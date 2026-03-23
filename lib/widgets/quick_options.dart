import 'package:flutter/material.dart';

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
    return Column(
      children: [
        // 密码管理
        ListTile(
          onTap: onEditTapped,
          leading: Icon(Icons.edit),
          title: Text("密码管理"),
          subtitle: Text("增加、删除或修改你的密码"),
        ),
        // 基础设置
        ListTile(
          onTap: (){},
          leading: Icon(Icons.settings),
          title: Text("基础设置"),
          subtitle: Text("基础生成器设置"),
        ),
        // 高级设置
        ListTile(
          onTap: (){},
          leading: Icon(Icons.code),
          title: Text("高级设置"),
          subtitle: Text("高级生成器设置"),
        )
      ],
    );
  }
}