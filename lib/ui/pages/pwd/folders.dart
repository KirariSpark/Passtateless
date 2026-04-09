import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/pages/pwd/list.dart';
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:provider/provider.dart';

class PwdFolderPage extends StatefulWidget {
  const PwdFolderPage({super.key});

  @override
  State<PwdFolderPage> createState() => _PwdFolderPageState();
}

class _PwdFolderPageState extends State<PwdFolderPage> {
  final TextEditingController folderName = TextEditingController();

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
          child: SingleChildScrollView(
            child: Wrap(
              spacing: styles.layoutSpacing,
              runSpacing: styles.layoutSpacing,
              children: foldersTiles
            ),
          )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          ui.showAlertDialogQuick(
            title: "新建文件夹",
            content: styled.buildTextField(
              label: "文件夹名",
              controller: folderName,
              alpha: styles.alphaSemitransparent,
              context: context
            ),
            action: (){
              Navigator.pop(context);
            },
            actionText: "取消",
            action2: () {
              var stat = Provider.of<PwdProvider>(context, listen: false).addFolder(folderName.text);
              if (stat == ErrorCode.success) {
                Navigator.pop(context);
                ui.showSnackBarQuick("文件夹已建立", context);
              } else if (stat == ErrorCode.emptyKey) {
                ui.showSnackBarQuick("请输入名称", context);
              } else {
                ui.showSnackBarQuick("输入的名称与已有的文件夹重复", context);
              }
            },
            action2Text: "确定",
            context: context
          );
        },
        shape: styles.roundedBorder,
        elevation: 3,
        child: Icon(Icons.create_new_folder_outlined),
      ),
    );
  }
}