import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passtateless/ui/widgets/uni_styles.dart' as styles;
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/ui/pages/pwd_edit.dart';

class StarredPasswords extends StatelessWidget {
  const StarredPasswords({super.key});

  @override
  Widget build(BuildContext context) {
    final starredPasswords = context.watch<PwdProvider>().starredPwds;

    return Container(
      constraints: styles.tileHeightConstraint,
      decoration: BoxDecoration(
        border: Border.all(
          color: ColorScheme.of(context).onPrimaryContainer
        ),
        borderRadius: styles.uniBorderRadius
      ),
      child: Padding(
        padding: styles.uniInsetsSmall,
        child: SingleChildScrollView(
          child: Column(
            children: _buildList(context, starredPasswords),
          ),
        ),
      ),
    );
  }

  List<ListTile> _buildList(BuildContext context, List<Map<String, dynamic>> starredPasswords) {
    if (starredPasswords.isEmpty) {
      return <ListTile>[
        ListTile(
          shape: styles.uniRoundedBorder,
          onTap: (){},
          title: const Text("没有收藏"),
          subtitle: const Text("前往管理页面添加收藏项，以在此处快速访问"),
        )
      ];
    } else {
      List<ListTile> temp = [];
      for (var(index, item) in starredPasswords.indexed) {
        temp.add(
          ListTile(
            shape: styles.uniRoundedBorder,
            onTap: (){
              throw UnimplementedError("暂未实现点击复制逻辑");
            },
            title: Text(item['identifier'] == "" ? "未命名" : item['identifier']),
            subtitle: Text("${item["userName"]} @ ${item["account"]}"),
            trailing: IconButton(
              style: styles.uniButtonStyle,
              onPressed: (){
                Provider.of<PwdProvider>(context, listen: false).switchStarStateFromStarred(index);
              },
              icon: item["starred"] ? Icon(Icons.star) : Icon(Icons.star_border)
            ),
          ),
        );
      }
      return temp;
    }
  }
}
