import 'package:flutter/material.dart';
import 'package:passtateless/ui/pages/settings/about.dart';
import 'package:passtateless/ui/pages/settings/master.dart';
import 'package:passtateless/ui/pages/settings/customize.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;

// 高级设置页面
class AdvancedSettingsPage extends StatelessWidget {
  const AdvancedSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("高级设置")),
      body: Center(child: Placeholder()),
    );
  }
}

// 基础设置页面
class BasicSettingsPage extends StatefulWidget {
  const BasicSettingsPage({super.key});

  @override
  State<BasicSettingsPage> createState() => _BasicSettingsPageState();
}

class _BasicSettingsPageState extends State<BasicSettingsPage> {
  String? _selectedTag;

  // 设置项列表
  final List<_SettingItem> _settingItems = const [
    _SettingItem(tag: "masterPwd", icon: Icons.key, title: "主密码", isFirst: true),
    _SettingItem(tag: "customize", icon: Icons.color_lens_outlined, title: "个性化"),
    _SettingItem(tag: "advanced", icon: Icons.developer_mode, title: "高级设置"),
    _SettingItem(tag: "about", icon: Icons.info_outlined, title: "关于", isLast: true),
  ];

  Widget _buildPage(String tag, bool isWide) {
    switch (tag) {
      case "masterPwd":
        return MasterPwdSettingsPage(useHero: !isWide, key: ValueKey(tag),); // 宽屏下，两页面处于同一页，因此不应使用Hero
      case "customize":
        return CustomizeSettingsPage(useHero: !isWide, key: ValueKey(tag));
      case "advanced":
        return AdvancedSettingsPage(key: ValueKey(tag));
      case "about":
        return AboutPage(useHero: !isWide, key: ValueKey(tag));
      default:
        return const SizedBox.shrink();
    }
  }

  void _onItemTapped(_SettingItem item, bool isWide) {
    if (isWide) {
      setState(() {
        _selectedTag = item.tag;
      });
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => _buildPage(item.tag, isWide)));
    }
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Container(
      key: const ValueKey("narrow"),
      padding: styles.pagePaddingAll,
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _buildSettingTiles(context, false),
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, bool isWide) {
    return Container(
      key: const ValueKey("wide"),
      padding: styles.pagePaddingAll,
      child: Row(
        spacing: styles.layoutSpacing,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 设置项列表
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _buildSettingTiles(context, true),
            ),
          ),
          // 选中项的内容
          Expanded(
            child: Container(
              constraints: styles.tileWidthConstraint,
              child: _buildRightContent(context, isWide),
            ),
          ),
        ],
      ),
    );
  }

  // 构建第二栏(右侧)内容
  Widget _buildRightContent(BuildContext context, bool isWide) {
    Widget buildHint(String text) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: styles.borderRadius,
          color: ColorScheme.of(context).primaryContainer.withAlpha(styles.alphaAlmostTransparent),
        ),
        child: Center(
          child: Text(text),
        ),
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 200) { // 过窄时什么都不显示
          return buildHint("");
        } else if (_selectedTag == null) {
          return buildHint("未选择设置项");
        } else {
          return AnimatedSwitcher(
            switchOutCurve: Curves.easeOutCubic,
            switchInCurve: Curves.easeOutCubic,
            duration: Duration(milliseconds: 200),
            child: _buildPage(_selectedTag!, isWide)
          );
        }
      }
    );
  }

  // 构建设置项列表
  List<Widget> _buildSettingTiles(BuildContext context, bool isWide) {
    final List<Widget> tiles = [];
    final colorScheme = ColorScheme.of(context);

    for (int i = 0; i < _settingItems.length; i++) {
      final item = _settingItems[i];
      final isSelected = _selectedTag == item.tag;
      final alpha = isSelected && isWide ? styles.alphaOpaque : styles.alphaAlmostTransparent;

      // 构建 decoration
      BoxDecoration? decoration;
      if (item.isFirst) {
        decoration = BoxDecoration(
          borderRadius: BorderRadius.vertical(top: styles.radius),
          color: colorScheme.primaryContainer.withAlpha(alpha),
        );
      } else if (item.isLast) {
        decoration = BoxDecoration(
          borderRadius: BorderRadius.vertical(bottom: styles.radius),
          color: colorScheme.primaryContainer.withAlpha(alpha),
        );
      } else {
        decoration = BoxDecoration(
          color: colorScheme.primaryContainer.withAlpha(alpha),
        );
      }

      Widget tile = AnimatedSwitcher(
        duration: Duration(milliseconds: 100),
        child: Container(
          key: isSelected ? ValueKey("selected") : ValueKey("notSelected"),
          decoration: decoration,
          constraints: isWide ? styles.tileWidthConstraintSmall : styles.tileWidthConstraint,
          child: styled.buildListTile(
            isFirst: item.isFirst,
            isLast: item.isLast,
            leading: item.icon,
            title: item.title,
            titleTag: isWide ? null : item.tag,
            trailing: const Icon(Icons.arrow_forward),
            onTapped: () => _onItemTapped(item, isWide),
            context: context,
          ),
        ),
      );

      tiles.add(tile);
    }

    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > styles.tileWidthConstraint.maxWidth * 2 + styles.layoutSpacing;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 100),
          child: isWide ? _buildWideLayout(context, isWide) : _buildNarrowLayout(context)
        );
      },
    );
  }
}

// 设置项数据类
class _SettingItem {
  final String tag;
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
