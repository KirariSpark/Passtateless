import 'package:flutter/material.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/ui/pages/settings/contrast.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/adaptive_view.dart';
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:provider/provider.dart';

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
      body: AdaptiveView(
        leftPaneBuilder: (
          BuildContext context,
          bool isWide,
          void Function((String, String)) onItemTapped,
          bool Function((String, String)) isSelected
        ) {
          return Container(
            constraints: isWide ? styles.tileWidthConstraintSmall : styles.tileWidthConstraint,
            padding: hasPadding ? styles.pagePadding : null,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  styled.buildListTile(
                    title: "对比度",
                    leading: Icons.contrast,
                    trailing: Icon(Icons.arrow_forward),
                    isFirst: true,
                    titleTag: isWide ? null : "contrast",
                    active: isSelected(("a11y", "contrast")),
                    onTapped: () => onItemTapped(("a11y", "contrast")),
                    context: context
                  ),
                  styled.buildListTile(
                    title: "TalkBack",
                    subtitle: "TalkBack 将跟随系统设置",
                    leading: Icons.volume_up_outlined,
                    context: context
                  ),
                  styled.buildListTile(
                    title: "字体大小",
                    subtitle: "字体大小将跟随系统设置",
                    leading: Icons.text_format,
                    isLast: true,
                    context: context
                  )
                ],
              ),
            ),
          );
        },
        pageBuilder: ((String, String) tag, bool isWide) {
          switch (tag) {
            case (("a11y", "contrast")):
              return ContrastSettingsPage(useHero: !isWide, hasAppBar: !isWide, hasPadding: !isWide);
            default:
              return SizedBox.shrink();
          }
        },
        navMode: context.watch<AppProvider>().currentNavMode,
        widthThreshold: styles.tileWidthConstraint.maxWidth + styles.tileWidthConstraintSmall.maxWidth +
            styles.layoutSpacing,
      ),
    );
  }
}