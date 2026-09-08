import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/ui/pages/pwd/eval.dart';
import 'package:passtateless/ui/pages/pwd/view.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/adaptive_view.dart';
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/ui/widgets/styled_list_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget _switchPage((String, String) tag, bool isWide) {
    switch (tag) {
      case ("pages", "pwdEval"):
        return PwdEvalPage(key: ValueKey(tag.$2), useHero: !isWide, hasAppBar: !isWide, hasPadding: !isWide);
      case ("pages", "quickMode"):
        return PwdViewPage(key: ValueKey(tag.$2), enableEdit: true, useHero: !isWide, hasAppBar: !isWide, hasPadding: !isWide);
      default:
        return styled.buildPlaceHolder(text: "无效选择", context: context);
    }
  }

  // 构建左侧面板
  Widget _buildLeftContent(
    BuildContext context,
    bool isWide,
    void Function((String, String) tag) navigateTo,
    bool Function((String, String) tag) isSelected,
  ) {
    return ConstrainedBox(
      constraints: isWide ? styles.tileWidthConstraintSmall : styles.tileWidthConstraint,
      child: ListView(
        children: [
          StyledListTileSimple(
            title: "密码强度",
            subtitle: "评估密码强度，获取相关建议",
            leadingIcon: Icons.checklist,
            trailing: Icon(Icons.arrow_forward),
            isFirst: true,
            onTap: () {
              appLogger.logger.d("Selected: ('pages', 'pwdEval')");
              navigateTo(("pages", "pwdEval"));
            },
            highlighted: isSelected(("pages", "pwdEval")),
          ),
          StyledListTileSimple(
            title: "快速开始",
            subtitle: "不创建资料，直接生成密码",
            leadingIcon: Icons.play_circle_outline,
            trailing: Icon(Icons.arrow_forward),
            isLast: true,
            onTap: () {
              appLogger.logger.d("Selected: ('pages', 'quickMode')");
              navigateTo(("pages", "quickMode"));
            },
            highlighted: isSelected(("pages", "quickMode")),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveView(
      leftPaneBuilder: _buildLeftContent,
      pageBuilder: _switchPage,
      padding: styles.pagePaddingAll,
      widthThreshold:
          styles.tileWidthConstraintSmall.maxWidth +
          styles.tileWidthConstraint.maxWidth +
          styles.layoutSpacing * 2
    );
  }
}
