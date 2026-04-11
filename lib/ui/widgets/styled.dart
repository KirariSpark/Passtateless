import 'dart:math';

import 'package:passtateless/ui/styles.dart' as styles;
import 'package:flutter/material.dart';

/// 构建预定义了风格的ListTile
///
/// [title] ListTile的标题<br>
/// [context] BuildContext context<br>
/// [leading] 位于头部的图标<br>
/// [subtitle] ListTile的副标题<br>
/// [trailing] 位于尾部的Widget<br>
/// [titleTag] 用于 Hero 动画的 tag<br>
/// [onTapped] 当ListTile被点击时，调用的函数<br>
/// [alpha] ListTile背景的透明度（0-255）<br>
/// [isFirst] 决定上方是否有圆角<br>
/// [isLast] 决定下方是否有圆角
ListTile buildListTile({
  required String title,
  required BuildContext context,
  IconData? leading,
  String? subtitle,
  Widget? trailing,
  String? titleTag,
  void Function()? onTapped,
  int? alpha,
  bool isFirst = false,
  bool isLast = false,
}) {
  return ListTile(
    onTap: onTapped,
    leading: leading == null ? null : Icon(leading),
    title: titleTag == null ? Text(title) : Hero(tag: titleTag, child: Text(title, style: Theme.of(context).textTheme.bodyLarge)),
    subtitle: subtitle == null ? null : Text(subtitle),
    trailing: trailing,
    shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.vertical(
      top: isFirst ? styles.radius : Radius.zero,
      bottom: isLast ? styles.radius : Radius.zero
    )),
    iconColor: ColorScheme.of(context).primary,
    tileColor: ColorScheme.of(context).surfaceContainerLowest.withAlpha(alpha ?? 0)
  );
}

/// 构建预定义了风格的TextField
///
/// [context] BuildContext context<br>
/// [controller] TextField 的控制器<br>
/// [onChanged] 当 TextField 发生变化时要做的事<br>
/// [label] TextField 的标签<br>
/// [alpha] 背景的透明度<br>
/// [passwordMode] 密码模式（显示内容为·）<br>
/// [multiline] 是否是多行文本框<br>
/// [readonly] 是否是只读文本框<br>
/// [maxLines] 多行文本框的最大行数<br>
TextField buildTextField({
  required BuildContext context,
  TextEditingController? controller,
  void Function(String)? onChanged,
  String? label,
  int alpha = 255,
  bool passwordMode = false,
  bool multiline = false,
  bool readonly = false,
  int maxLines = 1
}) {
  return TextField(
    controller: controller,
    onChanged: onChanged,
    decoration: InputDecoration(
      filled: true,
      fillColor: ColorScheme.of(context).surfaceContainerLowest.withAlpha(alpha),
      label: label == null ? null : Text(label),
      border: const OutlineInputBorder()
    ),
    obscureText: passwordMode,
    keyboardType: multiline ? TextInputType.multiline : null,
    maxLines: maxLines,
    minLines: 1,
    readOnly: readonly,
  );
}

/// 构建预定义了风格的AppBar
///
/// [title] 标题<br>
/// [context] BuildContext context<br>
/// [titleTag] 标题的 tag，用于 hero 动画<br>
/// [actions] 放在 AppBar 右侧的一组 Widget<br>
/// [exitIcon] 自定义退出按钮<br>
AppBar buildAppBar({
  required String title,
  required BuildContext context,
  String? titleTag,
  List<Widget>? actions,
  IconData exitIcon = Icons.arrow_back
}) {
  return buildAppBarWidget(
    title: titleTag == null ? Text(title) : Hero(tag: titleTag, child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
    context: context, exitIcon: exitIcon, actions: actions,
  );
}

/// 参考 buildAppBar
AppBar buildAppBarWidget({
  required Widget title,
  required BuildContext context,
  String? titleTag,
  List<Widget>? actions,
  IconData exitIcon = Icons.arrow_back
}) {
  final parentRoute = ModalRoute.of(context);
  bool hasLeading = false;
  if (parentRoute?.impliesAppBarDismissal ?? false) {
    hasLeading = true;
  } else {
    hasLeading = false;
  }
  return AppBar(
    leading: hasLeading ? IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: Icon(exitIcon),
      style: styles.buttonStyle,
    ) : null,
    title: title,
    actions: actions,
  );
}