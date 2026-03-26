import 'package:flutter/material.dart';
import 'package:passtateless/ui/widgets/uni_styles.dart' as styles;

class HomePageQuickOptions extends StatelessWidget {
  final void Function()? onEditTapped;

  const HomePageQuickOptions({
    super.key,
    required this.onEditTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        // 密码管理
        ConstrainedBox(
          constraints: styles.pageWidthConstraint,
          child: ListTile(
            onTap: onEditTapped,
            leading: Icon(Icons.edit),
            title: Text("密码管理"),
            subtitle: Text("增加、删除或修改你的密码"),
            trailing: Icon(Icons.arrow_forward),
            shape: styles.uniRoundedBorder,
            tileColor: ColorScheme.of(context).surfaceContainer,
          ),
        )
      ],
    );
  }
}