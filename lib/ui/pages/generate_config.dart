import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/providers/config_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/styles.dart' as styles;

class ConfigTab extends StatefulWidget {
  const ConfigTab({super.key});

  @override
  State<ConfigTab> createState() => _ConfigTabState();
}

class _ConfigTabState extends State<ConfigTab> {
  void _showSnackBarQuick(String content) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ui.showSnackBarQuick(content, context);
      }
    });
  }

  void _popQuick() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, ConfigProvider>(
      builder: (context, appProvider, configProvider, child) {
        return SafeArea(
          child: Center(
            child: Container(
              constraints: styles.uniBoxConstraints,
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.all(8),
              child: Column(
                spacing: styles.layoutSpacing,
                children: <Widget>[
                  // 顶部按钮组 Wrap
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      // 加载保存的文件
                      IconButton(
                        tooltip: "加载保存文件",
                        onPressed: () async {
                          final (int, String) loadRes = await configProvider.loadConfig();
                          _showSnackBarQuick(loadRes.$2);
                        },
                        style: styles.buttonStyle,
                        icon: const Icon(Icons.folder_open),
                      ),
                      // 保存当前文件
                      IconButton(
                        tooltip: "覆盖保存的文件",
                        onPressed: () async {
                          ui.showConfirmDialogQuick(
                            context,
                              () async {
                                final (int, String) saveRes = await configProvider.saveConfig();
                                _showSnackBarQuick(saveRes.$2);
                                _popQuick();
                              },
                            "确认覆盖"
                          );
                        },
                        style: styles.buttonStyle,
                        icon: const Icon(Icons.save_outlined),
                      ),
                      // 打开示例文件
                      IconButton(
                        tooltip: "打开示例文件",
                        onPressed: (){
                          if (configProvider.selectedDemo.isEmpty && configProvider.availableDemos.isNotEmpty) {
                            configProvider.selectDemo(configProvider.availableDemos.keys.first);
                          }
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("选择示例文件"),
                              shape: styles.roundedBorder,
                              // 操作按钮
                              actions: [
                                TextButton(
                                  style: styles.buttonStyle,
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("取消")
                                ),
                                TextButton(
                                  style: styles.buttonStyle,
                                  onPressed: () {
                                    configProvider.loadDemoFiles();
                                    Navigator.pop(context);
                                  },
                                  child: const Text("加载")
                                )
                              ],
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 8,
                                children: [
                                  const Text("示例文件是明文存储的\n你不应将其用于实际密码生成"),
                                  DropdownMenu<String>(
                                    initialSelection: configProvider.availableDemos.keys.first,
                                    dropdownMenuEntries:
                                    configProvider.availableDemos.entries
                                        .map<DropdownMenuEntry<String>>(
                                            (entry) => DropdownMenuEntry<String>(
                                          value: entry.key,
                                          label: entry.value,
                                        )).toList(),
                                    onSelected: (String? value) {
                                      configProvider.selectDemo(value);
                                    },
                                  ),
                                ],
                              ),
                            ));
                        },
                        style: styles.buttonStyle,
                        icon: const Icon(Icons.lightbulb_outline),
                      ),
                      // 查看警告
                      IconButton(
                        tooltip: "查看警告",
                        onPressed: () {
                          appProvider.refreshWarnings();
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: styles.roundedBorder,
                              title: const Text("当前警告"),
                              content: Text(appProvider.v2Warnings == "" ? "没有警告" : appProvider.v2Warnings),
                              actions: [
                                TextButton(
                                  style: styles.buttonStyle,
                                  onPressed: () {Navigator.pop(context);},
                                  child: const Text("确定")
                                )
                              ],
                            )
                          );
                        },
                        style: styles.buttonStyle,
                        icon: const Icon(Icons.warning_amber_rounded),
                      ),
                      // 删除保存的文件
                      IconButton(
                        style: styles.buttonStyle,
                        tooltip: "删除保存的文件",
                        onPressed: () async {
                          ui.showConfirmDialogQuick(
                            context,
                            () async {
                              final (int, String) delRes = await configProvider.deleteConfig();
                              _showSnackBarQuick(delRes.$2);
                              _popQuick();
                            },
                            "确认删除"
                          );
                        },
                        icon: Icon(
                          Icons.delete_forever,
                          color: Theme.of(context).colorScheme.error,
                        )
                      )
                    ],
                  ),
                  styles.uniSizedBoxMedium,

                  // 文本编辑
                  TextField(
                    controller: configProvider.masterPassword,
                    decoration: styles.uniInputDecoration("主密码"),
                  ),
                  Expanded(
                    child: TextField(
                      maxLines: 32767,
                      decoration: styles.uniInputDecoration("生成规则"),
                      controller: configProvider.v2ConfigJson,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}
