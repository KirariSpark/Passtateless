import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/modules/utils/utils.dart' as utils;
import 'package:passtateless/ui/pages/help/doc_view.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/modules/core/logger.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/styles/a11y-dark.dart';
import 'package:re_highlight/styles/a11y-light.dart';

class CfgEditPage extends StatefulWidget {
  final String initialText;

  const CfgEditPage({super.key, required this.initialText});

  @override
  State<CfgEditPage> createState() => _CfgEditPageState();
}

class _CfgEditPageState extends State<CfgEditPage> {
  late final CodeLineEditingController _configController;

  @override
  void initState() {
    super.initState();
    // 初始化时填入父页面传来的数据
    appLogger.logger.i("Showing generator config edit page with ${widget.initialText.length} characters");
    _configController = CodeLineEditingController.fromText(widget.initialText);
  }

  @override
  void dispose() {
    _configController.dispose();
    super.dispose();
  }

  void _formatJSON() {
    appLogger.logger.i("Formatting generator config JSON");
    var res = utils.formatJSON(_configController.text);
    if (res.$1 == ErrorCode.success) {
      setState(() {
        _configController.text = res.$2;
      });
    } else {
      appLogger.logger.e("Formatting failed: ${res.$1.code}");
      ui.showSnackBarQuick("JSON 格式错误", context);
    }
  }

  void _showHelp() {
    ui.showAlertDialogQuick(
      title: "选择帮助",
      content: ConstrainedBox(
        constraints: styles.tileWidthConstraint,
        child: Column(
          children: <Widget>[
            styled.buildListTile(
              title: "JSON 语法基础",
              onTapped: () {
                appLogger.logger.i("Pushing to help page json");
                Navigator.of(context, rootNavigator: true).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocViewPage(title: "JSON 语法", mode: "json"),
                  ),
                );
              },
              isFirst: true,
              context: context,
            ),
            styled.buildListTile(
              title: "生成配置",
              onTapped: () {
                appLogger.logger.i("Pushing to help page cfg");
                Navigator.of(context, rootNavigator: true).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocViewPage(title: "生成配置", mode: "cfg"),
                  ),
                );
              },
              context: context,
            ),
            styled.buildListTile(
              title: "生成规则提示",
              onTapped: () {
                appLogger.logger.i("Pushing to help page cfg_tips");
                Navigator.of(context, rootNavigator: true).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocViewPage(title: "提示", mode: "cfg_tips"),
                  ),
                );
              },
              context: context,
            ),
            styled.buildListTile(
              title: "格式化与可读性",
              onTapped: () {
                appLogger.logger.i("Pushing to help page formatting");
                Navigator.of(context, rootNavigator: true).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocViewPage(title: "格式化与可读性", mode: "formatting")
                  )
                );
              },
              isLast: true,
              context: context,
            ),
          ],
        ),
      ),
      actionText: "取消",
      action: () {Navigator.of(context, rootNavigator: true).pop();},
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: styled.buildAppBar(
        title: "自定义规则",
        context: context,
        exitIcon: Icons.close,
        actions: [
          IconButton(
            onPressed: () {
              appLogger.logger.i("Saving latest config and exiting");
              Navigator.pop(context, _configController.text);
            },
            icon: const Icon(Icons.save_outlined),
            style: styles.buttonStyle,
          ),
        ],
      ),
      body: Padding(
        padding: styles.uniInsetsSmall,
        child: Column(
          children: [
            Expanded(
              child: CodeEditor(
                wordWrap: false,
                controller: _configController,
                style: CodeEditorStyle(
                  codeTheme: CodeHighlightTheme(
                    languages: {'json': CodeHighlightThemeMode(mode: langJson)},
                    theme: ColorScheme.of(context).brightness == Brightness.light ? a11YLightTheme : a11YDarkTheme,
                  ),
                  fontSize: 14,
                  backgroundColor: ColorScheme.of(
                    context,
                  ).surfaceContainerLow.withAlpha(styles.alphaSemitransparent),
                ),
                borderRadius: styles.borderRadius,
                indicatorBuilder: (context, editingController, chunkController, notifier) {
                  return Row(
                    children: [
                      DefaultCodeLineNumber(controller: editingController, notifier: notifier),
                      DefaultCodeChunkIndicator(width: 20, controller: chunkController, notifier: notifier),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: styles.layoutSpacing),
            Row(
              spacing: styles.layoutSpacing,
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorScheme.of(context).surfaceContainerLow.withAlpha(styles.alphaOpaque),
                      shape: styles.roundedBorder,
                    ),
                    onPressed: _formatJSON,
                    child: const Text("格式化"),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorScheme.of(context).surfaceContainerLow.withAlpha(styles.alphaOpaque),
                      shape: styles.roundedBorder,
                    ),
                    onPressed: _showHelp,
                    child: const Text("帮助"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
