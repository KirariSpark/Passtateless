import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/core/pwd_item.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/pages/pwd/edit.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled_list_tile.dart';
import 'package:provider/provider.dart';

class PwdTile extends StatelessWidget {
  /// 单个密码记录条目
  final PwdItem pwdRecord;

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

  void _deleteArchive(BuildContext context, PwdProvider pwdProvider, AppProvider appProvider) {
    appLogger.logger.i("Deleting password archive");
    final res = pwdProvider.removeRecordById(pwdRecord.id);
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

  void _newArchive(BuildContext context, PwdProvider pwdProvider,  AppProvider appProvider) {
    appLogger.logger.i("Adding empty record");
    final newId = pwdProvider.addEmptyRecord();
    appProvider.hasUnsavedChanges = true;
    appLogger.logger.i("Record added, pushing to edit page for new record $newId");
    Navigator.push(
      context, ui.switchRoute(appProvider.currentNavMode, builder: (context) => PwdEditPage(id: newId))
    );
  }

  void _editArchive(BuildContext context, AppProvider appProvider) {
    appLogger.logger.i("Pushing to edit page for ${pwdRecord.id}");
    Navigator.push(
      context, ui.switchRoute(appProvider.currentNavMode, builder: (context) => PwdEditPage(id: pwdRecord.id))
    );
  }

  String? _getAltSubtitle() {
    return pwdRecord.identifier.toString().isNotEmpty ? "原标题：${pwdRecord.identifier}" : null;
  }

  @override
  Widget build(BuildContext context) {
    final String displayName = pwdRecord.displayName;
    final pwdProvider = context.read<PwdProvider>();
    final appProvider = context.read<AppProvider>();

    if (!pwdRecord.isValid()) {
      return Material(
        child: StyledListTileSimple(
          title: "无效记录",
          subtitle: _getAltSubtitle(),
          isFirst: isFirst,
          isLast: isLast,
          onTap: () => _showDelDialog(context, pwdProvider, appProvider)
        ),
      );
    }

    return Material(
      child: StyledMenuListTile(
        menuItems: [
          PopupMenuItem(
            child: Text("编辑"),
            onTap: () => _editArchive(context, appProvider),
          ),
          PopupMenuItem(
            child: Text("删除"),
            onTap: () => _showDelDialog(context, pwdProvider, appProvider),
          ),
          PopupMenuItem(
            child: Text("新建"),
            onTap: () => _newArchive(context, pwdProvider, appProvider),
          )
        ],
        title: displayName,
        subtitle: "${pwdRecord.userName} @ ${pwdRecord.account}",
        trailing: IconButton(
          style: styles.buttonStyle,
          onPressed: () {
            appProvider.hasUnsavedChanges = true;
            pwdProvider.switchStarStateById(pwdRecord.id);
          },
          icon: pwdRecord.starred
            ? Icon(Icons.star, color: ColorScheme.of(context).primary)
            : Icon(Icons.star_border),
        ),
        onTap: onTapped,
        isFirst: isFirst,
        isLast: isLast,
        highlighted: isActive
      ),
    );
  }
}