import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:provider/provider.dart';

/// 移除数字、字母、特殊字符的三个开关
///
/// 选项状态存于 [PwdProvider]，全局共享
class RemovalCfg extends StatelessWidget {
  const RemovalCfg({super.key});

  @override
  Widget build(BuildContext context) {
    final pwdProvider = context.watch<PwdProvider>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SwitchListTile(
          value: pwdProvider.removeDigits,
          onChanged: (value) {
            pwdProvider.removeDigits = value;
            appLogger.logger.d("Current digit removal state: ${pwdProvider.removeDigits}");
          },
          title: const Text("移除数字"),
          shape: RoundedRectangleBorder(
            borderRadius: ui.calcRadius(isFirst: true),
          ),
          tileColor: ColorScheme.of(context).surfaceContainerLow,
        ),
        SwitchListTile(
          value: pwdProvider.removeAlpha,
          onChanged: (value) {
            pwdProvider.removeAlpha = value;
            appLogger.logger.d("Current alphabet removal state: ${pwdProvider.removeAlpha}");
          },
          title: const Text("移除字母"),
          tileColor: ColorScheme.of(context).surfaceContainerLow,
        ),
        SwitchListTile(
          value: pwdProvider.removeSp,
          onChanged: (value) {
            pwdProvider.removeSp = value;
            appLogger.logger.d("Current special char removal state: ${pwdProvider.removeSp}");
          },
          title: const Text("移除特殊字符"),
          shape: RoundedRectangleBorder(
            borderRadius: ui.calcRadius(isLast: true),
          ),
          tileColor: ColorScheme.of(context).surfaceContainerLow,
        ),
      ],
    );
  }
}
