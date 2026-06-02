import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
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

  /// 页面是否有横向内边距
  final bool hasHorizontalPadding;

  const PwdFolderPage({super.key, required this.useHero, this.hasHorizontalPadding = true});

  @override
  State<PwdFolderPage> createState() => _PwdFolderPageState();
}

class _PwdFolderPageState extends State<PwdFolderPage> {
  final TextEditingController folderName = TextEditingController();

  void _showBottomSheet(String title, String folder) {
    ui.showBottomSheetQuick(
      context: context,
      title: title,
      children: [
        styled.buildListTile(
          title: "重命名",
          leading: Icons.edit_outlined,
          isFirst: true,
          onTapped: () => _renameFolder(folder, title),
          context: context
        ),
        styled.buildListTile(
          title: "删除",
          leading: Icons.delete_outline,
          isLast: true,
          onTapped: () => _removeFolder(folder, title),
          context: context
        )
      ]
    );
  }

  void _onItemTapped(String folder) {
    appLogger.logger.i("Pushing to page listing items in folder $folder");
    Navigator.push(
      context,
      ui.switchRoute(
        Provider.of<AppProvider>(context, listen: false).currentNavMode,
        builder: (context) => PwdListPage(folder: folder, useHero: true)
      )
    );
  }

  void _newFolder() {
    ui.showAlertDialogQuick(
      title: "新建资料夹",
      content: styled.buildTextField(label: "资料夹名", controller: folderName, context: context),
      action: () => Navigator.of(context).pop(),
      actionText: "取消",
      action2: () {
        appLogger.logger.i("Add folder ${folderName.text}");
        var stat = Provider.of<PwdProvider>(context, listen: false).addFolder(folderName.text);
        if (stat == ErrorCode.success) {
          appLogger.logger.i("Added successfully");
          Navigator.of(context).pop();
        } else {
          appLogger.logger.e("Can not add folder: ${stat.code}");
          ui.showSnackBarQuick(stat.generic, context);
        }
      },
      action2Text: "确定",
      context: context
    );
  }

  void _renameFolder(String folder, String title) {
    appLogger.logger.i("Trying to rename folder $folder");
    Navigator.pop(context);
    // 内置文件夹 未分类 不能重命名
    if (folder == "") {
      appLogger.logger.e("Folder (empty string) is builtin and can not be renamed");
      ui.showSnackBarQuick("你不能重命名此文件夹", context);
      return;
    }
    ui.showAlertDialogQuick(
      title: "重命名：$title",
      content: styled.buildTextField(context: context, controller: folderName, label: "新名称"),
      action: () => Navigator.of(context).pop(),
      actionText: "取消",
      action2: () {
        appLogger.logger.i("Renaming folder to ${folderName.text}");
        var res = Provider.of<PwdProvider>(context, listen: false).renameFolder(
            folder, folderName.text
        );
        if (res == ErrorCode.success) {
          appLogger.logger.i("Renamed successfully");
          Navigator.of(context).pop();
        } else {
          appLogger.logger.e("Can not rename folder: ${res.code}");
          ui.showSnackBarQuick(res.generic, context);
        }
      },
      action2Text: "确定",
      context: context
    );
  }

  void _removeFolder(String folder, String title) {
    Navigator.pop(context);
    // 未分类 文件夹是内置文件夹，不能删除
    if (folder.isEmpty) {
      appLogger.logger.i("folder (empty string) is builtin and can not be deleted");
      ui.showSnackBarQuick("你不能删除此文件夹", context);
    } else {
      ui.showConfirmDialogQuick(
        context: context,
        info: "确定要删除文件夹 “$folder” 吗\n一旦更改被保存，你将永远失去它",
        function: () {
          appLogger.logger.i("Trying to delete folder $folder");
          Provider.of<PwdProvider>(context, listen: false).removeFolder(folder);
          appLogger.logger.i("Folder deleted");
          Navigator.of(context).pop();
        },
        title: '删除：$title'
      );
    }
  }

  Future<void> _save() async {
    appLogger.logger.i("Saving changes in password archive");
    ui.showSnackBarQuick("正在保存", context);
    var stat = await Provider.of<PwdProvider>(context, listen: false).saveArchive(
        Provider.of<AppProvider>(context, listen: false).masterPwd
    );
    if (mounted) {
      if (stat == ErrorCode.success) {
        appLogger.logger.i("Saved successfully");
        ui.showSnackBarQuick("你的档案已保存", context);
      } else {
        appLogger.logger.i("Can not save archive: ${stat.code}");
        ui.showSnackBarQuick(stat.generic, context);
      }
    }
  }

  Widget _buildFolderList(List<String> folders) {
    return Container(
      alignment: Alignment.topCenter,
      padding: widget.hasHorizontalPadding ? styles.pagePaddingAll : styles.pagePaddingVertical,
      child: Container(
        constraints: styles.tileWidthConstraint,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: folders.length,
          itemBuilder: (BuildContext context, int index) {
            final bool isFirst = index == 0;
            final bool isLast = index == folders.length - 1;
            final String displayTitle = folders[index].isEmpty ? "未分类" : folders[index];
            return Material(
              child: styled.buildListTileAdvanced(
                onRightClick: () => _showBottomSheet(displayTitle, folders[index]),
                onTapped: () => _onItemTapped(folders[index]),
                isFirst: isFirst,
                isLast: isLast,
                title: displayTitle,
                titleTag: folders[index],
                context: context
              )
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
      appBar: styled.buildAppBar(
        title: "资料夹",
        actions: [
          styled.buildPopupMenuButton(
            context: context,
            children: [
              PopupMenuItem(
                onTap: _newFolder,
                child: Row(
                  spacing: styles.layoutSpacing,
                  children: [
                    Icon(Icons.create_new_folder_outlined),
                    Text("新建资料夹")
                  ],
                )
              ),
              PopupMenuItem(
                onTap: _save,
                child: Row(
                  spacing: styles.layoutSpacing,
                  children: [
                    Icon(Icons.save_outlined),
                    Text("保存更改")
                  ],
                )
              )
            ]
          )
        ],
        context: context,
        titleTag: widget.useHero ? "folders" : null
      ),
      body: _buildFolderList(folders)
    );
  }
}