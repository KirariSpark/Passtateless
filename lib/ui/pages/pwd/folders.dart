import 'package:flutter/material.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/pages/pwd/list.dart';
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:provider/provider.dart';

class PwdFolderPage extends StatelessWidget {
  const PwdFolderPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> folders = context.watch<PwdProvider>().pwdFolders;
    List<Widget> foldersTiles = [];
    for (var item in folders) {
      foldersTiles.add(ConstrainedBox(
        constraints: styles.tileWidthConstraint,
        child: styled.buildListTile(
          title: item.isEmpty ? "未分类" : item,
          onTapped: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => PwdListPage()));
          },
          trailing: Icon(Icons.arrow_forward),
          alpha: styles.alphaSemitransparent,
          context: context
        ),
      ));
    }
    return Scaffold(
      appBar: styled.buildAppBar(title: "密码管理", context: context),
      body: Container(
        alignment: Alignment.topCenter,
        child: Container(
          padding: styles.pagePadding,
          constraints: styles.pageWidthConstraint,
          child: SingleChildScrollView(
            child: Wrap(children: foldersTiles),
          )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        shape: styles.roundedBorder,
        elevation: 3,
        child: Icon(Icons.create_new_folder_outlined),
      ),
    );
  }
}