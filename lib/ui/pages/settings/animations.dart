import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:provider/provider.dart';

class AnimationSettingsPage extends StatefulWidget {
  /// 有AppBar时，是否要使用Hero动画
  final bool useHero;
  /// 是否要包含AppBar
  final bool hasAppBar;
  /// 是否有内边距
  final bool hasPadding;
  const AnimationSettingsPage({super.key, required this.useHero, this.hasAppBar = true, this.hasPadding = true});

  @override
  State<AnimationSettingsPage> createState() => _AnimationSettingsPageState();
}

class _AnimationSettingsPageState extends State<AnimationSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.hasAppBar
        ? styled.buildAppBar(title: "动画", context: context, titleTag: widget.useHero ? "settings/animations" : null)
        : null,
      body: Container(
        alignment: Alignment.topCenter,
        child: Container(
          padding: widget.hasPadding ? styles.pagePadding : EdgeInsets.zero,
          constraints: styles.tileWidthConstraint,
          child: SingleChildScrollView(
            child: Column(
              children: [
                styled.buildListTile(
                  title: "动画风格",
                  trailing: Icon(Icons.arrow_drop_down),
                  isFirst: true,
                  onTapped: () {
                    ui.showAlertDialogQuick(
                      context: context,
                      title: "动画风格",
                      content: RadioGroup(
                        groupValue: Provider.of<AppProvider>(context, listen: false).currentNavMode,
                        onChanged: (value) async {
                          Provider.of<AppProvider>(context, listen: false).currentNavMode = value!;
                          final stat = await Provider.of<AppProvider>(context, listen: false).saveConfig();
                          if (stat == ErrorCode.success && context.mounted) {
                            Navigator.of(context, rootNavigator: true).pop();
                          } else if (context.mounted) {
                            Navigator.of(context, rootNavigator: true).pop();
                            ui.showSnackBarQuick(stat.generic, context);
                          }
                        },
                        child: Column(
                          children: [
                            for (var item in NavigatorMode.values) RadioListTile(
                              value: item,
                              title: Text(item.displayName),
                              shape: styles.roundedBorder,
                            )
                          ],
                        )
                      ),
                      action: () => Navigator.of(context, rootNavigator: true).pop(),
                      actionText: '取消',
                    );
                  },
                  context: context
                ),
                styled.buildListTile(
                  title: "动画速度",
                  trailing: Icon(Icons.arrow_drop_down),
                  isLast: true,
                  onTapped: () {
                      ui.showAlertDialogQuick(
                        context: context,
                        title: "动画速度",
                        content: RadioGroup(
                          groupValue: Provider.of<AppProvider>(context, listen: false).currentDilation,
                          onChanged: (value) {
                            Provider.of<AppProvider>(context, listen: false).currentDilation =
                                value ?? AnimationDilation.normal;
                            Provider.of<AppProvider>(context, listen: false).saveConfig();
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          child: Column(
                            children: [
                              for (var item in AnimationDilation.values) RadioListTile(
                                value: item,
                                title: Text(item.displayName),
                                shape: styles.roundedBorder,
                              )
                            ],
                          )
                        ),
                        action: () => Navigator.of(context, rootNavigator: true).pop(),
                        actionText: '取消',
                      );
                    },
                  context: context
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}