import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/modules/utils/utils.dart' as utils;
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;

/// 弹出主密码验证对话框，返回：验证结果为 [ErrorCode] 或 null（用户取消）
Future<ErrorCode?> verifyMasterPwd(BuildContext context, AppProvider appProvider) async {
  appLogger.logger.i("Requesting master password verification");
  final controller = TextEditingController();
  final result = await showDialog<ErrorCode>(
    useRootNavigator: false,
    context: context,
    builder: (dialogContext) => AlertDialog(
      scrollable: true,
      shape: styles.roundedBorder,
      title: const Text("验证主密码"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("生成密码前需要先验证主密码"),
          styles.spacingSizedBox,
          styled.buildTextField(
            context: dialogContext,
            controller: controller,
            label: "主密码",
            passwordMode: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          style: styles.buttonStyle,
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text("取消"),
        ),
        TextButton(
          style: styles.buttonStyle,
          onPressed: () {
            if (controller.text.isEmpty) {
              Navigator.pop(dialogContext, ErrorCode.emptyPwd);
            } else if (utils.toSHA256(controller.text) == appProvider.masterPwd) {
              Navigator.pop(dialogContext, ErrorCode.success);
            } else {
              Navigator.pop(dialogContext, ErrorCode.wrongPwd);
            }
          },
          child: const Text("确定"),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}

/// 验证主密码，未通过或取消时返回 false；密码错误时给出提示
Future<bool> ensureMasterPwdVerified(BuildContext context, AppProvider appProvider) async {
  if (appProvider.masterPwd.isEmpty) return true;
  final result = await verifyMasterPwd(context, appProvider);
  if (result == ErrorCode.success) return true;
  if (result != null && context.mounted) {
    appLogger.logger.e(result.generic);
    ui.showSnackBarQuick(result.generic, context);
  }
  return false;
}