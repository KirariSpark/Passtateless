import 'package:flutter/material.dart';
import 'package:passtateless/ui/pages/pwd/eval.dart';
import 'package:passtateless/ui/pages/pwd/folders.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/ui/widgets/stars.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedTag;

  Widget _buildPage(String tag, bool isWide) {
    switch (tag) {
      case "folders":
        return PwdFolderPage(key: ValueKey(tag), useHero: !isWide); // 宽屏下不应使用Hero
      case "pwdEval":
        return PwdEvalPage(key: ValueKey(tag), useHero: !isWide);
      default:
        return const SizedBox.shrink();
    }
  }

  void _onItemTapped(String tag, bool isWide) {
    if (isWide) {
      setState(() {
        _selectedTag = tag;
      });
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => _buildPage(tag, isWide)));
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
    final colorScheme = ColorScheme.of(context);

    // 根据位置单独配置圆角，避免接缝处出现圆角
    BoxDecoration decoration;
    if (isFirst && isLast) {
      decoration = BoxDecoration(
        borderRadius: styles.borderRadius,
        color: colorScheme.primaryContainer.withAlpha(alpha),
      );
    } else if (isFirst) {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.vertical(top: styles.radius),
        color: colorScheme.primaryContainer.withAlpha(alpha),
      );
    } else if (isLast) {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: styles.radius),
        color: colorScheme.primaryContainer.withAlpha(alpha),
      );
    } else {
      decoration = BoxDecoration(
        color: colorScheme.primaryContainer.withAlpha(alpha),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      switchOutCurve: Curves.easeOutCubic,
      switchInCurve: Curves.easeOutCubic,
      child: Container(
        key: isSelected ? const ValueKey("selected") : const ValueKey("notSelected"),
        decoration: decoration,
        child: styled.buildListTile(
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

  Widget _buildMainContent(BuildContext context, bool isWide) {
    return ConstrainedBox(
      constraints: styles.tileWidthConstraint,
      child: SingleChildScrollView(
        child: Column(
          spacing: styles.layoutSpacing,
          children: [
            StarredPasswords(hasConstraint: true),
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
            )
          ],
        ),
      ),
    );
  }

  // 构建第二栏(右侧)内容
  Widget _buildRightContent(BuildContext context) {
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
        if (constraints.maxWidth < 200) {
          // 过窄时什么都不显示
          return buildHint("");
        } else if (_selectedTag == null) {
          return buildHint("未选择项目");
        } else {
          return AnimatedSwitcher(
            switchOutCurve: Curves.easeOutCubic,
            switchInCurve: Curves.easeOutCubic,
            duration: Duration(milliseconds: 200),
            child: _buildPage(_selectedTag!, true),
          );
        }
      },
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Container(
      key: const ValueKey('wide-layout'),
      padding: styles.pagePaddingAll,
      child: Row(
        spacing: styles.layoutSpacing,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMainContent(context, true),
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
      key: const ValueKey('narrow-layout'),
      child: _buildMainContent(context, false),
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
