import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/ui/pages/settings/animations.dart';
import 'package:passtateless/ui/pages/settings/contrast.dart';
import 'package:passtateless/ui/pages/settings/themes.dart';
import 'package:passtateless/ui/pages/settings/about.dart';
import 'package:passtateless/ui/pages/settings/advanced.dart';
import 'package:passtateless/ui/widgets/adaptive_view.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/ui/widgets/styled_list_tile.dart';
import 'package:provider/provider.dart';

// 基础设置页面
class BasicSettingsPage extends StatefulWidget {
  const BasicSettingsPage({super.key});

  @override
  State<BasicSettingsPage> createState() => _BasicSettingsPageState();
}

class _BasicSettingsPageState extends State<BasicSettingsPage> {
  late final AppProvider appProvider;

  @override
  void initState() {
    super.initState();
    appProvider = context.read<AppProvider>();
  }

  Widget _buildPage((String, String) id, bool isWide) {
    if (id == Pages.themeSettings.id) {
      return ThemeSettingsPage(
        key: ValueKey(id),
        useHero: !isWide,
        hasAppBar: !isWide,
        hasPadding: !isWide,
      );
    }
    if (id == Pages.animationSettings.id) {
      return AnimationSettingsPage(
        key: ValueKey(id),
        useHero: !isWide,
        hasAppBar: !isWide,
        hasPadding: !isWide,
      );
    }
    if (id == Pages.contrastnessSettings.id) {
      return ContrastSettingsPage(
        key: ValueKey(id),
        useHero: !isWide,
        hasAppBar: !isWide,
        hasPadding: !isWide,
      );
    }
    if (id == Pages.advancedSettings.id) {
      return AdvancedSettingsPage(
        key: ValueKey(id.$2),
        useHero: !isWide,
        hasAppBar: !isWide,
        hasPadding: !isWide,
      );
    }
    if (id == Pages.about.id) {
      return AboutPage(
        key: ValueKey(id),
        hasAppBar: !isWide,
        hasPadding: !isWide,
      );
    }
    return styled.buildPlaceHolder(text: "未选择项目", context: context);
  }

  Widget _buildSettingItems(
    BuildContext context,
    bool isWide,
    void Function((String, String)) navigateTo,
    bool Function((String, String)) isSelected,
  ) {
    return ConstrainedBox(
      constraints: isWide
          ? styles.tileWidthConstraintSmall
          : styles.tileWidthConstraint,
      child: SingleChildScrollView(
        child: Column(
          children: [
            StyledListTileSimple(
              title: "主题",
              leadingIcon: Icons.color_lens_outlined,
              trailing: Icon(Icons.arrow_forward),
              onTap: () => navigateTo(Pages.themeSettings.id),
              isFirst: true,
              highlighted: isSelected(Pages.themeSettings.id),
            ),
            StyledListTileSimple(
              title: "动画",
              leadingIcon: Icons.animation,
              trailing: Icon(Icons.arrow_forward),
              onTap: () => navigateTo(Pages.animationSettings.id),
              highlighted: isSelected(Pages.animationSettings.id),
            ),
            StyledListTileSimple(
              title: "对比度",
              leadingIcon: Icons.contrast,
              trailing: Icon(Icons.arrow_forward),
              onTap: () => navigateTo(Pages.contrastnessSettings.id),
              isLast: true,
              highlighted: isSelected(Pages.contrastnessSettings.id),
            ),
            styles.spacingSizedBox,
            StyledListTileSimple(
              title: "高级设置",
              leadingIcon: Icons.code,
              trailing: Icon(Icons.arrow_forward),
              onTap: () => navigateTo(Pages.advancedSettings.id),
              isFirst: true,
              highlighted: isSelected(Pages.advancedSettings.id),
            ),
            StyledListTileSimple(
              title: "关于",
              leadingIcon: Icons.info_outline,
              trailing: Icon(Icons.arrow_forward),
              onTap: () => navigateTo(Pages.about.id),
              isLast: true,
              highlighted: isSelected(Pages.about.id),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveView(
      placeholderText: "未选择设置项",
      pageBuilder: _buildPage,
      leftPaneBuilder: _buildSettingItems,
      padding: styles.pagePaddingAll,
      widthThreshold:
          styles.tileWidthConstraint.maxWidth +
          styles.tileWidthConstraintSmall.maxWidth +
          styles.layoutSpacing * 2,
    );
  }
}