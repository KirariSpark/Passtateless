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

  Widget _buildPage(String tag, bool isWide) {
    switch (tag) {
      case "folders":
        return PwdFolderPage(key: ValueKey(tag), useHero: !isWide);
      case "pwdEval":
        return PwdEvalPage(key: ValueKey(tag), useHero: !isWide);
      default:
        return const SizedBox.shrink();
    }
  }

  // 普通项目的点击
  void _onItemTapped(String tag, bool isWide) {
    if (isWide) {
      setState(() {
        _selectedTag = tag;
        _selectedPwdId = null; // 切换普通页面时，清空密码详情状态
      });
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => _buildPage(tag, isWide)));
    }
  }

  // 收藏夹项目的点击
  void _onStarredItemTapped(String id, bool isWide) {
    if (isWide) {
      setState(() {
        _selectedTag = null; // 切换密码详情时，清空普通页面状态
        _selectedPwdId = id;
      });
    } else {
      // 窄屏时通过 Provider 获取完整记录用于路由传参
      final record = Provider.of<PwdProvider>(context, listen: false).getItemById(id);
      if (record.isNotEmpty) {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => PwdViewPage(
              identifier: record["identifier"] ?? "",
              userName: record["userName"] ?? "",
              account: record["account"] ?? "",
            ),
          ),
        );
      }
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
    final alpha = isSelected
        ? styles.alphaOpaque
        : styles.alphaAlmostTransparent;

    // 下方入口部分
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      switchOutCurve: Curves.easeOutCubic,
      switchInCurve: Curves.easeOutCubic,
      child: ConstrainedBox(
        constraints: styles.tileWidthConstraint,
        key: isSelected
            ? const ValueKey("selected")
            : const ValueKey("notSelected"),
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

  Widget _buildMainContent(BuildContext context, bool isWide) {
    return ConstrainedBox(
      constraints: styles.tileWidthConstraint,
      child: SingleChildScrollView(
        child: Column(
          spacing: styles.layoutSpacing,
          children: [
            StarredPasswords(
              hasConstraint: true,
              isWide: isWide,
              onItemTapped: (id) => _onStarredItemTapped(id, isWide),
              selectedId: _selectedPwdId,
            ),
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
          color: ColorScheme.of(
            context,
          ).primaryContainer.withAlpha(styles.alphaAlmostTransparent),
        ),
        child: Center(child: Text(text)),
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 200) {
          return buildHint("");
        } else if (_selectedPwdId != null) {
          // 通过 ID 从 Provider 获取密码记录
          final pwdRecord = context.watch<PwdProvider>().getItemById(_selectedPwdId!);

          if (pwdRecord.isNotEmpty) {
            // 如果有选中的密码记录，则渲染密码详情页
            return AnimatedSwitcher(
              switchOutCurve: Curves.easeOutCubic,
              switchInCurve: Curves.easeOutCubic,
              duration: Duration(milliseconds: 200),
              child: PwdViewPage(
                key: ValueKey(_selectedPwdId),
                identifier: pwdRecord["identifier"] ?? "",
                userName: pwdRecord["userName"] ?? "",
                account: pwdRecord["account"] ?? "",
              ),
            );
          } else {
            return buildHint("未找到记录");
          }
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
      key: const ValueKey('wide-home'),
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
      key: const ValueKey('narrow-home'),
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
