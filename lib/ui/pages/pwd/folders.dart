import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/pages/pwd/list.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:provider/provider.dart';

/// 密码文件夹列表界面
class PwdFolderPage extends StatefulWidget {
  /// 有AppBar时，AppBar是否要使用Hero动画
  final bool useHero;
  /// 页面是否有AppBar
  final bool hasAppBar;
  /// 页面是否有内边距
  final bool hasPadding;
  const PwdFolderPage({super.key, required this.useHero, this.hasAppBar = true, this.hasPadding = true});

  @override
  State<PwdFolderPage> createState() => _PwdFolderPageState();
}

class _PwdFolderPageState extends State<PwdFolderPage> {
  final TextEditingController folderName = TextEditingController();

  Widget _buildMainBody(List<String> folders) {
    return Container(
      alignment: Alignment.topCenter,
      child: Container(
        constraints: styles.tileWidthConstraint,
        decoration: BoxDecoration(
          borderRadius: styles.borderRadius,
          color: ColorScheme.of(context).primaryContainer.withAlpha(styles.alphaAlmostTransparent)
        ),
        clipBehavior: Clip.antiAlias,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: folders.length,
          itemBuilder: (BuildContext context, int index) {
            final String displayTitle = folders[index].isEmpty ? "未分类" : folders[index];
            final bool isFirst = index == 0;
            final bool isLast = index == folders.length - 1;
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
                title: displayTitle,
                titleTag: folders[index],
                onTapped: (){
                  Navigator.push(
                    context, MaterialPageRoute(builder: (context) => PwdListPage(folder: folders[index]))
                  );
                },
                trailing: IconButton(
                  tooltip: "重命名",
                  onPressed: () {
                    if (folders[index] == "") {
                      ui.showSnackBarQuick("你不能重命名此文件夹", context);
                      return;
                    }
                    ui.showAlertDialogQuick(
                      title: "重命名：$displayTitle", content: styled.buildTextField(
                      context: context, controller: folderName, label: "新名称"
                    ),
                      action: () => Navigator.of(context, rootNavigator: true).pop(),
                      actionText: "取消",
                      action2: () {
                        var res = Provider.of<PwdProvider>(context, listen: false).renameFolder(
                          folders[index], folderName.text
                        );
                        if (res == ErrorCode.success) {
                          Navigator.of(context, rootNavigator: true).pop();
                        } else {
                          ui.showSnackBarQuick(res.generic, context);
                        }
                      },
                      action2Text: "确定",
                      context: context
                    );
                  },
                  style: styles.buttonStyle,
                  icon: Icon(Icons.drive_file_rename_outline_outlined)
                ),
                isFirst: isFirst,
                isLast: isLast,
                context: context
              ),
            );
          }
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> folders = context.watch<PwdProvider>().pwdFolders;
    return Scaffold(
      appBar: widget.hasAppBar
        ? styled.buildAppBar(title: "资料夹", context: context, titleTag: widget.useHero ? "folders" : null)
        : null,
      body: Padding(
        padding: widget.hasPadding ? styles.pagePadding : EdgeInsets.all(0),
        child: _buildMainBody(folders)
      ),
      floatingActionButton: PopupMenuButton(
        popUpAnimationStyle: AnimationStyle(
            curve: Curves.easeInOut,
            duration: Duration(milliseconds: 300),
            reverseCurve: Curves.easeInOut,
            reverseDuration: Duration(milliseconds: 300)
        ),
        tooltip: "更多功能",
        iconSize: 30,
        itemBuilder: (_) {
          return [
            // 保存更改
            PopupMenuItem(
              child: Row(
                spacing: styles.layoutSpacing,
                children: [
                  Icon(Icons.save_outlined),
                  Text("保存更改")
                ],
              ),
              onTap: () async {
                ui.showSnackBarQuick("正在保存", context);
                var stat = await Provider.of<PwdProvider>(context, listen: false).saveArchive(
                    Provider.of<AppProvider>(context, listen: false).masterPwd
                );
                if (context.mounted) {
                  if (stat == ErrorCode.success) {
                    ui.showSnackBarQuick("你的档案已保存", context);
                  } else {
                    ui.showSnackBarQuick(stat.generic, context);
                  }
                }
              },
            ),
            // 新建资料夹
            PopupMenuItem(
                child: Row(
                  spacing: styles.layoutSpacing,
                  children: [
                    Icon(Icons.create_new_folder_outlined),
                    Text("新建资料夹")
                  ],
                ),
                onTap: (){
                  ui.showAlertDialogQuick(
                      title: "新建文件夹",
                      content: styled.buildTextField(
                          label: "文件夹名", controller: folderName,
                          context: context
                      ),
                      action: () => Navigator.of(context, rootNavigator: true).pop(),
                      actionText: "取消",
                      action2: () {
                        var stat = Provider.of<PwdProvider>(context, listen: false).addFolder(folderName.text);
                        if (stat == ErrorCode.success) {
                          Navigator.of(context, rootNavigator: true).pop();
                          ui.showSnackBarQuick("文件夹已建立", context);
                        } else {
                          ui.showSnackBarQuick(stat.generic, context);
                        }
                      },
                      action2Text: "确定",
                      context: context
                  );
                }
            )
          ];
        },
        child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: ColorScheme.of(context).primaryContainer,
                borderRadius: styles.borderRadius
            ),
            child: Icon(Icons.menu)
        ),
      ),
    );
  }
}