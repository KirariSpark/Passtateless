import 'dart:math';

import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:provider/provider.dart';

class ThemeSettingsPage extends StatelessWidget {
  /// 有AppBar时，是否要使用Hero动画
  final bool useHero;
  /// 是否要包含AppBar
  final bool hasAppBar;
  /// 是否有内边距
  final bool hasPadding;
  const ThemeSettingsPage({super.key, required this.useHero, this.hasAppBar = true, this.hasPadding = true});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    return Scaffold(
      appBar: hasAppBar
        ? styled.buildAppBar(title: "主题", context: context, titleTag: useHero ? "settings/themes" : null)
        : null,
      body: Container(
        alignment: Alignment.topCenter,
        child: Container(
          padding: hasPadding ? styles.pagePadding : EdgeInsets.zero,
          constraints: styles.tileWidthConstraint,
          child: SingleChildScrollView(
            child: RadioGroup(
              groupValue: appProvider.currentColor,
              onChanged: (value) async {
                Provider.of<AppProvider>(context, listen: false).color = value ?? AvailableColors.teal;
                appLogger.logger.i("Theme changed to ${value?.name}");
                var res = await Provider.of<AppProvider>(context, listen: false).saveConfig();
                if (res != ErrorCode.success && context.mounted) {
                  appLogger.logger.e("Can not save config: $e}");
                  ui.showSnackBarQuick(res.generic, context);
                } else {
                  appLogger.logger.i("Changes in settings saved");
                }
              },
              child: Column(
                children: [
                  for (final (index, item) in AvailableColors.values.indexed) RadioListTile(
                    value: item,
                    shape: RoundedRectangleBorder(
                      borderRadius: ui.calcRadius(isFirst: index == 0, isLast: index == AvailableColors.values.length - 1)
                    ),
                    title: Container(
                      constraints: BoxConstraints(minHeight: 50),
                      decoration: BoxDecoration(borderRadius: styles.borderRadius),
                      clipBehavior: Clip.antiAlias,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              color: ColorScheme.fromSeed(seedColor: item.color, brightness: Brightness.dark).primary,
                              constraints: BoxConstraints(minHeight: 50),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: ColorScheme.fromSeed(seedColor: item.color, brightness: Brightness.dark).secondary,
                              constraints: BoxConstraints(minHeight: 50),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: ColorScheme.fromSeed(seedColor: item.color, brightness: Brightness.dark).tertiary,
                              constraints: BoxConstraints(minHeight: 50)
                            ),
                          )
                        ],
                      ),
                    ),
                    tileColor: ColorScheme.of(context).surfaceContainerLow,
                  ),
                ],
              )
            )
          )
        )
      )
    );
  }
}