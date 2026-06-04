import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/pages/pwd/edit.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:provider/provider.dart';

class PwdTile extends StatelessWidget {
  /// 单个密码记录条目
  final Map<String, dynamic> pwdRecord;

  /// 组件本身被点击时，应该做的事
  final void Function()? onTapped;

  /// 是否是第一项
  final bool isFirst;

  /// 是否是最后一项
  final bool isLast;

  /// 是否是被激活的项
  final bool isActive;

  /// 是否使用 Hero 动画
  final bool useHero;

  /// 右键菜单中，要额外添加的项
  final List<ListTile>? extraContextMenuItems;

  /// 用于显示密码的改版ListTile
  const PwdTile({
    super.key,
    required this.pwdRecord,
    this.onTapped,
    this.isFirst = false,
    this.isLast = false,
    this.isActive = false,
    this.useHero = true,
    this.extraContextMenuItems
  });

  void _deleteArchive(BuildContext context, PwdProvider pwdProvider, AppProvider appProvider) {
    appLogger.logger.i("Deleting password archive");
    final res = pwdProvider.removeRecordById(pwdRecord["id"]);
    if (res != ErrorCode.success) {
      appLogger.logger.e("Can not delete archive: $res");
      ui.showSnackBarQuick(res.generic, context);
      return;
    }
    appProvider.hasUnsavedChanges = true;
    appLogger.logger.i("Archive deleted");
    Navigator.pop(context);
  }

  void _showDelDialog(BuildContext context, PwdProvider pwdProvider, AppProvider appProvider) {
    ui.showConfirmDialogQuick(
      context: context,
      function: () => _deleteArchive(context, pwdProvider, appProvider),
      title: "确认删除",
      info: "一旦更改被保存，你将永远失去这条档案",
    );
  }

  void _moveOrCopy({
    required String folder,
    required BuildContext context,
    required PwdProvider pwdProvider,
    required AppProvider appProvider,
    required bool isMove
  }) {
    appLogger.logger.i("User selected folder '$folder' for ${isMove ? "moving" : "copying"} id: ${pwdRecord["id"]}");
    final ErrorCode result;
    if (isMove) {
      result = pwdProvider.moveTo(pwdRecord["id"], folder);
    } else {
      result = pwdProvider.copyTo(pwdRecord["id"], folder);
    }
    // 关闭文件夹选择对话框
    Navigator.of(context).pop();
    if (result != ErrorCode.success) {
      appLogger.logger.e("Operation failed: ${result.generic}");
      ui.showSnackBarQuick(result.generic, context);
    } else {
      appProvider.hasUnsavedChanges = true;
      appLogger.logger.i("Operation succeeded");
    }
  }

  void _showMoveCopyDialog({
    required BuildContext context,
    required PwdProvider pwdProvider,
    required AppProvider appProvider,
    required bool isMove
  }) {
    Navigator.pop(context);
    appLogger.logger.i("Showing folder picker for ${isMove ? "move" : "copy"} id: ${pwdRecord["id"]}");
    final folders = pwdProvider.pwdFolders;
    final List<Widget> tiles = [];

    for (int i = 0; i < folders.length; i++) {
      final folder = folders[i];
      final displayName = folder.isEmpty ? "未分类" : folder;
      tiles.add(
        styled.buildListTile(
          leading: Icons.folder_outlined,
          title: displayName,
          isFirst: i == 0,
          isLast: i == folders.length - 1,
          onTapped: () => _moveOrCopy(
            folder: folder,
            context: context,
            pwdProvider: pwdProvider,
            appProvider: appProvider,
            isMove: isMove
          ),
          context: context,
        ),
      );
    }

    ui.showAlertDialogQuick(
      title: isMove ? "移动到..." : "复制到...",
      content: Column(children: tiles),
      action: () {
        appLogger.logger.i("Folder picker cancelled");
        Navigator.of(context).pop();
      },
      actionText: "取消",
      context: context,
    );
  }

