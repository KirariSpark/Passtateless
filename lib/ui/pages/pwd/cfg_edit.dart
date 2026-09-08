import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
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

  @override
  void initState() {
    super.initState();
    appLogger.logger.i("Showing generator config edit page with ${widget.initialText.length} characters");
    _configController = CodeLineEditingController.fromText(widget.initialText);
  }

  @override
  void dispose() {
    _configController.dispose();
    super.dispose();
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
        child: styled.buildDslEditor(controller: _configController, context: context),
      ),
    );
  }
}
