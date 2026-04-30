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
  const AdvancedSettingsPage({super.key, required this.useHero, this.hasAppBar = true, this.hasPadding = true});

  @override
  State<AdvancedSettingsPage> createState() => _AdvancedSettingsPageState();
}

class _AdvancedSettingsPageState extends State<AdvancedSettingsPage> {
  final TextEditingController masterController = TextEditingController();
  final CodeLineEditingController configController = CodeLineEditingController();
  final CodeLineEditingController pwdController = CodeLineEditingController();

  @override
  void dispose() {
    masterController.dispose();
    configController.dispose();
    pwdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final pwdProvider = Provider.of<PwdProvider>(context, listen: false);

    return Scaffold(
      appBar: widget.hasAppBar
        ? styled.buildAppBar(title: "高级设置", titleTag: widget.useHero ? "advanced" : null, context: context)
        : null,
      body: Container(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: styles.tileWidthConstraint,
          padding: widget.hasPadding ? styles.pagePadding : null,
          child: SingleChildScrollView(
            child: Column(
              children: [
                styled.buildListTile(
                  isFirst: true,
                  title: "日志等级",
                  trailing: Icon(Icons.arrow_drop_down),
                  onTapped: () {
                    ui.showAlertDialogQuick(
                      title: "日志等级",
                      content: RadioGroup(
                        groupValue: appProvider.currentLogLevel,
                        onChanged: (value) {
                          appProvider.currentLogLevel = value!;
                          appProvider.saveConfig();
                          Navigator.of(context, rootNavigator: true).pop();
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
                      action: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      actionText: "取消",
                      context: context
                    );
                  },
                  context: context
                ),
                styled.buildListTile(
                  title: "查看日志",
                  titleTag: "log_view",
                  trailing: Icon(Icons.arrow_forward),
                  isLast: true,
                  onTapped: () async {
                    appLogger.logger.i("Loading log");
                    final (stat, res) = await readTextFile(Paths.log.path);
                    if (context.mounted && stat == ErrorCode.success) {
                      appLogger.logger.i("Log loaded");
                      Navigator.push(
                        context, ui.switchRoute(appProvider.currentNavMode, builder: (_) => LogViewPage(log: res))
                      );
                    } else {
                      appLogger.logger.e("Can not load log: ${stat.code}");
                      ui.showSnackBarQuick(stat.generic, context);
                    }
                  },
                  context: context
                ),
                styles.spacingSizedBox,
                styled.buildListTile(
                  title: "导出设置",
                  titleTag: "setting_export",
                  trailing: Icon(Icons.arrow_forward),
                  isFirst: true,
                  onTapped: () {
                    appLogger.logger.i("Generating settings JSON");
                    final text = Provider.of<AppProvider>(context, listen: false).getSettingsJson();
                    appLogger.logger.i("JSON generated");
                    Navigator.push(
                      context,
                      ui.switchRoute(
                        appProvider.currentNavMode,
                        builder: (_) => JsonExportPage(jsonText: text, title: "导出设置", titleTag: "setting_export")
                      )
                    );
                  },
                  context: context
                ),
                styled.buildListTile(
                  title: "导出密码",
                  titleTag: "pwd_export",
                  trailing: Icon(Icons.arrow_forward),
                  onTapped: () {
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
                      action: () {Navigator.of(context, rootNavigator: true).pop();},
                      actionText: "取消",
                      action2: () {
                        final res = pwdProvider.getPwdJson(masterController.text, appProvider.masterPwd);
                        if (res.$1 == ErrorCode.success) {
                          appLogger.logger.i("Got JSON");
                          masterController.text = "";
                          Navigator.of(context, rootNavigator: true).pop();
                          Navigator.push(
                            context, ui.switchRoute(
                              appProvider.currentNavMode,
                              builder: (_) => JsonExportPage(jsonText: res.$2, title: "导出密码", titleTag: "pwd_export")
                            )
                          );
                        } else {
                          appLogger.logger.e("Can not get password map json: ${res.$1.code}");
                          Navigator.of(context, rootNavigator: true).pop();
                          ui.showSnackBarQuick(res.$1.generic, context);
                        }
                      },
                      action2Text: "确定",
                      context: context
                    );
                  },
                  context: context
                ),
                styled.buildListTile(
                  title: "导入设置",
                  titleTag: "setting_import",
                  subtitle: "此行为会覆盖现有的设置",
                  trailing: Icon(Icons.arrow_forward),
                  onTapped:  () => Navigator.push(
                    context, ui.switchRoute(
                      appProvider.currentNavMode, builder: (_) => SettingsImportPage(
                        title: "导入设置",
                        titleTag: "setting_import",
                        controller: configController,
                        onImport: () {
                          appLogger.logger.i("Importing setting using json");
                          final stat = appProvider.restoreConfigFromText(configController.text, fallback: false);
                          if (stat == ErrorCode.success) {
                            ui.showSnackBarQuick("导入成功", context);
                          } else {
                            appLogger.logger.e("Can not import settings: ${stat.code}");
                            ui.showSnackBarQuick(stat.generic, context);
                          }
                        },
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
                  onTapped: () {
                    Navigator.push(
                      context, ui.switchRoute(
                        appProvider.currentNavMode, builder: (_) => SettingsImportPage(
                          title: "导入密码",
                          titleTag: "pwd_import",
                          onImport: () async {
                            appLogger.logger.i("Importing password using json");
                            final stat = pwdProvider.setPwdByJson(pwdController.text);
                            if (stat == ErrorCode.success) {
                              appLogger.logger.i("Password imported successfully, saving changes");
                              ui.showSnackBarQuick("导入成功，正在保存", context);
                              final stat = await pwdProvider.saveArchive(appProvider.masterPwd);
                              if (stat == ErrorCode.success) {
                                appLogger.logger.i("Successfully saved passwords");
                                if (context.mounted) {
                                  ui.showSnackBarQuick("保存成功", context);
                                }
                              } else {
                                appLogger.logger.e("Failed to save passwords: $stat");
                                if (context.mounted) {
                                  ui.showSnackBarQuick(stat.generic, context);
                                }
                              }
                            } else {
                              appLogger.logger.e("Can not import password: $stat");
                              ui.showSnackBarQuick(stat.generic, context);
                            }
                          },
                          controller: pwdController
                        )
                      )
                    );
                  },
                  context: context
                )
              ],
            )
          ),
        ),
      ),
    );
  }
}