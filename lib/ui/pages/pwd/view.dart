import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/generator/parser.dart' as parser;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/pages/pwd/cfg_edit.dart';
import 'package:passtateless/ui/pages/pwd/fullscreen.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:re_editor/re_editor.dart';

/// 密码记录的查看页面，也用于密码的生成功能，通过传入enableEdit来启用快速模式（此时将不会使用传入的id初始化页面）
///
/// 记录的 id 将被用于 Hero 动画
class PwdViewPage extends StatefulWidget {
  /// 要查看的密码记录的id
  final String id;

  /// 有AppBar时，AppBar是否要使用Hero动画
  final bool useHero;

  /// 页面是否有AppBar
  final bool hasAppBar;

  /// 页面是否有内边距
  final bool hasPadding;

  /// 是否启用编辑模式/快速模式
  final bool enableEdit;

  const PwdViewPage({
    super.key,
    this.id = "",
    this.useHero = true,
    this.hasAppBar = true,
    this.hasPadding = true,
    this.enableEdit = false,
  });

  @override
  State<PwdViewPage> createState() => _PwdViewPageState();
}

class _PwdViewPageState extends State<PwdViewPage> {
  // 一些只读的属性
  final CodeLineEditingController _configController = CodeLineEditingController.fromText("[{\"name\":\"toBase64\"}]");
  late final String identifier;
  late final String userName;
  late final String account;
  late final String id;

  // Providers
  late final AppProvider _appProvider;
  late final PwdProvider _pwdProvider;

  // Controllers
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController accountController = TextEditingController();

  // 一些内部要用到的状态
  Presets _preset = Presets.simple;
  bool isGenerating = false;
  bool removeDigits = false;
  bool removeAlpha = false;
  bool removeSp = false;
  bool somethingWentWrong = false; // 暂时还没用

  Future<void> _editCfg() async {
    // 跳转并等待返回结果
    appLogger.logger.i("Pushing to generator config edit page");
    final result = await Navigator.push(
      context,
      ui.switchRoute(
        _appProvider.currentNavMode,
        builder: (_) => CfgEditPage(initialText: _configController.text),
      ),
    );

    if (result != null && result is String) {
      setState(() => _configController.text = result);
      appLogger.logger.i("Got new config with ${result.length} characters");
      if (mounted) {
        ui.showSnackBarQuick("编辑结果已保存", context);
      }
    }
  }

  /// 根据当前预设决定是否显示自定义规则
  Widget? _showConfigEdit() {
    if (_preset == Presets.custom) {
      return styled.buildListTile(
        context: context,
        title: "配置生成规则",
        trailing: Icon(Icons.arrow_forward),
        isLast: true,
        onTapped: _editCfg,
      );
    }
    return null;
  }

  /// 密码生成后的处理，复制和显示snack bar
  (ErrorCode, String) _postProcess((ErrorCode, String) res, bool doCopy) {
    if (res.$1 == ErrorCode.success) {
      appLogger.logger.i("Generated successfully");
      if (doCopy) {
        Clipboard.setData(ClipboardData(text: res.$2));
      }
      if (context.mounted && doCopy) {
        appLogger.logger.i("Password copied");
        ui.showSnackBarQuick("密码已复制", context);
      }
    } else {
      if (context.mounted) {
        appLogger.logger.e("Can not generate password: ${res.$1.generic}");
        ui.showSnackBarQuick(res.$1.generic, context);
      }
    }
    return res;
  }

  bool _isBuiltin(Presets preset) {
    return <Presets>[
      Presets.simple,
      Presets.complex,
      Presets.bank,
    ].contains(_preset);
  }

