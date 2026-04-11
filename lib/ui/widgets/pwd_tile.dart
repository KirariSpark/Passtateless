import 'package:flutter/material.dart';
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/ui/styles.dart' as styles;

class PwdTile extends StatelessWidget {
  final Map<String, dynamic> pwdRecord;
  final void Function()? _onStarPressed;
  final void Function()? _onEditPressed;
  final void Function()? _onTapped;
  final bool hasEditButton;
  final bool isFirst;
  final bool isLast;

  /// 用于显示密码的改版ListTile
  const PwdTile({
    super.key,
    required this.pwdRecord,
    required void Function()? onStarPressed,
    void Function()? onEditPressed,
    void Function()? onTapped,
    this.hasEditButton = true,
    this.isFirst = false,
    this.isLast = false
  }) :
    _onStarPressed = onStarPressed,
    _onEditPressed = onEditPressed,
    _onTapped = onTapped;

  @override
  Widget build(BuildContext context) {
    String subtitleText = "";
    bool hasUserName = pwdRecord["userName"].toString().isNotEmpty;
    bool hasAccount = pwdRecord["account"].toString().isNotEmpty;

    if (hasAccount && !hasUserName) { // 设置了账号但未设置用户名
      subtitleText = pwdRecord["account"];
    } else if (hasUserName && !hasAccount) { // 设置了用户名但未设置账号
      subtitleText = pwdRecord["userName"];
    } else if (!hasUserName && !hasAccount) { // 都没有设置
      subtitleText = "无效记录，添加用户名或账号";
    } else { // 都设置了
      subtitleText = "${pwdRecord["userName"]} @ ${pwdRecord["account"]}";
    }

    return ConstrainedBox(
      constraints: styles.tileWidthConstraint,
      child: styled.buildListTile(
        title: pwdRecord["identifier"] == "" ? "未命名" : pwdRecord["identifier"],
        subtitle: subtitleText,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              style: styles.buttonStyle,
              onPressed: _onStarPressed,
              icon: pwdRecord["starred"] ? Icon(
                Icons.star, color: ColorScheme.of(context).primary
              ) : Icon(Icons.star_border)
            ),
            ?hasEditButton ? IconButton(
              style: styles.buttonStyle,
              onPressed: _onEditPressed,
              icon: Icon(Icons.edit_outlined)
            ) : null
          ],
        ),
        onTapped: _onTapped,
        isFirst: isFirst,
        isLast: isLast,
        context: context
      )
    );
  }
}