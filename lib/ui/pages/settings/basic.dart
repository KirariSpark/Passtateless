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
  String? _selectedTag; // 仅用于控制左侧列表的高亮状态

  // 右侧栏专属的 Navigator Key
  final GlobalKey<NavigatorState> _rightNavigatorKey = GlobalKey<NavigatorState>();

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
        return MasterPwdSettingsPage(useHero: !isWide, key: ValueKey(tag));
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
    // 更新左侧高亮状态
    setState(() {
      _selectedTag = item.tag;
    });

    if (isWide) {
      // 宽屏：在右侧嵌套 Navigator 中清空栈并推入新页面
      // 这样无论右侧处于什么层级，点击左侧菜单都能完美“重置”为新的设置页
      _rightNavigatorKey.currentState?.pushAndRemoveUntil(
        _FadeRoute(builder: (_) => _buildPage(item.tag, isWide)), (route) => false
      );
    } else {
      // 窄屏：常规的根 Navigator 跳转
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
          // 左侧菜单列表
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _buildSettingTiles(context, true),
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
          return styled.buildPlaceHolder(text: "", context: context);
        } else {
          // 使用嵌套 Navigator - 用于让右侧内容不要把整个页面都跳转掉
          return Navigator(
            key: _rightNavigatorKey,
            // 初始路由显示占位符
            onGenerateRoute: (settings) {
              return _FadeRoute(
                builder: (context) => styled.buildPlaceHolder(text: "未选择设置项", context: context),
              );
            },
          );
        }
      }
    );
  }

  // 构建设置项列表
  List<Widget> _buildSettingTiles(BuildContext context, bool isWide) {
    final List<Widget> tiles = [];
    for (int i = 0; i < _settingItems.length; i++) {
      final item = _settingItems[i];
      final isSelected = _selectedTag == item.tag;
      final alpha = isSelected && isWide ? styles.alphaOpaque : styles.alphaAlmostTransparent;

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

// 淡入淡出路由
class _FadeRoute extends PageRouteBuilder {
  _FadeRoute({required WidgetBuilder builder}) : super(
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionDuration: const Duration(milliseconds: 200),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        child: child,
      );
    },
  );
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
