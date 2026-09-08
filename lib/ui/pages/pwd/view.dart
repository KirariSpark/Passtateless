import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/core/pwd_item.dart';
import 'package:passtateless/modules/generator/pwd_gen_controller.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:provider/provider.dart';
import 'package:passtateless/ui/pages/pwd/fullscreen.dart';
import 'package:passtateless/ui/pages/pwd/master_pwd.dart';
import 'package:passtateless/ui/pages/pwd/preset_panel.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/removal_cfg.dart';
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/ui/widgets/styled_list_tile.dart';

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
  late final String identifier;
  late final String userName;
  late final String account;
  late final String id;

  // Providers
  late final AppProvider _appProvider;
  late final PwdProvider _pwdProvider;

  // 密码生成逻辑控制器
  late final PwdGenController _genController;

  // 非快速模式下打开的记录
  late final PwdItem? _record;

  // Controllers
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController accountController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _appProvider = context.read<AppProvider>();
    _pwdProvider = context.read<PwdProvider>();
    _genController = PwdGenController(
      appProvider: _appProvider,
      pwdProvider: _pwdProvider,
    );

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
    _genController.dispose();
    identifierController.dispose();
    userNameController.dispose();
    accountController.dispose();
    super.dispose();
  }

  void _showWarningDialog() {
    ui.showConfirmDialogQuick(
      context: context,
      function: _viewPwd,
      title: "危险操作",
      info: "此操作将会显示你的密码，以便于你的记忆\n请确保周围没有人能够窥视到你的屏幕",
    );
  }

  /// 统一的生成结果反馈：复制、提示文案或错误展示
  void _handleGenResult((ErrorCode, String) res, {required bool doCopy}) {
    final (stat, out) = res;
    if (stat == ErrorCode.success) {
      appLogger.logger.i("Generated successfully");
      if (doCopy) {
        Clipboard.setData(ClipboardData(text: out));
        appLogger.logger.i("Password copied");
        ui.showSnackBarQuick("密码已复制", context);
      }
    } else if (stat == ErrorCode.unknown) {
      ui.showSnackBarQuick("请检查以上输入", context);
    } else if (out.isNotEmpty && context.mounted) {
      appLogger.logger.e("Can not generate password: $stat");
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(out, style: TextStyle(fontFamily: "SourceCodePro")),
          showCloseIcon: true,
        ),
      );
    }
  }

  Future<void> _genAndCopyPwd() async {
    // 生成前先验证主密码
    if (!await ensureMasterPwdVerified(context, _appProvider)) return;
    if (!mounted) return;
    // 开始生成
    appLogger.logger.i("Generating password for copying");
    setState(() => _genController.isGenerating = true);
    final res = await _genController.generate(
      seedString:
          "${widget.enableEdit ? identifierController.text : identifier}: ${widget.enableEdit ? userNameController.text : userName} @ ${widget.enableEdit ? accountController.text : account}",
    );
    if (!mounted) return;
    setState(() => _genController.isGenerating = false);
    _handleGenResult(res, doCopy: true);
  }

  Future<void> _viewPwd() async {
    appLogger.logger.i("Generating password for viewing");
    Navigator.pop(context);
    // 生成前先验证主密码
    if (!await ensureMasterPwdVerified(context, _appProvider)) return;
    if (!mounted) return;
    setState(() => _genController.isGenerating = true);
    final res = await _genController.generate(
      seedString: "$identifier: $userName @ $account",
    );
    if (!mounted) return;
    setState(() => _genController.isGenerating = false);
    if (res.$1 == ErrorCode.success) {
      appLogger.logger.i("Generated successfully, pushing to fullscreen mode");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FullscreenPwd(res.$2)),
      );
    } else {
      _handleGenResult(res, doCopy: false);
    }
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
                PresetPanel(
                  controller: _genController,
                  onChanged: () => setState(() {}),
                ),
                styles.spacingSizedBox,
                // 按钮
                Row(
                  spacing: styles.layoutSpacing,
                  children: [
                    // 查看密码
                    Expanded(
                      child: styled.buildTextButton(
                        onPressed: _genController.isGenerating ? null : _showWarningDialog,
                        context: context,
                        child: const Text("查看密码"),
                      ),
                    ),
                    // 复制密码
                    Expanded(
                      child: styled.buildTextButton(
                        onPressed: _genController.isGenerating ? null : _genAndCopyPwd,
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