import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/generator/pwd_gen_controller.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:provider/provider.dart';
import 'package:passtateless/ui/pages/pwd/fullscreen.dart';
import 'package:passtateless/ui/pages/pwd/preset_panel.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/removal_cfg.dart';
import 'package:passtateless/ui/widgets/styled.dart' as styled;

/// 纯无状态密码生成页面：输入用户名、账号、主密码，即时生成密码。
class PwdViewPage extends StatefulWidget {
  /// 有AppBar时，AppBar是否要使用Hero动画
  final bool useHero;

  /// 页面是否有AppBar
  final bool hasAppBar;

  /// 页面是否有内边距
  final bool hasPadding;

  /// 兼容旧调用方的占位参数，已不再生效
  final String id;

  /// 兼容旧调用方的占位参数，已不再生效
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
  // Providers
  late final AppProvider _appProvider;
  late final PwdProvider _pwdProvider;

  // 密码生成逻辑控制器
  late final PwdGenController _genController;

  // Controllers
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController accountController = TextEditingController();
  final TextEditingController masterPwdController = TextEditingController();

  AppBar? _buildAppBar(bool hasAppBar) {
    if (hasAppBar) {
      return styled.buildAppBar(
        title: "主页",
        titleTag: widget.useHero ? widget.id : null,
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
  }

  @override
  void dispose() {
    _genController.dispose();
    userNameController.dispose();
    accountController.dispose();
    masterPwdController.dispose();
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

  /// 生成前将主密码交由 AppProvider 哈希，作为 master 输入
  void _refreshMasterPwd() {
    _appProvider.masterPwd = masterPwdController.text;
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

  String get _seed => "${userNameController.text} @ ${accountController.text}";

  Future<void> _genAndCopyPwd() async {
    _refreshMasterPwd();
    // 开始生成
    appLogger.logger.i("Generating password for copying");
    setState(() => _genController.isGenerating = true);
    final res = await _genController.generate(seedString: _seed);
    if (!mounted) return;
    setState(() => _genController.isGenerating = false);
    _handleGenResult(res, doCopy: true);
  }

  Future<void> _viewPwd() async {
    _refreshMasterPwd();
    Navigator.pop(context);
    appLogger.logger.i("Generating password for viewing");
    setState(() => _genController.isGenerating = true);
    final res = await _genController.generate(seedString: _seed);
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
    return [
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
      styles.spacingSizedBox,
      styled.buildTextField(
        label: "主密码",
        controller: masterPwdController,
        passwordMode: true,
        context: context,
      ),
    ];
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