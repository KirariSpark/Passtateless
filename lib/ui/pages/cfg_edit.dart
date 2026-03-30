import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/modules/utils/utils.dart' as utils;
import 'package:passtateless/ui/pages/doc.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
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
    _configController = CodeLineEditingController.fromText(widget.initialText);
  }

  @override
  void dispose() {
    _configController.dispose();
    super.dispose();
  }

  void _formatJSON() {
    var res = utils.formatJSON(_configController.text);
    if (res.$1 == ErrorCode.success) {
      setState(() {
        _configController.text = res.$2;
      });
    } else {
      ui.showSnackBarQuick("JSON 格式错误", context);
    }
  }

  void _showHelp() {
    ui.showAlertQuickWidget(
      "选择帮助",
      ConstrainedBox(
        constraints: styles.tileWidthConstraint,
        child: SingleChildScrollView(
          child: Column(
            spacing: styles.layoutSpacing,
            children: <Widget>[
              styled.buildListTile(
                title: "JSON 语法基础",
                alpha: styles.alphaTransparent,
                onTapped: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => DocPage(title: "JSON 语法", mode: "json"))
                  );
                },
                context: context),
              styled.buildListTile(
                title: "生成配置",
                alpha: styles.alphaTransparent,
                onTapped: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => DocPage(title: "生成配置", mode: "cfg"))
                  );
                },
                context: context
              ),
              styled.buildListTile(
                title: "生成规则提示",
                alpha: styles.alphaTransparent,
                onTapped: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => DocPage(title: "提示", mode: "tip"))
                  );
                },
                context: context),
              styled.buildListTile(
                title: "格式化与可读性",
                alpha: styles.alphaTransparent,
                onTapped: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => DocPage(title: "格式化与可读性", mode: "formatting"))
                  );
                },
                context: context)
            ],
          ),
        ),
      ),
      "取消",
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close),
          style: styles.buttonStyle,
        ),
        title: const Text("编辑生成规则"),
        actions: [
          IconButton(
            onPressed: () {
              // 带参数 pop，把编辑器里的内容传回上一页
              Navigator.pop(context, _configController.text);
            },
            icon: const Icon(Icons.save_outlined),
            style: styles.buttonStyle,
          )
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
                  backgroundColor: ColorScheme.of(context).surfaceContainerLowest.withAlpha(styles.alphaSemitransparent),
                ),
                borderRadius: styles.borderRadius,
                indicatorBuilder: (context, editingController, chunkController, notifier) {
                  return Row(
                    children: [
                      DefaultCodeLineNumber(
                        controller: editingController,
                        notifier: notifier,
                      ),
                      DefaultCodeChunkIndicator(
                        width: 20,
                        controller: chunkController,
                        notifier: notifier,
                      )
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
                      backgroundColor: ColorScheme.of(context).surfaceContainerLowest.withAlpha(styles.alphaOpaque),
                      shape: styles.roundedBorder,
                    ),
                    onPressed: _formatJSON,
                    child: const Text("格式化"),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorScheme.of(context).surfaceContainerLowest.withAlpha(styles.alphaOpaque),
                      shape: styles.roundedBorder,
                    ),
                    onPressed: _showHelp,
                    child: const Text("帮助"),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
