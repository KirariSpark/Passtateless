import 'package:flutter/material.dart';
import 'package:passtateless/ui/widgets/uni_styles.dart' as styles;

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
          ListTile(
            onTap: onEditTapped,
            leading: Icon(Icons.format_list_bulleted),
            title: Text("密码管理"),
            subtitle: Text("增加、删除或修改你的密码"),
            trailing: Icon(Icons.arrow_forward),
            shape: styles.roundedBorder,
            tileColor: ColorScheme.of(context).surfaceContainerLowest,
          ),
          // 密码评估
          ListTile(
            onTap: onEvalTapped,
            leading: Icon(Icons.checklist),
            title: Text("密码评估"),
            subtitle: Text("评估密码强度，并获取相关建议"),
            trailing: Icon(Icons.arrow_forward),
            shape: styles.roundedBorder,
            tileColor: ColorScheme.of(context).surfaceContainerLowest,
          )
        ],
      ),
    );
  }
}