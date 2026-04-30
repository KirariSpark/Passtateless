import 'package:flutter/cupertino.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:flutter/material.dart';

/// 计算圆角<br>
/// 通常用于决定列表中的每一个元素的圆角
BorderRadius calcRadius({bool isFirst = false, bool isLast = false}) {
  return BorderRadius.vertical(
    top: isFirst ? styles.radius : Radius.zero,
    bottom: isLast ? styles.radius : Radius.zero
  );
}

/// 便捷地显示SnackBar
void showSnackBarQuick(String content, BuildContext context) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content), showCloseIcon: true));
}

/// 便捷地显示AlertDialog
void showAlertDialogQuick({
  required String title,
  required Widget content,
  required void Function() action,
  required String actionText,
  required BuildContext context,
  void Function()? action2,
  String? action2Text,
}) {
  showDialog(
    useRootNavigator: false,
    context: context,
    builder: (context) => AlertDialog(
      scrollable: true,
      shape: styles.roundedBorder,
      title: Text(title),
      content: content,
      actions: <Widget>[
        TextButton(
          style: styles.buttonStyle,
          onPressed: action,
          child: Text(actionText),
        ),
        ?action2 == null ? null : TextButton(
          style: styles.buttonStyle,
          onPressed: action2,
          child: Text(action2Text ?? ""),
        ),
      ],
    ),
  );
}

/// 便捷地显示只有一行字和一个按钮的AlertDialog
void showInfoDialogQuick({
  required String title, required String content,
  required String buttonText, required BuildContext context
}) {
  showAlertDialogQuick(
    title: title, content: Text(content),
    action: (){Navigator.pop(context);}, 
    actionText: buttonText, context: context
  );
}

/// 便捷地显示不可撤销操作确认AlertDialog
void showConfirmDialogQuick({
  required BuildContext context, required void Function() function,
  required String title, required String info
}) {
  showAlertDialogQuick(
    title: title, content: Text(info), action: (){Navigator.of(context).pop();},
    actionText: "取消", context: context, action2: function, action2Text: "确定"
  );
}

PageRoute switchRoute(NavigatorMode mode, {required Widget Function(BuildContext) builder}) {
  if (mode == NavigatorMode.material) {
    return MaterialPageRoute(builder: builder);
  } else {
    return CupertinoPageRoute(builder: builder);
  }
}

void showBottomSheetQuick ({
  required BuildContext context,
  required String title,
  required List<Widget> children,
}) {
  List<Widget> realChildren = [Text(title, style: Theme.of(context).textTheme.titleLarge)];
  realChildren.add(Divider());
  realChildren.addAll(children);

  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(borderRadius: calcRadius(isFirst: true)),
    builder: (_) => Container(
      constraints: styles.tileWidthConstraintSmall,
      padding: styles.pagePaddingAll,
      child: SingleChildScrollView(
        child: Column(
          children: realChildren
        ),
      ),
    )
  );
}