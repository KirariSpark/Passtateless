import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/file_mgr/core_mgr.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/pages/settings/export.dart';
import 'package:passtateless/ui/pages/settings/import.dart';
import 'package:passtateless/ui/pages/settings/log_view.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:provider/provider.dart';
import 'package:re_editor/re_editor.dart';

// 高级设置页面
class AdvancedSettingsPage extends StatefulWidget {
  /// 有AppBar时，是否要使用Hero动画
  final bool useHero;

  /// 是否要包含AppBar
  final bool hasAppBar;

  /// 是否有内边距
  final bool hasPadding;

  const AdvancedSettingsPage({
    super.key,
    required this.useHero,
    this.hasAppBar = true,
    this.hasPadding = true
  });

  @override
  State<AdvancedSettingsPage> createState() => _AdvancedSettingsPageState();
}

class _AdvancedSettingsPageState extends State<AdvancedSettingsPage> {
  final TextEditingController masterController = TextEditingController();
  final CodeLineEditingController configController = CodeLineEditingController();
  final CodeLineEditingController pwdController = CodeLineEditingController();
  late final AppProvider _appProvider;
  late final PwdProvider _pwdProvider;

  Future<void> _changeLogLvl(LogLevels value) async {
    _appProvider.currentLogLevel = value;
    final stat = await _appProvider.saveConfig();
    if (mounted && stat != ErrorCode.success) ui.showSnackBarQuick(stat.generic, context);
  }

  void _showLogLvlDialog() {
    ui.showAlertDialogQuick(
      title: "日志等级",
      content: RadioGroup(
        groupValue: _appProvider.currentLogLevel,
        onChanged: (value) {
          _changeLogLvl(value!);
          Navigator.of(context).pop();
        },
        child: Column(
          children: [
            for (var item in LogLevels.values) RadioListTile(
              value: item,
              title: Text(item.displayName),
              shape: styles.roundedBorder,
            )
          ],
        )
      ),
      action: () => Navigator.of(context).pop(),
      actionText: "取消",
      context: context
    );
  }

  Future<void> _viewLog() async {
    appLogger.logger.i("Loading log");
    final (stat, res) = await readTextFile(Paths.log.path);
    if (context.mounted && stat == ErrorCode.success) {
      appLogger.logger.i("Log loaded");
      Navigator.push(context, ui.switchRoute(_appProvider.currentNavMode, builder: (_) => LogViewPage(log: res)));
    } else {
      appLogger.logger.e("Can not load log: ${stat.code}");
      ui.showSnackBarQuick(stat.generic, context);
    }
  }

  void _exportSettings() {
    appLogger.logger.i("Generating settings JSON");
    final text = _appProvider.getSettingsJson();
    appLogger.logger.i("Setting JSON generated");
    Navigator.push(
      context,
      ui.switchRoute(
        _appProvider.currentNavMode,
        builder: (_) => JsonExportPage(jsonText: text, title: "导出设置", titleTag: "setting_export")
      )
    );
  }

  void _exportPwd() {
    appLogger.logger.i("Trying to export password");
    final (stat, json) = _pwdProvider.getPwdJson(masterController.text, _appProvider.masterPwd);
    if (stat == ErrorCode.success) {
      appLogger.logger.i("Got password JSON");
      masterController.text = "";
      Navigator.pop(context);
      Navigator.push(
        context, ui.switchRoute(
        _appProvider.currentNavMode,
        builder: (_) => JsonExportPage(jsonText: json, title: "导出密码", titleTag: "pwd_export"))
      );
    } else {
      appLogger.logger.e("Can not get password map json: $stat");
      Navigator.pop(context);
      ui.showSnackBarQuick(stat.generic, context);
    }
  }

  void _showPwdExportDialog() {
    ui.showAlertDialogQuick(
      title: "危险操作",
      content: Column(
        spacing: styles.layoutSpacing,
        children: [
          Text("此操作会明文展示你的所有密码档案，需要先验证主密码"),
          styled.buildTextField(
            context: context,
            controller: masterController,
            passwordMode: true
          )
        ],
      ),
      action: () => Navigator.of(context).pop(),
      actionText: "取消",
      action2: _exportPwd,
      action2Text: "确定",
      context: context
    );
  }

