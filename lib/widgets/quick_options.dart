import 'package:flutter/material.dart';
import 'package:passtateless/widgets/uni_styles.dart' as styles;

class HomePageQuickOptions extends StatelessWidget {
  final void Function()? onEditTapped;
  final void Function()? onBasicTapped;
  final void Function()? onAdvancedTapped;

  const HomePageQuickOptions({
    super.key,
    required this.onEditTapped,
    required this.onBasicTapped,
    required this.onAdvancedTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        // 密码管理
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 400
          ),
          child: ListTile(
            onTap: onEditTapped,
            leading: Icon(Icons.edit),
            title: Text("密码管理"),
            subtitle: Text("增加、删除或修改你的密码"),
            trailing: Icon(Icons.arrow_forward),
            shape: styles.uniRoundedBorder
          ),
        ),
        // 基础设置
        ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: 400
          ),
          child: ListTile(
            onTap: onBasicTapped,
            leading: Icon(Icons.settings),
            title: Text("基础设置"),
            subtitle: Text("生成预设、后处理等基础生成器设置"),
            trailing: Icon(Icons.arrow_forward),
            shape: styles.uniRoundedBorder,
          ),
        ),
        // 高级设置
        ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: 400
          ),
          child: ListTile(
            onTap: onAdvancedTapped,
            leading: Icon(Icons.code),
            title: Text("高级设置"),
            subtitle: Text("自定义生成方案等高级生成器设置"),
            trailing: Icon(Icons.arrow_forward),
            shape: styles.uniRoundedBorder,
          ),
        )
      ],
    );
  }
}