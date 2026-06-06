import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/pages/pwd/list.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/adaptive_view.dart';
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:provider/provider.dart';

/// 密码文件夹列表界面
class PwdFolderPage extends StatefulWidget {
  /// 有AppBar时，AppBar是否要使用Hero动画
  final bool useHero;

  /// 页面是否有内边距
  final bool hasPadding;

  /// 页面是否有AppBar
  final bool hasAppBar;

  const PwdFolderPage({
    super.key,
    required this.useHero,
    this.hasPadding = true,
    this.hasAppBar = true
  });

  @override
  State<PwdFolderPage> createState() => _PwdFolderPageState();
}

class _PwdFolderPageState extends State<PwdFolderPage> {
  final TextEditingController _folderNameController = TextEditingController();
  late final AppProvider _appProvider;
  late final PwdProvider _pwdProvider;

  @override
  void initState() {
    super.initState();
    _appProvider = context.read<AppProvider>();
    _pwdProvider = context.read<PwdProvider>();
  }

  @override
  void dispose() {
    _folderNameController.dispose();
    super.dispose();
  }

  void _showBottomSheet({required String title, required String folder}) {
    ui.showBottomSheetQuick(
      context: context,
      title: title,
      children: [
        styled.buildListTile(
          title: "重命名",
          leading: Icons.edit_outlined,
          isFirst: true,
          onTapped: () => _showRenameFolderDialog(folder:folder, title: title),
          context: context
        ),
        styled.buildListTile(
          title: "删除",
          leading: Icons.delete_outline,
          onTapped: () => _showDelFolderDialog(folder: folder, title: title),
          context: context
        ),
        Divider(height: 1),
        styled.buildListTile(
          title: "新建资料夹",
          leading: Icons.create_new_folder_outlined,
          onTapped: () {
            Navigator.pop(context);
            _showNewFolderDialog();
          },
          context: context
        ),
        styled.buildListTile(
          title: "保存更改",
          leading: Icons.save_outlined,
          isLast: true,
          onTapped: () {
            Navigator.pop(context);
            _save();
          },
          context: context
        )
      ]
    );
  }

  void _newFolder() {
    appLogger.logger.i("Add folder ${_folderNameController.text}");
    final stat = _pwdProvider.addFolder(_folderNameController.text);
    if (stat == ErrorCode.success) {
      _appProvider.hasUnsavedChanges = true;
      appLogger.logger.i("Added successfully");
      Navigator.of(context).pop();
    } else {
      appLogger.logger.e("Can not add folder: ${stat.code}");
      ui.showSnackBarQuick(stat.generic, context);
    }
  }

  void _showNewFolderDialog() {
    ui.showAlertDialogQuick(
      title: "新建资料夹",
      content: styled.buildTextField(label: "资料夹名", controller: _folderNameController, context: context),
      action: () => Navigator.of(context).pop(),
      actionText: "取消",
      action2: _newFolder,
      action2Text: "确定",
      context: context
    );
  }

  // TODO: 重命名文件夹后，应该重新选择
  void _renameFolder(String folder) {
    appLogger.logger.i("Renaming folder to ${_folderNameController.text}");
    var res = _pwdProvider.renameFolder(folder, _folderNameController.text);
    if (res == ErrorCode.success) {
      _appProvider.hasUnsavedChanges = true;
      appLogger.logger.i("Renamed successfully");
      Navigator.of(context).pop();
    } else {
      appLogger.logger.e("Can not rename folder: ${res.code}");
      ui.showSnackBarQuick(res.generic, context);
    }
  }

