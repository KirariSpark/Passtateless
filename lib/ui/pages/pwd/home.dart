import 'package:flutter/material.dart';
import 'package:passtateless/ui/pages/pwd/eval.dart';
import 'package:passtateless/ui/pages/pwd/folders.dart';
import 'package:passtateless/ui/pages/pwd/view.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/ui/widgets/stars.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedTag;
  String? _selectedPwdId;

  // 右侧栏专属的 Navigator Key
  final GlobalKey<NavigatorState> _homePageRightNavigatorKey = GlobalKey<NavigatorState>();

  // 构建右侧页面（将tag设为pwd以使id起作用，此时id一定不能为空）
  Widget _buildPage(String tag, bool isWide, String? id) {
    switch (tag) {
      case "folders":
        return PwdFolderPage(key: ValueKey(tag), useHero: !isWide);
      case "pwdEval":
        return PwdEvalPage(key: ValueKey(tag), useHero: !isWide);
      case "pwd":
        return PwdViewPage(key: ValueKey(_selectedPwdId), id: id!);
      default:
        return styled.buildPlaceHolder(text: "无效选择", context: context);
    }
  }

  // 普通项目的点击
  void _onItemTapped(String tag, bool isWide) {
    if (isWide) {
      setState(() {
        _selectedTag = tag;
        _selectedPwdId = null; // 切换普通页面时，清空密码详情状态
      });
      _homePageRightNavigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => _buildPage(tag, isWide, null)), (route) => false
      );
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => _buildPage(tag, isWide, null)));
    }
  }

  // 收藏夹项目的点击
  void _onStarredItemTapped(String id, bool isWide) {
    if (isWide) {
      setState(() {
        _selectedTag = null; // 切换密码详情时，清空普通页面状态
        _selectedPwdId = id;
      });
      _homePageRightNavigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => _buildPage("pwd", isWide, id)), (route) => false
      );
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => _buildPage("pwd", isWide, null)));
    }
  }

  // 构建单个瓦片
  Widget _buildTile({
    required String tag,
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

    // 下方入口部分
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
                tag: "folders",
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
                tag: "pwdEval",
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
              hasConstraint: false, // 取消固定高度约束，由 Expanded 控制
              isWide: isWide,
              onItemTapped: (id) => _onStarredItemTapped(id, isWide),
              selectedId: _selectedPwdId,
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
        } else if (_selectedPwdId != null) {
          // 选择了密码项时，显示密码详情页
          // 通过 ID 从 Provider 获取密码记录
          return Navigator(
            observers: [HeroController()],
            key: _homePageRightNavigatorKey,
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                builder: (context) => _buildPage("pwd", true, _selectedPwdId),
              );
            },
          );
        } else if (_selectedTag == null) {
          // 没有选择设置项
          return Navigator(
            observers: [HeroController()],
            key: _homePageRightNavigatorKey,
            onGenerateRoute: (_) {
              return MaterialPageRoute(
                builder: (context) => styled.buildPlaceHolder(text: "未选择项目", context: context)
              );
            },
          );
        } else {
          // 选择了设置项时
          return Navigator(
            observers: [HeroController()],
            key: _homePageRightNavigatorKey,
            onGenerateRoute: (_) {
              return MaterialPageRoute(
                builder: (context) => _buildPage(_selectedTag!, true, null),
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
