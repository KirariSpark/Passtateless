import 'package:passtateless/ui/styles.dart' as styles;
import 'package:flutter/material.dart';

/// 构建预定义了风格的ListTile
///
/// [title] ListTile的标题
/// [context] BuildContext context
/// [leading] 位于头部的图标
/// [trailing] 位于尾部的Widget
/// [subtitle] ListTile的副标题
/// [onTapped] 当ListTile被点击时，调用的函数
/// [alpha] ListTile背景的透明度（0-255）
ListTile buildListTile({
  required String title,
  required BuildContext context,
  IconData? leading,
  String? subtitle,
  Widget? trailing,
  void Function()? onTapped,
  int? alpha
}) {
  return ListTile(
    onTap: onTapped,
    leading: leading == null ? null : Icon(leading),
    title: Text(title),
    subtitle: subtitle == null ? null : Text(subtitle),
    trailing: trailing,
    shape: styles.roundedBorder,
    tileColor: ColorScheme.of(context).surfaceContainerLowest.withAlpha(alpha ?? 255),
  );
}

/// 构建预定义了风格的TextField
TextField buildTextField({
  required BuildContext context,
  TextEditingController? controller,
  void Function(String)? onChanged,
  String? label,
  int alpha = 255,
  bool passwordMode = false,
  bool multiline = false,
  int? maxLines = 1
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
  );
}