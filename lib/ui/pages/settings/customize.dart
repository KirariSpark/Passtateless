import 'package:flutter/material.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/adaptive_view.dart';
import 'package:passtateless/ui/pages/settings/themes.dart';
import 'package:passtateless/ui/widgets/styled.dart' as styled;

class CustomizeSettingsPage extends StatelessWidget {
  /// 有AppBar时，是否要使用Hero动画
  final bool useHero;
  /// 是否要包含AppBar
  final bool hasAppBar;
  /// 是否有内边距
  final bool hasPadding;
  const CustomizeSettingsPage({super.key, required this.useHero, this.hasAppBar = true, this.hasPadding = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hasAppBar
        ? styled.buildAppBar(title: "个性化", context: context, titleTag: useHero ? "customize" : null)
        : null,
      body: AdaptiveView(
        leftPaneBuilder: (
          BuildContext context,
          bool isWide,
          void Function((String, String)) onItemTapped,
          bool Function((String, String)) isSelected
        ) {
          return Container(
            padding: hasPadding ? styles.pagePadding : EdgeInsets.zero,
            constraints: isWide ? styles.tileWidthConstraintSmall : styles.tileWidthConstraint,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  styled.buildListTile(
                    leading: Icons.colorize,
                    title: "主题",
                    trailing: Icon(Icons.arrow_forward),
                    isFirst: true,
                    onTapped: () => onItemTapped(("customize", "theme")),
                    active: isSelected(("customize", "theme")),
                    context: context
                  ),
                  styled.buildListTile(
                    leading: Icons.animation,
                    title: "动画",
                    trailing: Icon(Icons.arrow_forward),
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
            case ("customize", "theme"):
              return ThemeSettingsPage(useHero: !isWide, hasAppBar: !isWide, hasPadding: !isWide);
            default:
              return SizedBox.shrink();
          }
        },
        widthThreshold: styles.tileWidthConstraint.maxWidth + styles.tileWidthConstraintSmall.maxWidth + styles.layoutSpacing,
      )
    );
  }
}