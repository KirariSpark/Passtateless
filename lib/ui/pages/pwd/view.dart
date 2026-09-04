import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/core/pwd_item.dart';
import 'package:passtateless/modules/generator/generate.dart' as generate;
import 'package:provider/provider.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/modules/utils/utils.dart' as utils;
import 'package:passtateless/ui/pages/pwd/cfg_edit.dart';
import 'package:passtateless/ui/pages/pwd/fullscreen.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/removal_cfg.dart';
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

  // 非快速模式下打开的记录
  late final PwdItem? _record;

  // Controllers
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController accountController = TextEditingController();

  // 一些内部要用到的状态
  Presets _preset = Presets.simple;
  bool isGenerating = false;

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
        isFirst: true,
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

    final res = await generate.generatePassword(
      preset: _preset,
      configText: _configController.text,
      identifier: identifier,
      userName: userName,
      account: account,
      removeDigits: _pwdProvider.removeDigits,
      removeAlpha: _pwdProvider.removeAlpha,
      removeSp: _pwdProvider.removeSp,
    );

    if (res.$1 == ErrorCode.jsonFormatError) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "JSON 格式错误\n${res.$2}",
              style: TextStyle(fontFamily: "SourceCodePro"),
            ),
            showCloseIcon: true,
          ),
        );
      }
      return (ErrorCode.jsonFormatError, "");
    }

    return _postProcess(res, copyAfterGenerate);
  }

  AppBar? _buildAppBar(bool hasAppBar) {
    if (hasAppBar) {
      return styled.buildAppBar(
        title: widget.enableEdit
            ? "快速开始"
            : (_record?.displayName ?? "未命名"),
        titleTag: widget.useHero ? id : null,
        context: context,
      );
    }
    return null;
  }

  void _selectPreset(Presets? value) {
    appLogger.logger.i("Setting preset to ${value?.name}");
    setState(() => _preset = value ?? Presets.simple);
  }

  void _showWarningDialog() {
    ui.showConfirmDialogQuick(
      context: context,
      function: _viewPwd,
      title: "危险操作",
      info: "此操作将会显示你的密码，以便于你的记忆\n请确保周围没有人能够窥视到你的屏幕",
    );
  }

  /// 弹出主密码验证对话框，返回：验证结果为ErrorCode或null（用户取消）
  Future<ErrorCode?> _verifyMasterPwd() async {
    appLogger.logger.i("Requesting master password verification");
    final controller = TextEditingController();
    final result = await showDialog<ErrorCode>(
      useRootNavigator: false,
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        shape: styles.roundedBorder,
        title: const Text("验证主密码"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("生成密码前需要先验证主密码"),
            styles.spacingSizedBox,
            styled.buildTextField(
              context: dialogContext,
              controller: controller,
              label: "主密码",
              passwordMode: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            style: styles.buttonStyle,
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("取消"),
          ),
          TextButton(
            style: styles.buttonStyle,
            onPressed: () {
              if (controller.text.isEmpty) {
                Navigator.pop(dialogContext, ErrorCode.emptyPwd);
              } else if (utils.toSHA256(controller.text) ==  _appProvider.masterPwd) {
                Navigator.pop(dialogContext, ErrorCode.success);
              } else {
                Navigator.pop(dialogContext, ErrorCode.wrongPwd);
              }
            },
            child: const Text("确定"),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  /// 验证主密码，未通过或取消时返回false；密码错误时给出提示
  Future<bool> _ensureMasterPwdVerified() async {
    if (_appProvider.masterPwd.isEmpty) return true;
    final result = await _verifyMasterPwd();
    if (result == ErrorCode.success) return true;
    if (result != null && mounted) {
      appLogger.logger.e(result.generic);
      ui.showSnackBarQuick(result.generic, context);
    }
    return false;
  }

  Future<void> _genAndCopyPwd() async {
    // 生成前先验证主密码
    if (!await _ensureMasterPwdVerified()) return;
    if (!mounted) return;
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
    if (mounted) setState(() => isGenerating = false);
  }

  Future<void> _viewPwd() async {
    appLogger.logger.i("Generating password for viewing");
    Navigator.pop(context);
    // 生成前先验证主密码
    if (!await _ensureMasterPwdVerified()) return;
    if (!mounted) return;
    final (stat, res) = await _genPwd(
      context: context,
      copyAfterGenerate: false,
      identifier: identifier,
      userName: userName,
      account: account,
    );
    if (!mounted) return;
    if (stat == ErrorCode.success) {
      appLogger.logger.i("Generated successfully, pushing to fullscreen mode");
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
    // 启用按钮
    setState(() => isGenerating = false);
  }

  List<Widget> _buildHeader() {
    if (widget.enableEdit) {
      return [
        styled.buildTextField(
          label: "档案名",
          controller: identifierController,
          context: context,
        ),
        styles.spacingSizedBox,
        styled.buildTextField(
          label: "用户名",
          controller: userNameController,
          context: context,
        ),
        styles.spacingSizedBox,
        styled.buildTextField(
          label: "账号",
          controller: accountController,
          context: context,
        ),
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
      _record = _pwdProvider.getItemById(widget.id);
      identifier = _record?.identifier ?? "";
      userName = _record?.userName ?? "";
      account = _record?.account ?? "";
      id = _record?.id ?? widget.id;
    } else {
      _record = null;
      identifier = "快速开始";
      userName = "快速开始";
      account = "快速开始";
      id = "快速开始";
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
                const RemovalCfg(),
                styles.spacingSizedBox,
                DropdownMenu(
                  label: Text("生成预设"),
                  width: double.infinity,
                  helperText: _preset.desc,
                  menuStyle: MenuStyle(
                    maximumSize: WidgetStatePropertyAll<Size>(Size(120, double.infinity))
                  ),
                  dropdownMenuEntries: [
                    for (Presets i in Presets.values) DropdownMenuEntry(
                      value: i,
                      label: i.displayName,
                    )
                  ],
                  onSelected: (value) => _selectPreset(value),
                  initialSelection: _preset,
                  selectOnly: true,
                ),
                styles.spacingSizedBox,
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
