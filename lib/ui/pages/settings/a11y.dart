import 'package:flutter/material.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;

class A11ySettingsPage extends StatelessWidget {
  /// 有AppBar时，是否要使用Hero动画
  final bool useHero;
  /// 是否要包含AppBar
  final bool hasAppBar;
  /// 是否有内边距
  final bool hasPadding;
  const A11ySettingsPage({super.key, required this.useHero, this.hasAppBar = true, this.hasPadding = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hasAppBar
        ? styled.buildAppBar(title: "可访问性", titleTag: useHero ? "a11y" : null, context: context)
        : null,
      body: Container(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: styles.tileWidthConstraint,
          padding: hasPadding ? styles.pagePaddingAll : null,
          child: SingleChildScrollView(
            child: Column(
              children: [
                styled.buildListTile(
                  title: "字体",
                  leading: Icons.text_format,
                  trailing: Icon(Icons.arrow_forward),
                  isFirst: true,
                  onTapped: () {},
                  context: context
                ),
                styled.buildListTile(
                  title: "对比度",
                  leading: Icons.contrast,
                  trailing: Icon(Icons.arrow_drop_down),
                  isLast: true,
                  onTapped: () {},
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