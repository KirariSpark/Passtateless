import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/ui/widgets/pwd_tile.dart';

class StarredPasswords extends StatelessWidget {
  const StarredPasswords({super.key});

  @override
  Widget build(BuildContext context) {
    final starredPasswords = context.watch<PwdProvider>().starredPwds;

    return Container(
      constraints: styles.tileHeightConstraint,
      decoration: BoxDecoration(
        color: ColorScheme.of(context).secondaryContainer.withAlpha(175),
        borderRadius: styles.uniBorderRadius
      ),
      padding: styles.uniInsetsSmall,
      child: SingleChildScrollView(
        child: Wrap(
          spacing: styles.layoutSpacing,
          runSpacing: styles.layoutSpacing,
          children: _buildList(context, starredPasswords),
        ),
      ),
    );
  }

  List<Widget> _buildList(BuildContext context, List<Map<String, dynamic>> starredPasswords) {
    if (starredPasswords.isEmpty) {
      return <Widget>[
        Material(
          shape: styles.roundedBorder,
          child: ListTile(
            shape: styles.roundedBorder,
            tileColor: ColorScheme.of(context).surfaceContainerLowest.withAlpha(180),
            onTap: (){},
            title: const Text("没有收藏"),
            subtitle: const Text("前往管理页面添加收藏项，以在此处快速访问"),
          ),
        )
      ];
    } else {
      List<Widget> temp = [];
      for (var(index, _) in starredPasswords.indexed) {
        temp.add(
          PwdTile(
            pwdRecord: starredPasswords[index],
            onStarPressed: (){
              Provider.of<PwdProvider>(context, listen: false).switchStarStateFromStarred(index);
            },
            hasEditButton: false,
            alpha: 180,
          )
        );
      }
      return temp;
    }
  }
}
