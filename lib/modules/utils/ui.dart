import 'package:passtateless/ui/widgets/uni_styles.dart' as styles;
import 'package:flutter/material.dart';

/// 计算宽度约束
/// [availableWidth]: 父容器提供的最大可用宽度
/// [useSpacing]: 是否在计算中加入间隔，true则使用layoutSpacing，false则间隔为0
/// [maxColumns]: 允许的最大列数限制，默认为100（即相当于不限制）
double calcWidthConstraint(double availableWidth, bool useSpacing, {int maxColumns = 100}) {
  final double tileWidth = styles.tileWidthConstraint.maxWidth;
  final double spacing = useSpacing ? styles.layoutSpacing : 0.0;

  if (tileWidth <= 0) return availableWidth;

  // 计算可用宽度下自然排列的列数
  int columns = ((availableWidth + spacing) / (tileWidth + spacing)).floor();

  // 使用 clamp 限制列数范围：最少1列，最多 maxColumns 列
  columns = columns.clamp(1, maxColumns);

  // 计算总宽度：n个Tile宽度 + (n-1)个间隔
  return columns * tileWidth + (columns - 1) * spacing;
}

/// 便捷地显示SnackBar
void showSnackBarQuick(String content, BuildContext context) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(content),
    showCloseIcon: true,
  ));
}

/// 便捷地显示只有一行字和一个按钮的AlertDialog
void showAlertQuick(String title, String content, String buttonText, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: styles.uniRoundedBorder,
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          style: styles.uniButtonStyle,
          onPressed: () {Navigator.pop(context);},
          child: Text(buttonText)
        )
      ],
    )
  );
}
/// 便捷地显示只有一个按钮的AlertDialog，它的内容是一个Widget而非字符串
void showAlertQuickWidget(String title, Widget content, String buttonText, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: styles.uniRoundedBorder,
      title: Text(title),
      content: content,
      actions: [
        TextButton(
          style: styles.uniButtonStyle,
          onPressed: () {Navigator.pop(context);},
          child: Text(buttonText)
        )
      ],
    )
  );
}

/// 便捷地显示不可撤销操作确认AlertDialog
void showConfirmDialogQuick(BuildContext context, VoidCallback? function, String title) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: styles.uniRoundedBorder,
      title: Text(title),
      content: const Text("此操作不可撤销"),
      actions: [
        // 取消
        TextButton(
          style: styles.uniButtonStyle,
          onPressed: () => Navigator.pop(context),
          child: const Text("取消")
        ),
        // 确定
        TextButton(
            style: styles.uniButtonStyle,
          onPressed: function,
          child: Text(
            "确定",
            style: TextStyle(
              color: Theme.of(context).colorScheme.error
            ),
          )
        )
      ],
    )
  );
}