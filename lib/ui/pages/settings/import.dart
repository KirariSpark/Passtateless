import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:provider/provider.dart';
import 'package:re_editor/re_editor.dart';

class SettingsImportPage extends StatelessWidget {
  final void Function() onImport;
  final CodeLineEditingController controller;
  const SettingsImportPage({super.key, required this.onImport, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: styled.buildAppBar(
        title: "导入设置",
        titleTag: "setting_import",
        exitIcon: Icons.close,
        actions: [
          IconButton(
            onPressed: () {
              appLogger.logger.i("Importing setting");
              final stat = Provider.of<AppProvider>(
                context, listen: false
              ).restoreConfigFromText(controller.text, fallback: false);
              if (stat == ErrorCode.success) {
                ui.showSnackBarQuick("导入成功", context);
              } else {
                appLogger.logger.e("Can not import settings: ${stat.code}");
                ui.showSnackBarQuick(stat.generic, context);
              }
            },
            icon: Icon(Icons.check)
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