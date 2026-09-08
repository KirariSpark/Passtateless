import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/core/pwd_item.dart';
import 'package:passtateless/modules/generator/errors.dart';
import 'package:passtateless/modules/generator/inputs.dart';
import 'package:passtateless/modules/generator/interpreter.dart';
import 'package:passtateless/modules/generator/presets.dart' as dsl_presets;
import 'package:passtateless/modules/generator/values.dart';
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
import 'package:passtateless/ui/widgets/styled_list_tile.dart';
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
  /// 语法正确的最小 DSL，作为自定义编辑器初始内容
  static const String _defaultDslSource = '''
GroupInput {
    str master: "主密码";
    str seedString: "种子字符串";
}
Generate {
    return toBase64(string: seedString);
}
''';

  // 一些只读的属性
  final CodeLineEditingController _configController =
      CodeLineEditingController.fromText(_defaultDslSource);
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
      MaterialPageRoute(
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
      return StyledListTileSimple(
        title: "配置生成规则",
        trailing: Icon(Icons.arrow_forward),
        isLast: true,
        isFirst: true,
        onTap: _editCfg,
      );
    }
    return null;
  }

  /// 请求额外的 GroupInput 输入（master/seedString 由程序提供，不弹窗）。
  /// 返回 {name: 值} 映射（str→String / int→int / bool→bool）；无额外输入返回空映射；取消返回 null。
  Future<Map<String, dynamic>?> _requestExtraInputs(
    BuildContext context,
    List<DslInput> inputs,
  ) async {
    final extra = inputs
        .where((i) => i.name != 'master' && i.name != 'seedString')
        .toList();
    if (extra.isEmpty) return <String, dynamic>{};

    appLogger.logger.i("Requesting ${extra.length} extra inputs");

    // 每个 str/int 输入一个控制器（预填默认值），bool 输入单独记录开关状态
    final controllers = <String, TextEditingController>{};
    final switchStates = <String, bool>{};
    for (final i in extra) {
      switch (i.type) {
        case DslType.str:
          controllers[i.name] =
              TextEditingController(text: (i.defaultValue as String?) ?? '');
        case DslType.int:
          controllers[i.name] =
              TextEditingController(text: i.defaultValue?.toString() ?? '');
        case DslType.bool:
          switchStates[i.name] = i.defaultValue as bool? ?? false;
      }
    }

    String? errorText;
    final result = await showDialog<Map<String, dynamic>>(
      useRootNavigator: false,
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          scrollable: true,
          shape: styles.roundedBorder,
          title: const Text("请求输入"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final i in extra) ...[
                switch (i.type) {
                  DslType.bool => SwitchListTile(
                      title: Text(i.displayName),
                      value: switchStates[i.name]!,
                      onChanged: (v) =>
                          setDialogState(() => switchStates[i.name] = v),
                    ),
                  _ => styled.buildTextField(
                      context: dialogContext,
                      controller: controllers[i.name],
                      label: i.displayName,
                      // int 使用数字键盘
                      keyboardType: i.type == DslType.int
                          ? TextInputType.number
                          : null,
                    ),
                },
                styles.spacingSizedBox,
              ],
              if (errorText != null)
                Text(
                  errorText!,
                  style: TextStyle(
                    color: ColorScheme.of(dialogContext).error,
                  ),
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
                final values = <String, dynamic>{};
                for (final i in extra) {
                  switch (i.type) {
                    case DslType.str:
                      final t = controllers[i.name]!.text.trim();
                      if (t.isEmpty && i.defaultValue == null) {
                        setDialogState(
                            () => errorText = "请填写“${i.displayName}”");
                        return;
                      }
                      values[i.name] = t;
                    case DslType.int:
                      final t = controllers[i.name]!.text.trim();
                      if (t.isEmpty) {
                        if (i.defaultValue != null) {
                          values[i.name] = i.defaultValue;
                        } else {
                          setDialogState(
                              () => errorText = "请填写“${i.displayName}”");
                          return;
                        }
                      } else {
                        final v = int.tryParse(t);
                        if (v == null) {
                          setDialogState(
                              () => errorText = "“${i.displayName}”必须是整数");
                          return;
                        }
                        values[i.name] = v;
                      }
                    case DslType.bool:
                      values[i.name] = switchStates[i.name]!;
                  }
                }
                Navigator.pop(dialogContext, values);
              },
              child: const Text("确定"),
            ),
          ],
        ),
      ),
    );

    for (final c in controllers.values) {
      c.dispose();
    }
    return result;
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

    // 1) 选取 DSL 源码：预设用内置 DSL，自定义用编辑器文本
    final String dslSource = switch (_preset) {
      Presets.simple => dsl_presets.simple,
      Presets.complex => dsl_presets.complex,
      Presets.bank => dsl_presets.bank,
      Presets.custom => _configController.text,
    };

    // 2) 解析 DSL 声明，收集额外输入并弹窗请求
    List<DslInput> declaredInputs;
    try {
      declaredInputs = parseDslInputs(dslSource);
    } on DslError catch (e) {
      appLogger.logger.e("DSL config error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "配置或生成出错\n${e.display}",
              style: TextStyle(fontFamily: "SourceCodePro"),
            ),
            showCloseIcon: true,
          ),
        );
      }
      return (ErrorCode.generateFailed, "");
    }
    final requested = await _requestExtraInputs(context, declaredInputs);
    if (requested == null) {
      // 用户取消输入，中止生成（不复制、不展示错误）
      appLogger.logger.i("Input cancelled, aborting generation");
      return (ErrorCode.unknown, "");
    }

    // 3) 组装输入：seedString 对应旧 composeSeed 的拼接结果；
    //    master 传入主密码哈希（明文不可恢复），供 DSL 脚本选用
    final String seedString = "$identifier: $userName @ $account";
    final inputValues = <String, dynamic>{
      'master': _appProvider.masterPwd,
      'seedString': seedString,
      ...requested,
    };

    // 4) 交给 DSL 解释器
    final result = await runDsl(dslSource, inputValues);

    if (!result.ok) {
      final err = result.error!;
      appLogger.logger.e("DSL generation error: $err");
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "配置或生成出错\n${err.display}",
              style: TextStyle(fontFamily: "SourceCodePro"),
            ),
            showCloseIcon: true,
          ),
        );
      }
      return (ErrorCode.generateFailed, "");
    }

    // 5) 成功：保留旧的“移除数字/字母/特殊字符”后处理
    var pwd = result.value!;
    if (_pwdProvider.removeDigits) pwd = utils.removeDigits(pwd);
    if (_pwdProvider.removeAlpha) pwd = utils.removeAlpha(pwd);
    if (_pwdProvider.removeSp) pwd = utils.removeSpChar(pwd);

    return _postProcess((ErrorCode.success, pwd), copyAfterGenerate);
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
        MaterialPageRoute(
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
        StyledListTileSimple(
          title: "档案名",
          subtitle: identifier,
          isFirst: true,
        ),
        StyledListTileSimple(
          title: "用户名",
          subtitle: userName,
        ),
        StyledListTileSimple(
          title: "账号",
          subtitle: account,
          isLast: true,
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
