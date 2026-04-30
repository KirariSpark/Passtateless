import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
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

  /// 是否是第二项
  final bool isLast;

  /// 是否是被激活的项
  final bool isActive;

  /// 是否使用 Hero 动画
  final bool useHero;

  /// 用于显示密码的改版ListTile
  const PwdTile({
    super.key,
    required this.pwdRecord,
    this.onTapped,
    this.isFirst = false,
    this.isLast = false,
    this.isActive = false,
    this.useHero = true,
  });

  void _confirmDel(BuildContext context) {
    ui.showConfirmDialogQuick(
      context: context,
      function: () {
        appLogger.logger.i("Deleting password archive");
        final res = Provider.of<PwdProvider>(context, listen: false).removeRecordById(pwdRecord["id"]);
        if (res != ErrorCode.success) {
          appLogger.logger.e("Can not delete archive: $res");
          ui.showSnackBarQuick(res.generic, context);
        }
        appLogger.logger.i("Archive deleted");
        Navigator.pop(context);
      },
      title: "确认删除",
      info: "你无法撤销此操作",
    );
  }

  /// 显示移动或复制到的文件夹选择对话框
  void _showMoveCopyDialog(BuildContext context, PwdProvider pwdProvider, bool isMove) {
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
          onTapped: () {
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
              appLogger.logger.i("Operation succeeded");
            }
          },
          context: context,
        ),
      );
    }

    ui.showAlertDialogQuick(
      title: isMove ? "移动到..." : "复制到...",
      content: SingleChildScrollView(
        child: Column(children: tiles),
      ),
      action: () {
        appLogger.logger.i("Folder picker cancelled");
        Navigator.of(context).pop();
      },
      actionText: "取消",
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pwdProvider = Provider.of<PwdProvider>(context, listen: false);
    String subtitleText = "";
    final String displayName = pwdRecord["identifier"] == "" ? "未命名" : pwdRecord["identifier"];

    if (pwdProvider.isRecordValid(pwdRecord["id"])) {
      subtitleText = "${pwdRecord["userName"]} @ ${pwdRecord["account"]}";
    } else {
      return ConstrainedBox(
        constraints: styles.tileWidthConstraint,
        child: Material(
          child: styled.buildListTile(
            title: "无效记录",
            subtitle: pwdRecord.containsKey("identifier") && pwdRecord["identifier"].toString().isNotEmpty
              ? "原标题：${pwdRecord["identifier"]}" : null,
            context: context,
            isFirst: isFirst,
            isLast: isLast,
            onTapped: () => _confirmDel(context)
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: styles.tileWidthConstraint,
      child: Material(
        child: styled.buildListTileAdvanced(
          onRightClick: () {
            ui.showBottomSheetQuick(
              context: context,
              title: displayName,
              children: [
                styled.buildListTile(
                  leading: Icons.edit_outlined,
                  title: "编辑",
                  isFirst: true,
                  onTapped: (){
                    appLogger.logger.i("Pushing to edit page for ${pwdRecord["id"]}");
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PwdEditPage(id: pwdRecord["id"])));
                  },
                  context: context
                ),
                styled.buildListTile(
                  leading: Icons.cut_outlined,
                  title: "移动到",
                  onTapped: () {
                    appLogger.logger.i("User triggered move for password id: ${pwdRecord["id"]}");
                    Navigator.pop(context);
                    _showMoveCopyDialog(context, pwdProvider, true);
                  },
                  context: context
                ),
                styled.buildListTile(
                  leading: Icons.file_copy_outlined,
                  title: "复制到",
                  onTapped: () {
                    appLogger.logger.i("User triggered copy for password id: ${pwdRecord["id"]}");
                    Navigator.pop(context);
                    _showMoveCopyDialog(context, pwdProvider, false);
                  },
                  context: context
                ),
                styled.buildListTile(
                  leading: Icons.delete_outline,
                  title: "删除",
                  isLast: true,
                  onTapped: () {
                    Navigator.pop(context);
                    _confirmDel(context);
                  },
                  context: context
                )
              ]
            );
          },
          title: displayName,
          titleTag: useHero ? pwdRecord["id"] : null,
          subtitle: subtitleText,
          trailing: IconButton(
            style: styles.buttonStyle,
            onPressed: () => pwdProvider.switchStarStateById(pwdRecord["id"]),
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
      ),
    );
  }
}