  void _importSettings() {
    appLogger.logger.i("Importing setting using json");
    final stat = _appProvider.restoreConfigFromText(configController.text, fallback: false);
    if (stat == ErrorCode.success) {
      appLogger.logger.i("Successfully imported settings");
      ui.showSnackBarQuick("导入成功", context);
    } else {
      appLogger.logger.e("Can not import settings: ${stat.code}");
      ui.showSnackBarQuick(stat.generic, context);
    }
  }

  Future<void> _importPwd() async {
    appLogger.logger.i("Importing password using json");
    // Step1：使用JSON设置密码
    final importStat = _pwdProvider.setPwdByJson(pwdController.text);
    if (importStat != ErrorCode.success) {
      appLogger.logger.e("Can not import password: $importStat");
      ui.showSnackBarQuick(importStat.generic, context);
      return;
    }
    // Step2：保存更改
    appLogger.logger.i("Password imported successfully, saving changes");
    ui.showSnackBarQuick("导入成功，正在保存", context);
    final saveStat = await _pwdProvider.saveArchive(_appProvider.masterPwd);
    if (saveStat == ErrorCode.success) {
      appLogger.logger.i("Successfully saved passwords");
      if (mounted) ui.showSnackBarQuick("保存成功", context);
      return;
    }
    appLogger.logger.e("Failed to save passwords: $saveStat");
    if (mounted) ui.showSnackBarQuick(saveStat.generic, context);
  }

  @override
  void initState() {
    super.initState();
    _appProvider = context.read<AppProvider>();
    _pwdProvider = context.read<PwdProvider>();
  }

  @override
  void dispose() {
    masterController.dispose();
    configController.dispose();
    pwdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.hasAppBar
        ? styled.buildAppBar(title: "高级设置", titleTag: widget.useHero ? HeroTags.advancedSettings.tag : null, context: context)
        : null,
      body: Container(
        alignment: Alignment.topCenter,
        padding: widget.hasPadding ? styles.pagePaddingAll : null,
        child: ConstrainedBox(
          constraints: styles.tileWidthConstraint,
          child: ListView(
            children: [
              styled.buildListTile(
                isFirst: true,
                title: "日志等级",
                trailing: Icon(Icons.arrow_drop_down),
                onTapped: _showLogLvlDialog,
                context: context
              ),
              styled.buildListTile(
                title: "查看日志",
                titleTag: "log_view",
                trailing: Icon(Icons.arrow_forward),
                isLast: true,
                onTapped: _viewLog,
                context: context
              ),
              styles.spacingSizedBox,
              styled.buildListTile(
                title: "导出设置",
                titleTag: "setting_export",
                trailing: Icon(Icons.arrow_forward),
                isFirst: true,
                onTapped: _exportSettings,
                context: context
              ),
              styled.buildListTile(
                title: "导出密码",
                titleTag: "pwd_export",
                trailing: Icon(Icons.arrow_forward),
                onTapped: _showPwdExportDialog,
                context: context
              ),
              styled.buildListTile(
                title: "导入设置",
                titleTag: "setting_import",
                subtitle: "此行为会覆盖现有的设置",
                trailing: Icon(Icons.arrow_forward),
                onTapped:  () => Navigator.push(
                  context,
                  ui.switchRoute(
                    _appProvider.currentNavMode,
                    builder: (_) => SettingsImportPage(
                      title: "导入设置",
                      titleTag: "setting_import",
                      controller: configController,
                      onImport: _importSettings,
                    )
                  )
                ),
                context: context
              ),
              styled.buildListTile(
                isLast: true,
                title: "导入密码",
                subtitle: "此行为会覆盖部分现有的密码档案",
                titleTag: "pwd_import",
                trailing: Icon(Icons.arrow_forward),
                onTapped: () => Navigator.push(
                  context,
                  ui.switchRoute(
                    _appProvider.currentNavMode,
                    builder: (_) => SettingsImportPage(
                      title: "导入密码",
                      titleTag: "pwd_import",
                      onImport: _importPwd,
                      controller: pwdController
                    )
                  )
                ),
                context: context
              )
            ],
          ),
        ),
      ),
    );
  }
}