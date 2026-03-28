import 'package:flutter/material.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;

class HomePageQuickOptions extends StatelessWidget {
  final void Function()? onEditTapped;
  final void Function()? onEvalTapped;

  const HomePageQuickOptions({
    super.key,
    this.onEditTapped,
    this.onEvalTapped,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: styles.pageWidthConstraint,
      child: Column(
        spacing: styles.layoutSpacing,
        children: [
          // 密码管理
          styled.buildListTile(
            title: "密码管理",
            subtitle: "增加、删除或修改你的密码",
            leading: Icons.format_list_bulleted,
            trailing: Icon(Icons.arrow_forward),
            onTapped: onEditTapped,
            context: context
          ),
          // 密码评估
          styled.buildListTile(
            title: "密码评估",
            subtitle: "评估密码强度，并获取相关建议",
            leading: Icons.checklist,
              trailing: Icon(Icons.arrow_forward),
            onTapped: onEvalTapped,
            context: context
          )
        ],
      ),
    );
  }
}