  /// 生成密码并显示提示（返回生成的密码或错误信息）
  Future<(ErrorCode, String)> _genPwd({
    required BuildContext context,
    required bool copyAfterGenerate,
    required String identifier,
    required String userName,
    required String account,
  }) async {
    appLogger.logger.i("Generating password");
    setState(() => isGenerating = true);

    if (_isBuiltin(_preset)) {
      appLogger.logger.i("Generating using builtin presets");
      final res = await parser.parseBuiltins(
        _preset,
        "$identifier: $userName @ $account",
        removeAlpha: removeAlpha,
        removeDigits: removeDigits,
        removeSp: removeSp,
      );
      return _postProcess(res, copyAfterGenerate);
    }

    try {
      appLogger.logger.i("Generating using custom config");
      final res = await parser.parse(
        jsonDecode(_configController.text),
        "$identifier: $userName @ $account",
        removeAlpha: removeAlpha,
        removeDigits: removeDigits,
        removeSp: removeSp,
      );
      return _postProcess(res, copyAfterGenerate);
    } catch (e) {
      if (context.mounted) {
        appLogger.logger.e("Can not generate password: $e");
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "JSON 格式错误\n${e.toString()}",
              style: TextStyle(fontFamily: "SourceCodePro"),
            ),
            showCloseIcon: true,
          ),
        );
      }
      return (ErrorCode.jsonFormatError, "");
    }
  }

  AppBar? _buildAppBar(bool hasAppBar) {
    if (hasAppBar) {
      return styled.buildAppBar(
        title: identifier.isEmpty ? '未命名' : identifier,
        titleTag: widget.useHero ? id : null,
        context: context,
      );
    }
    return null;
  }

  void _selectPreset(Presets? value) {
    appLogger.logger.i("Setting preset to ${value?.name}");
    setState(() => _preset = value ?? Presets.simple);
    Navigator.pop(context);
  }

  void _showPresetSelectionDialog() {
    ui.showAlertDialogQuick(
      title: "选择预设",
      content: RadioGroup(
        groupValue: _preset,
        onChanged: _selectPreset,
        child: Column(
          children: [
            for (var item in Presets.values)
              RadioListTile(
                value: item,
                subtitle: Text(item.desc),
                shape: styles.roundedBorder,
                title: Text(item.displayName),
              ),
          ],
        ),
      ),
      actionText: "取消",
      action: () => Navigator.of(context).pop(),
      context: context,
    );
  }

  void _showWarningDialog() {
    ui.showConfirmDialogQuick(
      context: context,
      function: _viewPwd,
      title: "危险操作",
      info: "此操作将会显示你的密码，以便于你的记忆\n请确保周围没有人能够窥视到你的屏幕",
    );
  }

  Future<void> _genAndCopyPwd() async {
    // 开始生成
    appLogger.logger.i("Generating password for copying");
    await _genPwd(
      context: context,
      copyAfterGenerate: true,
      identifier: widget.enableEdit ? identifierController.text : identifier,
      userName: widget.enableEdit ? userNameController.text : userName,
      account: widget.enableEdit ? accountController.text : account,
    );
    // 启用按钮
    setState(() => isGenerating = false);
  }

  Future<void> _viewPwd() async {
    appLogger.logger.i("Generating password for viewing");
    Navigator.pop(context);
    final (stat, res) = await _genPwd(
      context: context,
      copyAfterGenerate: false,
      identifier: identifier,
      userName: userName,
      account: account,
    );
    if (context.mounted) {
      if (stat == ErrorCode.success) {
        appLogger.logger.i(
          "Generated successfully, pushing to fullscreen mode",
        );
        Navigator.push(
          context,
          ui.switchRoute(
            _appProvider.currentNavMode,
            builder: (context) => FullscreenPwd(res),
          ),
        );
      } else {
        appLogger.logger.e("Can not generate password: ${stat.code}");
      }
    }
    // 启用按钮
    setState(() => isGenerating = false);
  }

  List<Widget> _buildHeader() {
    if (widget.enableEdit) {
      return [
        styled.buildTextField(
          label: "档案名",
          controller: identifierController,
          context: context
        ),
        styles.spacingSizedBox,
        styled.buildTextField(
          label: "用户名",
          controller: userNameController,
          context: context
        ),
        styles.spacingSizedBox,
        styled.buildTextField(
          label: "账号",
          controller: accountController,
          context: context
        )
      ];
    } else {
      return [
        styled.buildListTile(
          title: "档案名",
          subtitle: identifier,
          isFirst: true,
          context: context,
        ),
        styled.buildListTile(
          title: "用户名",
          subtitle: userName,
          context: context,
        ),
        styled.buildListTile(
          title: "账号",
          subtitle: account,
          isLast: true,
          context: context,
        ),
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    _appProvider = context.read<AppProvider>();
    _pwdProvider = context.read<PwdProvider>();

    if (!widget.enableEdit) {
      final data = _pwdProvider.getItemById(widget.id);
      identifier = data["identifier"];
      userName = data["userName"];
      account = data["account"];
      id = data["id"];
    } else {
      identifier = "Quick mode enabled";
      userName = "Quick mode enabled";
      account = "Quick mode enabled";
      id = "Quick mode enabled";
    }
  }

  @override
  void dispose() {
    _configController.dispose();
    identifierController.dispose();
    userNameController.dispose();
    accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(widget.hasAppBar),
      body: SingleChildScrollView(
        child: Container(
          padding: widget.hasPadding ? styles.pagePaddingAll : EdgeInsets.zero,
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: styles.tileWidthConstraint,
            child: Column(
              children: [
                ..._buildHeader(),
                styles.spacingSizedBox,
                // 移除数字
                SwitchListTile(
                  value: removeDigits,
                  onChanged: (value) {
                    if (removeSp == true && removeAlpha == true) return;
                    setState(() => removeDigits = value);
                    appLogger.logger.d(
                      "Current digit removal state: $removeDigits",
                    );
                  },
                  title: const Text("移除数字"),
                  shape: RoundedRectangleBorder(
                    borderRadius: ui.calcRadius(isFirst: true),
                  ),
                  tileColor: ColorScheme.of(context).surfaceContainerLow,
                ),
                // 移除字母
                SwitchListTile(
                  value: removeAlpha,
                  onChanged: (value) {
                    if (removeDigits == true && removeSp == true) return;
                    setState(() => removeAlpha = value);
                    appLogger.logger.d(
                      "Current alphabet removal state: $removeAlpha",
                    );
                  },
                  title: const Text("移除字母"),
                  tileColor: ColorScheme.of(context).surfaceContainerLow,
                ),
                // 移除特殊字符
                SwitchListTile(
                  value: removeSp,
                  onChanged: (value) {
                    if (removeDigits == true && removeAlpha == true) return;
                    setState(() => removeSp = value);
                    appLogger.logger.d(
                      "Current special char removal state: $removeSp",
                    );
                  },
                  title: const Text("移除特殊字符"),
                  shape: RoundedRectangleBorder(
                    borderRadius: ui.calcRadius(isLast: true),
                  ),
                  tileColor: ColorScheme.of(context).surfaceContainerLow,
                ),
                styles.spacingSizedBox,
                styled.buildListTile(
                  context: context,
                  title: "生成预设",
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _preset.displayName,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                  isFirst: true,
                  isLast: _preset == Presets.custom ? false : true,
                  onTapped: _showPresetSelectionDialog,
                ),
                ?_showConfigEdit(),
                styles.spacingSizedBox,
                // 按钮
                Row(
                  spacing: styles.layoutSpacing,
                  children: [
                    // 查看密码
                    Expanded(
                      child: styled.buildTextButton(
                        onPressed: isGenerating ? null : _showWarningDialog,
                        context: context,
                        child: const Text("查看密码"),
                      ),
                    ),
                    // 复制密码
                    Expanded(
                      child: styled.buildTextButton(
                        onPressed: isGenerating ? null : _genAndCopyPwd,
                        context: context,
                        child: const Text("复制密码"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
