import 'package:flutter/material.dart';
import 'package:passtateless/ui/pages/settings/about.dart';
import 'package:passtateless/ui/pages/settings/master.dart';
import 'package:passtateless/ui/pages/settings/customize.dart';
import 'package:passtateless/ui/pages/settings/advanced.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;

// 基础设置页面
class BasicSettingsPage extends StatefulWidget {
  const BasicSettingsPage({super.key});

  @override
  State<BasicSettingsPage> createState() => _BasicSettingsPageState();
}

class _BasicSettingsPageState extends State<BasicSettingsPage> {
  // (命名空间, 值) 的 Record
  (String, String)? _selectedTag;

  // 右侧栏专属的 Navigator Key
  final GlobalKey<NavigatorState> _settingsRightNavigatorKey = GlobalKey<NavigatorState>();

  // 设置项列表
  final List<_SettingItem> _settingItems = const [
    _SettingItem(tag: ("basic", "masterPwd"), icon: Icons.key, title: "主密码", isFirst: true),
    _SettingItem(tag: ("basic", "customize"), icon: Icons.color_lens_outlined, title: "个性化"),
    _SettingItem(tag: ("basic", "advanced"), icon: Icons.developer_mode, title: "高级设置"),
    _SettingItem(tag: ("basic", "about"), icon: Icons.info_outlined, title: "关于", isLast: true),
  ];

  Widget _buildPage((String, String) tag, bool isWide) {
    switch (tag) {
      case ("basic", "masterPwd"):
        return MasterPwdSettingsPage(useHero: !isWide, key: ValueKey(tag.$2));
      case ("basic", "customize"):
        return CustomizeSettingsPage(useHero: !isWide, key: ValueKey(tag.$2));
      case ("basic", "advanced"):
        return AdvancedSettingsPage(key: ValueKey(tag.$2));
      case ("basic", "about"):
        return AboutPage(useHero: !isWide, key: ValueKey(tag.$2));
      default:
        return const SizedBox.shrink();
    }
  }

  void _onItemTapped((String, String) tag, bool isWide) {
    // 只有宽屏下需要更新高亮状态
    // 同时也是为了避免窄屏下更新状态，触发AnimatedSwitcher，导致同时有两个Hero（加上新页面就是三个）在场的问题
    if (isWide) {
      // 更新左侧高亮状态
      setState(() {
        _selectedTag = tag;
      });

      // 宽屏：在右侧嵌套 Navigator 中清空栈并推入新页面
      _settingsRightNavigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => _buildPage(tag, isWide)), (route) => false,
      );
    } else {
      // 窄屏：常规的根 Navigator 跳转
      Navigator.push(context, MaterialPageRoute(builder: (_) => _buildPage(tag, isWide)));
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
          children: _buildLeftContent(context, false),
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
          // 左侧菜单列表
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _buildLeftContent(context, true),
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          // 右侧内容区
          Expanded(
            child: _buildRightContent(context),
          ),
        ],
      ),
    );
  }

  // 构建第二栏(右侧)内容
  Widget _buildRightContent(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 200) {
          // 页面过窄时，什么都不显示
          return styled.buildPlaceHolder(text: "", context: context);
        } else if (_selectedTag != null) {
          // 有选中项时显示对应页面
          return Navigator(
            observers: [HeroController()],
            key: _settingsRightNavigatorKey,
            onGenerateRoute: (_) {
              return MaterialPageRoute(
                builder: (context) => _buildPage(_selectedTag!, true),
              );
            },
          );
        } else {
          // 没有选择任何项目
          return Navigator(
            observers: [HeroController()],
            key: _settingsRightNavigatorKey,
            onGenerateRoute: (_) {
              return MaterialPageRoute(
                builder: (context) => styled.buildPlaceHolder(text: "未选择设置项", context: context),
              );
            },
          );
        }
      },
    );
  }

  // 构建设置项列表(左侧)
  List<Widget> _buildLeftContent(BuildContext context, bool isWide) {
    final List<Widget> tiles = [];
    for (var item in _settingItems) {
      final isSelected = _selectedTag == item.tag && isWide;
      final alpha = isSelected ? styles.alphaOpaque : styles.alphaAlmostTransparent;

      Widget tile = AnimatedSwitcher(
        duration: const Duration(milliseconds: 100),
        child: ConstrainedBox(
          key: isSelected ? const ValueKey("selected") : const ValueKey("notSelected"),
          constraints: isWide ? styles.tileWidthConstraintSmall : styles.tileWidthConstraint,
          child: styled.buildListTile(
            alpha: alpha,
            isFirst: item.isFirst,
            isLast: item.isLast,
            leading: item.icon,
            title: item.title,
            // 窄屏下传具体名称标签，宽屏不传以避免 Hero 错误
            titleTag: isWide ? null : item.tag.$2,
            trailing: const Icon(Icons.arrow_forward),
            onTapped: () => _onItemTapped(item.tag, isWide),
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
          child: isWide ? _buildWideLayout(context, isWide) : _buildNarrowLayout(context),
        );
      },
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
