import 'package:flutter/material.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:re_editor/re_editor.dart';

class SettingsImportPage extends StatelessWidget {
  final String titleTag;
  final String title;
  final void Function() onImport;
  final CodeLineEditingController controller;
  const SettingsImportPage({super.key, required this.onImport, required this.controller, required this.titleTag, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: styled.buildAppBar(
        title: title,
        titleTag: titleTag,
        exitIcon: Icons.close,
        actions: [
          IconButton(
            onPressed: onImport,
            icon: Icon(Icons.check),
            style: styles.buttonStyle,
          )
        ],
        context: context
      ),
      body: Padding(
        padding: styles.pagePadding,
        child: styled.buildJsonEditor(
          context: context,
          controller: controller
        ),
      ),
    );
  }
}