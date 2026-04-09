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

    return Scaffold(
      appBar: styled.buildAppBar(title: "全部资料夹", context: context),
      body: Container(
        alignment: Alignment.topCenter,
        child: Container(
          padding: styles.pagePadding,
          constraints: styles.pageWidthConstraint,
          child: ListView.separated(
            itemCount: folders.length,
            itemBuilder: (BuildContext context, int index) {
              return Dismissible(
                key: ValueKey(folders[index]),
                direction: DismissDirection.endToStart,
                background: Container(
                  decoration: BoxDecoration(
                    borderRadius: styles.borderRadius,
                    color: Colors.red,
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete_forever, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  // 未分类 文件夹是内置文件夹，不能删除
                  if (folders[index].isEmpty) {
                    ui.showSnackBarQuick("你不能删除此文件夹", context);
                    return false;
                  } else {
                    return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("确认删除"),
                        shape: styles.roundedBorder,
                        content: Text("确定要删除文件夹 ${folders[index]} 吗？\n你会永远失去它（真的很久）"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: styles.buttonStyle,
                            child: const Text("取消"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: styles.buttonStyle,
                            child: const Text("删除", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  }
                },
                onDismissed: (_) {
                  Provider.of<PwdProvider>(context, listen: false).removeFolder(folders[index]);
                  ui.showSnackBarQuick("文件夹已删除", context);
                },
                child: styled.buildListTile(
                  title: folders[index].isEmpty ? "未分类" : folders[index],
                  onTapped: (){
                    Navigator.push(
                      context, MaterialPageRoute(builder: (context) => PwdListPage(folder: folders[index]))
                    );
                  },
                  trailing: Icon(Icons.arrow_forward),
                  alpha: styles.alphaSemitransparent,
                  context: context
                ),
              );
            },
            separatorBuilder: (_, _) {
              return styles.spacingSizedBox;
            },
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
              } else {
                ui.showSnackBarQuick(stat.generic, context);
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