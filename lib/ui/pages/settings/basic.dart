import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/ui/pages/settings/about.dart';
import 'package:passtateless/ui/pages/settings/advanced.dart';
import 'package:passtateless/ui/pages/settings/a11y.dart';
import 'package:passtateless/ui/pages/settings/change_master.dart';
import 'package:passtateless/ui/widgets/adaptive_view.dart';
import 'package:passtateless/ui/pages/settings/customize.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:provider/provider.dart';

// 基础设置页面
class BasicSettingsPage extends StatefulWidget {
  const BasicSettingsPage({super.key});

  @override
  State<BasicSettingsPage> createState() => _BasicSettingsPageState();
}

class _BasicSettingsPageState extends State<BasicSettingsPage> {
  final List<_SettingItem> _settingItems = const [
    _SettingItem(
      tag: ("basic", "customize"),
      icon: Icons.color_lens_outlined,
      title: "个性化",
    ),
    _SettingItem(
      tag: ("basic", "a11y"),
      icon: Icons.accessibility_new,
      title: "可访问性",
    ),
    _SettingItem(
      tag: ("basic", "advanced"), 
      icon: Icons.code, 
      title: "高级设置"
    ),
    _SettingItem(
      tag: ("basic", "about"),
      icon: Icons.info_outlined,
      title: "关于",
      isLast: true,
    ),
  ];
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

  Widget _buildPage((String, String) tag, bool isWide) {
    if (tag == Pages.changeMaster.id) {
      return MasterPwdPage(useHero: !isWide, hasPadding: !isWide, hasAppBar: !isWide);
    }

    switch (tag) {
      case ("basic", "customize"):
        return CustomizeSettingsPage(
          useHero: !isWide,
          key: ValueKey(tag.$2),
          hasAppBar: !isWide,
          hasPadding: !isWide,
        );
      case ("basic", "advanced"):
        return AdvancedSettingsPage(
          key: ValueKey(tag.$2),
          useHero: !isWide,
          hasAppBar: !isWide,
          hasPadding: !isWide,
        );
      case ("basic", "a11y"):
        return A11ySettingsPage(
          key: ValueKey(tag.$2),
          useHero: !isWide,
          hasAppBar: !isWide,
          hasPadding: !isWide,
        );
      case ("basic", "about"):
        return AboutPage(
          useHero: !isWide,
          key: ValueKey(tag.$2),
          hasAppBar: !isWide,
          hasPadding: !isWide,
        );
      default:
        return styled.buildPlaceHolder(text: "未选择项目", context: context);
    }
  }

  Widget _buildSettingItems(
    BuildContext context,
    bool isWide,
    void Function((String, String)) navigateTo,
    bool Function((String, String)) isSelected,
  ) {
    return ConstrainedBox(
      constraints: isWide ? styles.tileWidthConstraintSmall : styles.tileWidthConstraint,
      child: SingleChildScrollView(
        child: Column(
          children: [
            styled.buildListTile(
              title: "更改主密码",
              titleTag: HeroTags.changeMaster.tag,
              leading: Icons.key,
              trailing: Icon(Icons.arrow_forward),
              isFirst: true,
              onTapped: () => navigateTo(Pages.changeMaster.id),
              context: context,
            ),
            styled.buildListTile(
              title: "提醒我更改主密码",
              subtitle: "当前：${appProvider.remindMe.displayName}",
              leading: Icons.schedule,
              trailing: Icon(Icons.arrow_drop_down),
              isLast: true,
              onTapped: () => ui.showBottomSheetQuick(
                context: context, 
                title: "在选择的天数后提醒你", 
                children: [
                  RadioGroup(
                    groupValue: appProvider.remindMe,
                    onChanged: (value) => _changeRemindDays(value!, context),
                    child: Column(
                      children: [
                        for (final (index, item) in RemindDays.values.indexed) RadioListTile(
                          value: item,
                          title: Text(item.displayName),
                          tileColor: ColorScheme.of(context).surfaceContainerLow,
                          shape: RoundedRectangleBorder(
                            borderRadius: ui.calcRadius(
                              isFirst: index == 0, isLast: index == RemindDays.values.length - 1
                            ),
                          )
                        )
                      ],
                    ),
                  ),
                ]
              ),
              context: context
            ),
            styles.spacingSizedBox,
            ..._settingItems.map((item) {
              final selected = isSelected(item.tag);
              return styled.buildListTile(
                active: selected,
                isFirst: item.isFirst,
                isLast: item.isLast,
                leading: item.icon,
                title: item.title,
                titleTag: isWide ? null : item.tag.$2,
                trailing: const Icon(Icons.arrow_forward),
                onTapped: () => navigateTo(item.tag),
                context: context,
              );
            })
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

// 设置项数据类
class _SettingItem {
  final (String, String) tag;
  final IconData icon;
  final String title;
  final bool isFirst;
  final bool isLast;

  const _SettingItem({
    required this.tag,
    required this.icon,
    required this.title,
    this.isFirst = false,
    this.isLast = false,
  });
}
