import 'package:flutter/material.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;

class AnimationSettingsPage extends StatelessWidget {
  /// 有AppBar时，是否要使用Hero动画
  final bool useHero;
  /// 是否要包含AppBar
  final bool hasAppBar;
  /// 是否有内边距
  final bool hasPadding;
  const AnimationSettingsPage({super.key, required this.useHero, this.hasAppBar = true, this.hasPadding = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hasAppBar
        ? styled.buildAppBar(title: "动画", context: context, titleTag: useHero ? "settings/animations" : null)
        : null,
      body: Container(
        alignment: Alignment.topCenter,
        child: Container(
          padding: hasPadding ? styles.pagePadding : EdgeInsets.zero,
          constraints: styles.tileWidthConstraint,
          child: SingleChildScrollView(
            child: Column(
              children: [
                styled.buildListTile(
                  title: "动画风格",
                  trailing: Icon(Icons.arrow_drop_down),
                  isFirst: true,
                  context: context
                ),
                styled.buildListTile(
                  title: "动画速度",
                  trailing: Icon(Icons.arrow_drop_down),
                  isLast: true,
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