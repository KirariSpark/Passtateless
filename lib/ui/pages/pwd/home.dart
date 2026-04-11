import 'package:flutter/material.dart';
import 'package:passtateless/ui/pages/pwd/eval.dart';
import 'package:passtateless/ui/pages/pwd/folders.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/ui/widgets/stars.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _buildListTiles(BuildContext context) {
    return Container(
      constraints: styles.tileWidthConstraint.loosen(),
      decoration: BoxDecoration(
        borderRadius: styles.borderRadius,
        color: ColorScheme.of(context).primaryContainer.withAlpha(styles.alphaAlmostTransparent),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 密码管理
          styled.buildListTile(
            title: "资料夹",
            titleTag: "folders",
            subtitle: "查看和修改全部密码资料夹",
            leading: Icons.format_list_bulleted,
            trailing: Icon(Icons.arrow_forward),
            onTapped: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PwdFolderPage()),
            ),
            alpha: 0,
            isFirst: true,
            context: context,
          ),
          // 密码评估
          styled.buildListTile(
            title: "密码强度",
            titleTag: "pwdEval",
            subtitle: "评估密码强度，并获取相关建议",
            leading: Icons.checklist,
            trailing: Icon(Icons.arrow_forward),
            onTapped: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PwdEvalPage()),
            ),
            alpha: 0,
            isLast: true,
            context: context,
          )
        ],
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Container(
      key: const ValueKey('wide-layout'),
      alignment: Alignment.topCenter,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: styles.layoutSpacing,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints: styles.tileWidthConstraint.loosen(),
              child: StarredPasswords(hasConstraint: false),
            ),
          ),
          Flexible(child: _buildListTiles(context)),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      key: const ValueKey('narrow-layout'),
      child: SingleChildScrollView(
        child: Column(
          spacing: styles.layoutSpacing,
          children: [
            ConstrainedBox(
              constraints: styles.tileWidthConstraint,
              child: StarredPasswords(hasConstraint: true),
            ),
            _buildListTiles(context),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: styles.pagePaddingAll,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // 判断是否满足双栏布局条件
          final bool isWide = constraints.maxWidth > (styles.tileWidthConstraint.maxWidth * 2 + styles.layoutSpacing);

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeOutCubic,
            child: isWide ? _buildWideLayout(context) : _buildNarrowLayout(context),
          );
        },
      ),
    );
  }
}
