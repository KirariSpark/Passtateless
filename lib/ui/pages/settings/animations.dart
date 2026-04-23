import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;

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
  double currentDilation = AnimationDurations.normal.dilation;

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
                        groupValue: NavigatorMode.material,
                        onChanged: (_) {
                          ui.showSnackBarQuick("Coming s∞n", context);
                          Navigator.of(context, rootNavigator: true).pop();
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
                          groupValue: currentDilation,
                          onChanged: (value) {
                            timeDilation = value ?? AnimationDurations.normal.dilation;
                            setState(() {
                              currentDilation = value ?? AnimationDurations.normal.dilation;
                            });
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          child: Column(
                            children: [
                              for (var item in AnimationDurations.values) RadioListTile(
                                value: item.dilation,
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