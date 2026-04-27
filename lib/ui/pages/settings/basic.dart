import 'package:flutter/material.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/ui/pages/settings/about.dart';
import 'package:passtateless/ui/pages/settings/master.dart';
import 'package:passtateless/ui/pages/settings/advanced.dart';
import 'package:passtateless/ui/pages/settings/a11y.dart';
import 'package:passtateless/ui/widgets/adaptive_view.dart';
import 'package:passtateless/ui/pages/settings/customize.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:provider/provider.dart';

// 基础设置页面
class BasicSettingsPage extends StatefulWidget {
  const BasicSettingsPage({super.key});

  @override
  State<BasicSettingsPage> createState() => _BasicSettingsPageState();
}

class _BasicSettingsPageState extends State<BasicSettingsPage> {
  // 设置项列表
  final List<_SettingItem> _settingItems = const [
    _SettingItem(tag: ("basic", "masterPwd"), icon: Icons.key, title: "主密码", isFirst: true),
    _SettingItem(tag: ("basic", "customize"), icon: Icons.color_lens_outlined, title: "个性化"),
    _SettingItem(tag: ("basic", "a11y"), icon: Icons.accessibility_new, title: "可访问性"),
    _SettingItem(tag: ("basic", "advanced"), icon: Icons.code, title: "高级设置"),
    _SettingItem(tag: ("basic", "about"), icon: Icons.info_outlined, title: "关于", isLast: true),
  ];

  Widget _buildPage((String, String) tag, bool isWide) {
    switch (tag) {
      case ("basic", "masterPwd"):
        return MasterPwdSettingsPage(useHero: !isWide, key: ValueKey(tag.$2), hasAppBar: !isWide, hasPadding: !isWide);
      case ("basic", "customize"):
        return CustomizeSettingsPage(useHero: !isWide, key: ValueKey(tag.$2), hasAppBar: !isWide, hasPadding: !isWide);
      case ("basic", "advanced"):
        return AdvancedSettingsPage(key: ValueKey(tag.$2), useHero: !isWide, hasAppBar: !isWide, hasPadding: !isWide);
      case ("basic", "a11y"):
        return A11ySettingsPage(key: ValueKey(tag.$2), useHero: !isWide, hasAppBar: !isWide, hasPadding: !isWide);
      case ("basic", "about"):
        return AboutPage(useHero: !isWide, key: ValueKey(tag.$2), hasAppBar: !isWide, hasPadding: !isWide);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveView(
      placeholderText: "未选择设置项",
      pageBuilder: _buildPage,
      leftPaneBuilder: (context, isWide, onItemTapped, isSelected) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _settingItems.map((item) {
              final selected = isSelected(item.tag);
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 100),
                child: ConstrainedBox(
                  key: selected ? const ValueKey("selected") : const ValueKey("notSelected"),
                  constraints: isWide ? styles.tileWidthConstraintSmall : styles.tileWidthConstraint,
                  child: styled.buildListTile(
                    active: selected,
                    isFirst: item.isFirst,
                    isLast: item.isLast,
                    leading: item.icon,
                    title: item.title,
                    titleTag: isWide ? null : item.tag.$2,
                    trailing: const Icon(Icons.arrow_forward),
                    onTapped: () => onItemTapped(item.tag),
                    context: context,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
      padding: styles.pagePaddingAll,
      navMode: context.watch<AppProvider>().currentNavMode,
      widthThreshold: styles.tileWidthConstraint.maxWidth + styles.tileWidthConstraintSmall.maxWidth +
          styles.layoutSpacing,
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
