import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:provider/provider.dart';

class PwdTile extends StatelessWidget {
  /// 单个密码记录条目
  final Map<String, dynamic> pwdRecord;

  /// 收藏键点击时，应该做的事
  final void Function()? onStarPressed;

  /// 编辑键点击时，应该做的事
  final void Function()? onEditPressed;

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
    required this.onStarPressed,
    this.onEditPressed,
    this.onTapped,
    this.isFirst = false,
    this.isLast = false,
    this.isActive = false,
    this.useHero = true,
  });

  @override
  Widget build(BuildContext context) {
    String subtitleText = "";
    bool hasUserName = pwdRecord["userName"].toString().isNotEmpty;
    bool hasAccount = pwdRecord["account"].toString().isNotEmpty;
    final String displayName = pwdRecord["identifier"] == "" ? "未命名" : pwdRecord["identifier"];

    // 决定副标题内容
    if (hasAccount && !hasUserName) {
      // 设置了账号但未设置用户名
      subtitleText = pwdRecord["account"];
    } else if (hasUserName && !hasAccount) {
      // 设置了用户名但未设置账号
      subtitleText = pwdRecord["userName"];
    } else if (!hasUserName && !hasAccount) {
      // 都没有设置
      appLogger.logger.w("Password record ${pwdRecord["id"]} invalid");
      subtitleText = "无效记录，添加用户名或账号";
    } else {
      // 都设置了
      subtitleText = "${pwdRecord["userName"]} @ ${pwdRecord["account"]}";
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
                  onTapped: onEditPressed,
                  context: context
                ),
                styled.buildListTile(
                  leading: Icons.cut_outlined,
                  title: "移动到",
                  context: context
                ),
                styled.buildListTile(
                  leading: Icons.file_copy_outlined,
                  title: "复制到",
                  context: context
                ),
                styled.buildListTile(
                  leading: Icons.delete_outline,
                  title: "删除",
                  isLast: true,
                  onTapped: () {
                    Navigator.pop(context);
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
                  },
                  context: context
                )
              ]
            );
          },
          title: displayName,
          titleTag: useHero ? pwdRecord["id"] : null,
          subtitle: subtitleText,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                style: styles.buttonStyle,
                onPressed: onStarPressed,
                icon: pwdRecord["starred"]
                  ? Icon(Icons.star, color: ColorScheme.of(context).primary)
                  : Icon(Icons.star_border),
              )
            ],
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