  void _showRenameFolderDialog({required String folder, required String title}) {
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
      content: styled.buildTextField(context: context, controller: _folderNameController, label: "新名称"),
      action: () => Navigator.of(context).pop(),
      actionText: "取消",
      action2: () => _renameFolder(folder),
      action2Text: "确定",
      context: context
    );
  }

  // TODO: 删除文件夹后，应该清空选择
  void _delFolder(String folder) {
    appLogger.logger.i("Trying to delete folder $folder");
    _pwdProvider.removeFolder(folder);
    _appProvider.hasUnsavedChanges = true;
    appLogger.logger.i("Folder deleted");
    Navigator.of(context).pop();
  }

  void _showDelFolderDialog({required String folder, required String title}) {
    Navigator.pop(context);
    // 未分类 文件夹是内置文件夹，不能删除
    if (folder.isEmpty) {
      appLogger.logger.i("folder (empty string) is builtin and can not be deleted");
      ui.showSnackBarQuick("你不能删除此文件夹", context);
    } else {
      ui.showConfirmDialogQuick(
        context: context,
        info: "确定要删除文件夹 “$folder” 吗\n一旦更改被保存，你将永远失去它",
        function: () => _delFolder(folder),
        title: '删除：$title'
      );
    }
  }

  AppBar? _buildAppBar(bool hasAppBar) {
    if (hasAppBar) {
      return styled.buildAppBar(
        title: "资料夹",
        actions: [
          styled.buildPopupMenuButton(
            context: context,
            children: [
              styled.buildPopupMenuItem(
                description: "新建资料夹",
                icon: Icons.create_new_folder_outlined,
                onTap: _showNewFolderDialog
              ),
              styled.buildPopupMenuItem(
                description: "保存更改",
                icon: Icons.save_outlined,
                onTap: _save
              )
            ]
          )
        ],
        context: context,
        titleTag: widget.useHero ? "folders" : null
      );
    }
    return null;
  }

  Future<void> _save() async {
    appLogger.logger.i("Saving changes in password archive");
    ui.showSnackBarQuick("正在保存", context);
    var stat = await _pwdProvider.saveArchive(_appProvider.masterPwd);
    if (mounted) {
      if (stat == ErrorCode.success) {
        _appProvider.hasUnsavedChanges = false;
        appLogger.logger.i("Saved successfully");
        ui.showSnackBarQuick("你的档案已保存", context);
      } else {
        appLogger.logger.i("Can not save archive: ${stat.code}");
        ui.showSnackBarQuick(stat.generic, context);
      }
    }
  }

  Widget _buildFolderList({
    required List<String> folders,
    required void Function((String, String)) onItemTapped,
    required bool Function((String, String)) isSelected,
    required bool isWide
  }) {
    return Container(
      alignment: Alignment.topCenter,
      padding: widget.hasPadding ? styles.pagePaddingAll : null,
      child: Container(
        constraints: isWide ? styles.tileWidthConstraintSmall : styles.tileWidthConstraint,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: folders.length,
          itemBuilder: (BuildContext context, int index) {
            final bool isFirst = index == 0;
            final bool isLast = index == folders.length - 1;
            final String displayTitle = folders[index].isEmpty ? "未分类" : folders[index];
            return Material(
              child: styled.buildListTileAdvanced(
                onRightClick: () => _showBottomSheet(title: displayTitle, folder: folders[index]),
                onTapped: () => onItemTapped(("folders", folders[index])),
                isFirst: isFirst,
                isLast: isLast,
                title: displayTitle,
                titleTag: folders[index],
                active: isSelected(("folders", folders[index])),
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
    List<String> folders = _pwdProvider.pwdFolders;
    return Scaffold(
      appBar: _buildAppBar(widget.hasAppBar),
      body: AdaptiveView(
        leftPaneBuilder: (_, isWide, onItemTapped, isSelected) => _buildFolderList(
          folders: folders, onItemTapped: onItemTapped, isSelected: isSelected, isWide: isWide
        ),
        pageBuilder: ((String, String) tag, bool isWide) {
          if (tag.$1 == "folders") {
            return PwdListPage(folder: tag.$2, useHero: !isWide, hasAppBar: !isWide, hasPadding: !isWide);
          } else {
            return styled.buildPlaceHolder(text: "未选择档案", context: context);
          }
        },
        navMode: _appProvider.currentNavMode,
        widthThreshold: styles.tileWidthConstraintSmall.maxWidth
            + styles.tileWidthConstraint.maxWidth + styles.layoutSpacing * 2
      )
    );
  }
}