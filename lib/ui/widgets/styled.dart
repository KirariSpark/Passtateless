import 'package:passtateless/ui/styles.dart' as styles;
import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/styles/a11y-dark.dart';
import 'package:re_highlight/styles/a11y-light.dart';

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
/// [isLast] 决定下方是否有圆角<br>
/// [active] 非active状态，颜色为surfaceContainerLow，否则为secondaryContainer
ListTile buildListTile({
  required String title,
  required BuildContext context,
  IconData? leading,
  String? subtitle,
  Widget? trailing,
  String? titleTag,
  void Function()? onTapped,
  bool isFirst = false,
  bool isLast = false,
  bool active = false,
  bool enabled = true
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
    enabled: enabled,
    iconColor: active ? ColorScheme.of(context).onSecondaryContainer : ColorScheme.of(context).onSurface,
    textColor: active ? ColorScheme.of(context).onSecondaryContainer : ColorScheme.of(context).onSurface,
    tileColor: active ? ColorScheme.of(context).secondaryContainer : ColorScheme.of(context).surfaceContainerLow,
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
  int alpha = 0,
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
      fillColor: ColorScheme.of(context).primaryContainer.withAlpha(alpha),
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

/// 构建一个占位符，比自带的好看（）
/// 
/// [text] 占位符内要显示的内容
/// [context] 上下文
Container buildPlaceHolder({
  required String text, 
  required BuildContext context
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: styles.borderRadius,
      color: ColorScheme.of(context).surfaceContainerLow
    ),
    alignment: Alignment.center,
    child: Text(text),
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
  // 决定是否展示返回键（参考官方AppBar实现）
  if (parentRoute?.impliesAppBarDismissal ?? false) {
    hasLeading = true;
  } else {
    hasLeading = false;
  }
  return AppBar(
    shape: styles.roundedBorder,
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

/// 构建一个预定义了风格的TextButton
TextButton buildTextButton({
  required Widget child,
  required BuildContext context,
  required void Function()? onPressed
}) {
  return TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: styles.borderRadius),
      backgroundColor: ColorScheme.of(context).secondaryContainer,
      foregroundColor: ColorScheme.of(context).onSecondaryContainer
    ),
    child: child,
  );
}

/// 构建一个代码编辑器，包含高亮和行指示器，配置为JSON格式
CodeEditor buildJsonEditor({
  required BuildContext context,
  CodeLineEditingController? controller,
  bool readOnly = false
}) {
  return CodeEditor(
    readOnly: readOnly,
    wordWrap: false,
    controller: controller,
    style: CodeEditorStyle(
    codeTheme: CodeHighlightTheme(
      languages: {'json': CodeHighlightThemeMode(mode: langJson)},
      theme: ColorScheme.of(context).brightness == Brightness.light ? a11YLightTheme : a11YDarkTheme),
      fontSize: 14,
      backgroundColor: ColorScheme.of(context).surfaceContainerLow
    ),
    borderRadius: styles.borderRadius,
      indicatorBuilder: (context, editingController, chunkController, notifier) {
      return Row(
        children: [
          DefaultCodeLineNumber(controller: editingController, notifier: notifier),
          DefaultCodeChunkIndicator(width: 20, controller: chunkController, notifier: notifier),
        ],
      );
    },
  );
}