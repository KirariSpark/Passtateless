import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/modules/utils/utils.dart' as utils;
import 'package:passtateless/ui/pages/help/doc_view.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:provider/provider.dart';
import 'package:re_editor/re_editor.dart';

class CfgEditPage extends StatefulWidget {
  /// 一开始要显示的内容
  final String initialText;

  const CfgEditPage({super.key, required this.initialText});

  @override
  State<CfgEditPage> createState() => _CfgEditPageState();
}

class _CfgEditPageState extends State<CfgEditPage> {
  late final CodeLineEditingController _configController;
  late final AppProvider _appProvider;

  @override
  void initState() {
    super.initState();
    appLogger.logger.i("Showing generator config edit page with ${widget.initialText.length} characters");
    _configController = CodeLineEditingController.fromText(widget.initialText);
    _appProvider = context.read<AppProvider>();
  }

  @override
  void dispose() {
    _configController.dispose();
    super.dispose();
  }

  void _formatJSON() {
    appLogger.logger.i("Formatting generator config JSON");
    final (code, json) = utils.formatJSON(_configController.text);
    if (code == ErrorCode.success) {
      setState(() => _configController.text = json);
    } else {
      appLogger.logger.e("Formatting failed: ${code.code}");
      ui.showSnackBarQuick(code.generic, context);
    }
  }

  void _showDoc(DocItems item) {
    appLogger.logger.i("Showing doc ${item.name}");
    Navigator.of(context).pop();
    Navigator.push(
      context,
      ui.switchRoute(
        _appProvider.currentNavMode, builder: (context) => DocViewPage(title: item.displayName, docItem: item)
      )
    );
  }

  void _showHelp() {
    ui.showAlertDialogQuick(
      title: "选择帮助",
      content: Column(
        children: [
          for (final (index, item) in editorHelpItems.indexed) styled.buildListTile(
            title: item.displayName,
            isFirst: index == 0,
            isLast: index == editorHelpItems.length - 1,
            onTapped: () => _showDoc(item),
            context: context
          )
        ],
      ),
      actionText: "取消",
      action: () => Navigator.pop(context),
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
        padding: styles.pagePaddingAll,
        child: Column(
          spacing: styles.layoutSpacing,
          children: [
            Expanded(child: styled.buildJsonEditor(controller: _configController, context: context)),
            Row(
              spacing: styles.layoutSpacing,
              children: [
                Expanded(
                  child: styled.buildTextButton(
                    onPressed: _formatJSON,
                    child: const Text("格式化"),
                    context: context,
                    highlighted: false
                  ),
                ),
                Expanded(
                  child: styled.buildTextButton(
                    onPressed: _showHelp,
                    child: const Text("帮助"),
                    context: context,
                    highlighted: false
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
