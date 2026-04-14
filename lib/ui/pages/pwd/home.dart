import 'package:flutter/material.dart';
import 'package:passtateless/ui/pages/pwd/eval.dart';
import 'package:passtateless/ui/pages/pwd/folders.dart';
import 'package:passtateless/ui/pages/pwd/view.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/adaptive_view.dart';
import 'package:passtateless/ui/widgets/stars.dart';
import 'package:passtateless/ui/widgets/styled.dart' as styled;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  (String, String)? _localSelectedTag;

  // 构建右侧页面（直接作为 AdaptiveView 的 pageBuilder）
  Widget _buildPage((String, String) tag, bool isWide) {
    switch (tag) {
      case ("pages", "folders"):
        // 宽屏状态下无需使用Scaffold，因为不需要AppBar，也不需要额外的Padding
        return PwdFolderPage(key: ValueKey(tag.$2), useHero: !isWide, hasAppBar: !isWide, hasPadding: !isWide);
      case ("pages", "pwdEval"):
        return PwdEvalPage(key: ValueKey(tag.$2), useHero: !isWide, hasAppBar: !isWide, hasPadding: !isWide);
      case ("pwd", String id):
        return PwdViewPage(key: ValueKey(id), id: id);
      default:
        return styled.buildPlaceHolder(text: "无效选择", context: context);
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
    required void Function((String, String)) onTapped,
    required bool Function((String, String)) isSelectedCallback,
  }) {
    // 使用 AdaptiveView 传递过来的 isSelected 判断方法
    final isSelected = isSelectedCallback(tag);
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
          onTapped: () {
            setState(() {
              _localSelectedTag = tag;
            });
            onTapped(tag);
          },
          isFirst: isFirst,
          isLast: isLast,
          context: context,
        ),
      ),
    );
  }

  // 构建左侧面板
  Widget _buildLeftContent(
    BuildContext context,
    bool isWide,
    void Function((String, String) tag) onItemTapped,
    bool Function((String, String) tag) isSelected,
  ) {
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
                onTapped: onItemTapped,
                isSelectedCallback: isSelected,
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
                onTapped: onItemTapped,
                isSelectedCallback: isSelected,
              ),
            ],
          ),
          // 收藏夹
          Expanded(
            child: StarredPasswords(
              hasConstraint: false,
              isWide: isWide,
              onItemTapped: (id) {
                setState(() {
                  _localSelectedTag = ("pwd", id);
                });
                onItemTapped(("pwd", id));
              },
              selectedId: _localSelectedTag?.$1 == "pwd" && isWide ? _localSelectedTag?.$2 : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveView(
      leftPaneBuilder: (context, isWide, onItemTapped, isSelected) {
        return _buildLeftContent(context, isWide, onItemTapped, isSelected);
      },
      pageBuilder: _buildPage,
      placeholderText: "未选择项目",
      rightPaneConstraints: styles.tileWidthConstraint,
    );
  }
}
