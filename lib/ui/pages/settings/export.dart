import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:re_editor/re_editor.dart';

class JsonExportPage extends StatelessWidget {
  final String jsonText;
  final String title;
  final String titleTag;
  const JsonExportPage({super.key, required this.jsonText, required this.title, required this.titleTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: styled.buildAppBar(
        title: title,
        titleTag: titleTag,
        actions: [
          IconButton(
            onPressed: () {
              appLogger.logger.i("Copying settings JSON");
              Clipboard.setData(ClipboardData(text: jsonText));
              ui.showSnackBarQuick("配置已复制到剪贴板", context);
            },
            icon: Icon(Icons.copy),
            style: styles.buttonStyle,
          )
        ],
        context: context
      ),
      body: Padding(
        padding: styles.pagePadding,
        child: styled.buildJsonEditor(
          context: context,
          readOnly: true,
          controller: CodeLineEditingController.fromText(jsonText)
        ),
      ),
    );
  }
}