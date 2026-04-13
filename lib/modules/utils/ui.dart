import 'package:passtateless/ui/styles.dart' as styles;
import 'package:flutter/material.dart';

/// 计算宽度约束<br>
/// [availableWidth]: 父容器提供的最大可用宽度<br>
/// [useSpacing]: 是否在计算中加入间隔<br>
/// [maxColumns]: 允许的最大列数限制，默认为100（即相当于不限制）<br>
/// [usePadding]: 是否在计算时引入内边距<br>
double calcWidthConstraint(
  double availableWidth,
  bool useSpacing, {
  int maxColumns = 100,
  bool usePadding = false,
}) {
  final double tileWidth = styles.tileWidthConstraint.maxWidth;
  final double spacing = useSpacing ? styles.layoutSpacing : 0.0;
  final double padding = usePadding ? styles.layoutSpacing : 0.0;

  if (tileWidth <= 0) return availableWidth;

  // 1. 计算除去内边距后的实际内容可用宽度
  final double effectiveWidth = availableWidth - padding * 2;

  // 2. 在有效宽度下计算自然排列的列数
  // 公式推导：n * tileWidth + (n-1) * spacing <= effectiveWidth
  int columns = ((effectiveWidth + spacing) / (tileWidth + spacing)).floor();

  // 3. 使用 clamp 限制列数范围：最少1列，最多 maxColumns 列
  columns = columns.clamp(1, maxColumns);

  // 4. 计算总宽度：n个Tile宽度 + (n-1)个间隔 + 左右内边距
  return columns * tileWidth + (columns - 1) * spacing + padding * 2;
}

/// 便捷地显示SnackBar
void showSnackBarQuick(String content, BuildContext context) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(content), showCloseIcon: true));
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
    title: title, content: Text(info), action: (){Navigator.of(context, rootNavigator: true).pop();},
    actionText: "取消", context: context, action2: function, action2Text: "确定"
  );
}
