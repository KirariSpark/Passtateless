import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final String initialText;

  const CfgEditPage({super.key, required this.initialText});

  @override
  State<CfgEditPage> createState() => _CfgEditPageState();
}

class _CfgEditPageState extends State<CfgEditPage> {
  late final CodeLineEditingController _configController;
  DocItems? _currentLoadingItem;

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

  void _showHelp(AppProvider provider) {
    ui.showAlertDialogQuick(
      title: "选择帮助",
      content: ConstrainedBox(
        constraints: styles.tileWidthConstraint,
        child: Column(
          children: [
            for (final (index, item) in editorHelpItems.indexed) styled.buildListTile(
              enabled: _currentLoadingItem == null,
              title: item.displayName,
              isFirst: index == 0,
              isLast: index == editorHelpItems.length - 1,
              onTapped: () async {
                appLogger.logger.i("Loading doc ${item.name}");
                setState(() => _currentLoadingItem = item);
                final res = await rootBundle.loadString(item.path);
                setState(() => _currentLoadingItem = null);
                if (mounted) {
                  Navigator.of(context, rootNavigator: true).pop();
                  Navigator.push(
                    context,
                    ui.switchRoute(
                      provider.currentNavMode,
                      builder: (context) => DocViewPage(title: item.displayName, docText: res)
                    )
                  );
                }
              },
              context: context
            )
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
    final appProvider = Provider.of<AppProvider>(context, listen: false);
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
        padding: styles.pagePadding,
        child: Column(
          children: [
            Expanded(child: styled.buildJsonEditor(controller: _configController, context: context)),
            styles.spacingSizedBox,
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
                    onPressed: () => _showHelp(appProvider),
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
