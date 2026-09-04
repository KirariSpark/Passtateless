import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/ui/pages/settings/animations.dart';
import 'package:passtateless/ui/pages/settings/contrast.dart';
import 'package:passtateless/ui/pages/settings/themes.dart';
import 'package:passtateless/ui/pages/settings/about.dart';
import 'package:passtateless/ui/pages/settings/advanced.dart';
import 'package:passtateless/ui/pages/settings/change_master.dart';
import 'package:passtateless/ui/widgets/adaptive_view.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/ui/widgets/styled_list_tile.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
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

  Future<void> _changeRemindDays(RemindDays value, BuildContext context) async {
    appProvider.remindMe = value;
    appLogger.logger.i("Remind settings updated to ${value.name}");
    await appProvider.saveConfig();
    if (context.mounted) {
      appLogger.logger.i("Changes in settings saved");
      Navigator.pop(context);
    }
  }

  Widget _buildPage((String, String) id, bool isWide) {
    if (id == Pages.changeMaster.id) {
      return MasterPwdPage(
        key: ValueKey(id),
        useHero: !isWide,
        hasPadding: !isWide,
        hasAppBar: !isWide,
      );
    }
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
              title: "更改主密码",
              leadingIcon: Icons.key,
              trailing: Icon(Icons.arrow_forward),
              isFirst: true,
              onTap: () => navigateTo(Pages.changeMaster.id),
              highlighted: isSelected(Pages.changeMaster.id),
            ),
            StyledListTileSimple(
              title: "提醒我更改主密码",
              subtitle: "当前：${context.watch<AppProvider>().remindMe.displayName}",
              leadingIcon: Icons.schedule,
              trailing: Icon(Icons.arrow_drop_down),
              isLast: true,
              onTap: () => ui.showBottomSheetQuick(
                context: context,
                title: "在选择的天数后提醒你",
                children: [
                  RadioGroup(
                    groupValue: appProvider.remindMe,
                    onChanged: (value) => _changeRemindDays(value!, context),
                    child: Column(
                      children: [
                        for (final (index, item) in RemindDays.values.indexed)
                          RadioListTile(
                            value: item,
                            title: Text(item.displayName),
                            tileColor: ColorScheme.of(
                              context,
                            ).surfaceContainerLow,
                            shape: RoundedRectangleBorder(
                              borderRadius: ui.calcRadius(
                                isFirst: index == 0,
                                isLast: index == RemindDays.values.length - 1,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            styles.spacingSizedBox,
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
      navMode: appProvider.currentNavMode,
      widthThreshold:
          styles.tileWidthConstraint.maxWidth +
          styles.tileWidthConstraintSmall.maxWidth +
          styles.layoutSpacing * 2,
    );
  }
}