  void _editArchive(BuildContext context, AppProvider appProvider) {
    appLogger.logger.i("Pushing to edit page for ${pwdRecord["id"]}");
    Navigator.pop(context);
    Navigator.push(
      context, ui.switchRoute(appProvider.currentNavMode, builder: (context) => PwdEditPage(id: pwdRecord["id"]))
    );
  }

  void _showContextMenu({
    required BuildContext context,
    required String displayName,
    required PwdProvider pwdProvider,
    required AppProvider appProvider,
    List<ListTile>? extraMenuItems
  }) {
    List<Widget>? realChildren = [
      styled.buildListTile(
        leading: Icons.edit_outlined,
        title: "编辑",
        isFirst: true,
        onTapped: () => _editArchive(context, appProvider),
        context: context
      ),
      styled.buildListTile(
        leading: Icons.cut_outlined,
        title: "移动到",
        onTapped: () {
          appLogger.logger.i("User triggered move for password id: ${pwdRecord["id"]}");
          _showMoveCopyDialog(
            context: context,
            pwdProvider: pwdProvider,
            appProvider: appProvider,
            isMove: true
          );
        },
        context: context
      ),
      styled.buildListTile(
        leading: Icons.file_copy_outlined,
        title: "复制到",
        onTapped: () {
          appLogger.logger.i("User triggered copy for password id: ${pwdRecord["id"]}");
          _showMoveCopyDialog(
            context: context,
            pwdProvider: pwdProvider,
            appProvider: appProvider,
            isMove: false
          );
        },
        context: context
      ),
      styled.buildListTile(
        leading: Icons.delete_outline,
        title: "删除",
        isLast: extraMenuItems == null ? true : false,
        onTapped: () {
          Navigator.pop(context);
          _showDelDialog(context, pwdProvider, appProvider);
        },
        context: context
      )
    ];

    if (extraMenuItems != null) {
      realChildren.add(Divider(height: 1));
      realChildren.addAll(extraMenuItems);
    }

    ui.showBottomSheetQuick(
      context: context,
      title: displayName,
      children: realChildren
    );
  }

  String? _getAltSubtitle() {
    return pwdRecord.containsKey("identifier") && pwdRecord["identifier"].toString().isNotEmpty
      ? "原标题：${pwdRecord["identifier"]}" : null;
  }

  @override
  Widget build(BuildContext context) {
    final String displayName = pwdRecord["identifier"] == "" ? "未命名" : pwdRecord["identifier"];
    final pwdProvider = context.read<PwdProvider>();
    final appProvider = context.read<AppProvider>();

    if (!pwdProvider.isRecordValid(pwdRecord["id"])) {
      return Material(
        child: styled.buildListTile(
          title: "无效记录",
          subtitle: _getAltSubtitle(),
          context: context,
          isFirst: isFirst,
          isLast: isLast,
          onTapped: () => _showDelDialog(context, pwdProvider, appProvider)
        ),
      );
    }

    return Material(
      child: styled.buildListTileAdvanced(
        onRightClick: () => _showContextMenu(
          context: context,
          displayName: displayName,
          pwdProvider: pwdProvider,
          appProvider: appProvider,
          extraMenuItems: extraContextMenuItems
        ),
        title: displayName,
        titleTag: useHero ? pwdRecord["id"] : null,
        subtitle: "${pwdRecord["userName"]} @ ${pwdRecord["account"]}",
        trailing: IconButton(
          style: styles.buttonStyle,
          onPressed: () {
            appProvider.hasUnsavedChanges = true;
            pwdProvider.switchStarStateById(pwdRecord["id"]);
          },
          icon: pwdRecord["starred"]
            ? Icon(Icons.star, color: ColorScheme.of(context).primary)
            : Icon(Icons.star_border),
        ),
        onTapped: onTapped,
        isFirst: isFirst,
        isLast: isLast,
        context: context,
        active: isActive
      ),
    );
  }
}