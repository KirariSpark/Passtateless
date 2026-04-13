import 'package:flutter/material.dart';
import 'package:passtateless/ui/pages/pwd/eval.dart';
import 'package:passtateless/ui/pages/pwd/folders.dart';
import 'package:passtateless/ui/pages/pwd/view.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/stars.dart';
import 'package:passtateless/ui/widgets/styled.dart' as styled;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // (命名空间, 值) 的 Record
  (String, String)? _selectedTag;

  // 右侧栏专属的 Navigator Key
  final GlobalKey<NavigatorState> _homePageRightNavigatorKey = GlobalKey<NavigatorState>();

  // 构建右侧页面
  Widget _buildPage((String, String) tag, bool isWide) {
    switch (tag) {
      case ("pages", "folders"):
        return PwdFolderPage(key: ValueKey(tag.$2), useHero: !isWide);
      case ("pages", "pwdEval"):
        return PwdEvalPage(key: ValueKey(tag.$2), useHero: !isWide);
      case ("pwd", String id):
        return PwdViewPage(key: ValueKey(id), id: id);
      default:
        return styled.buildPlaceHolder(text: "无效选择", context: context);
    }
  }

  // 统一的点击处理逻辑
  void _onItemTapped((String, String) tag, bool isWide) {
    if (isWide) {
      setState(() {
        _selectedTag = tag;
      });
      _homePageRightNavigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => _buildPage(tag, isWide)), (route) => false,
      );
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => _buildPage(tag, isWide)));
    }
  }

  // 构建单个瓦片
  Widget _buildTile({
    required (String, String) tag,
    required String title,
    required String? titleTag,
    required String subtitle,
    required IconData leading,
    required bool isFirst,
    required bool isLast,
    required bool isWide,
    required BuildContext context,
  }) {
    final isSelected = _selectedTag == tag && isWide;
    final alpha = isSelected ? styles.alphaOpaque : styles.alphaAlmostTransparent;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      switchOutCurve: Curves.easeOutCubic,
      switchInCurve: Curves.easeOutCubic,
      child: ConstrainedBox(
        constraints: styles.tileWidthConstraint,
        key: isSelected ? const ValueKey("selected") : const ValueKey("notSelected"),
        child: styled.buildListTile(
          alpha: alpha,
          title: title,
          titleTag: titleTag,
          subtitle: subtitle,
          leading: leading,
          trailing: const Icon(Icons.arrow_forward),
          onTapped: () => _onItemTapped(tag, isWide),
          isFirst: isFirst,
          isLast: isLast,
          context: context,
        ),
      ),
    );
  }

  // 构建左侧部分
  Widget _buildLeftContent(BuildContext context, bool isWide) {
    return ConstrainedBox(
      constraints: styles.tileWidthConstraint,
      child: Column(
        spacing: styles.layoutSpacing,
        children: [
          // 入口部分
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTile(
                tag: ("pages", "folders"),
                title: "资料夹",
                titleTag: isWide ? null : "folders",
                subtitle: "查看和修改全部密码资料夹",
                leading: Icons.format_list_bulleted,
                isFirst: true,
                isLast: false,
                isWide: isWide,
                context: context,
              ),
              _buildTile(
                tag: ("pages", "pwdEval"),
                title: "密码强度",
                titleTag: isWide ? null : "pwdEval",
                subtitle: "评估密码强度，并获取相关建议",
                leading: Icons.checklist,
                isFirst: false,
                isLast: true,
                isWide: isWide,
                context: context,
              ),
            ],
          ),
          // 收藏夹
          Expanded(
            child: StarredPasswords(
              hasConstraint: false,
              isWide: isWide,
              onItemTapped: (id) => _onItemTapped(("pwd", id), isWide),
              // 命名空间是pwd时才提供
              selectedId: _selectedTag?.$1 == "pwd" && isWide ? _selectedTag?.$2 : null,
            ),
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
          return styled.buildPlaceHolder(text: '', context: context);
        } else if (_selectedTag != null) {
          // 有选中项时显示对应页面
          return Navigator(
            observers: [HeroController()],
            key: _homePageRightNavigatorKey,
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
            key: _homePageRightNavigatorKey,
            onGenerateRoute: (_) {
              return MaterialPageRoute(
                builder: (context) => styled.buildPlaceHolder(text: "未选择项目", context: context),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Container(
      key: const ValueKey('wide-home'),
      padding: styles.pagePaddingAll,
      child: Row(
        spacing: styles.layoutSpacing,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLeftContent(context, true),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: Container(
              constraints: styles.tileWidthConstraint,
              child: _buildRightContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Container(
      padding: styles.pagePaddingAll,
      alignment: Alignment.topCenter,
      key: const ValueKey('narrow-home'),
      child: _buildLeftContent(context, false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // 判断是否满足双栏布局条件
        final bool isWide = constraints.maxWidth > (styles.tileWidthConstraint.maxWidth * 2 + styles.layoutSpacing);
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 100),
          child: isWide ? _buildWideLayout(context) : _buildNarrowLayout(context),
        );
      },
    );
  }
}
