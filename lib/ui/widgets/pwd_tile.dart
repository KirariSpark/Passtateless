import 'package:flutter/material.dart';
import 'package:passtateless/ui/styles.dart' as styles;

class PwdTile extends StatelessWidget {
  final Map<String, dynamic> _pwdRecord;
  final void Function()? _onStarPressed;
  final void Function()? _onEditPressed;
  final bool _hasEditButton;
  final int _alpha;
  const PwdTile({
    super.key,
    required Map<String, dynamic> pwdRecord,
    required void Function()? onStarPressed,
    void Function()? onEditPressed,
    bool hasEditButton = true,
    int alpha = 255
  }) :
    _onStarPressed = onStarPressed,
    _pwdRecord = pwdRecord,
    _onEditPressed = onEditPressed,
    _hasEditButton = hasEditButton,
    _alpha = alpha;

  @override
  Widget build(BuildContext context) {
    String subtitleText = "";
    bool hasUserName = _pwdRecord["userName"].toString().isNotEmpty;
    bool hasAccount = _pwdRecord["account"].toString().isNotEmpty;

    if (hasAccount && !hasUserName) { // 设置了账号但未设置用户名
      subtitleText = _pwdRecord["account"];
    } else if (hasUserName && !hasAccount) { // 设置了用户名但未设置账号
      subtitleText = _pwdRecord["userName"];
    } else if (!hasUserName && !hasAccount) { // 都没有设置
      subtitleText = "无效记录，添加用户名或账号";
    } else { // 都设置了
      subtitleText = "${_pwdRecord["userName"]} @ ${_pwdRecord["account"]}";
    }

    return ConstrainedBox(
      constraints: styles.tileWidthConstraint,
      child: Material(
        shape: styles.roundedBorder,
        child: ListTile(
          onTap: (){
            throw UnimplementedError("暂未实现点击复制逻辑");
          },
          shape: styles.roundedBorder,
          tileColor: ColorScheme.of(context).surfaceContainerLowest.withAlpha(_alpha),
          title: Text(_pwdRecord["identifier"] == "" ? "未命名" : _pwdRecord["identifier"]),
          subtitle: Text(subtitleText),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                style: styles.buttonStyle,
                onPressed: _onStarPressed,
                icon: _pwdRecord["starred"] ? Icon(
                  Icons.star, color: ColorScheme.of(context).primary
                ) : Icon(Icons.star_border)
              ),
              ?_hasEditButton ? IconButton(
                  style: styles.buttonStyle,
                  onPressed: _onEditPressed,
                  icon: Icon(Icons.edit_outlined)
              ) : null
            ],
          ),
        ),
      )
    );
  }
}