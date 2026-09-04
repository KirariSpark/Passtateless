import 'package:passtateless/ui/styles.dart' as styles;
import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/styles/a11y-dark.dart';
import 'package:re_highlight/styles/a11y-light.dart';

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
  int maxLines = 1,
}) {
  return TextField(
    controller: controller,
    onChanged: onChanged,
    decoration: InputDecoration(
      filled: true,
      fillColor: ColorScheme.of(context).primaryContainer.withAlpha(alpha),
      label: label == null ? null : Text(label),
      border: const OutlineInputBorder(),
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
/// [text] 占位符内要显示的内容<br>
/// [context] 上下文
Container buildPlaceHolder({
  required String text,
  required BuildContext context,
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: styles.borderRadius,
      color: ColorScheme.of(context).surfaceContainerLow,
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
  IconData exitIcon = Icons.arrow_back,
}) {
  return buildAppBarWidget(
    title: titleTag == null
      ? Text(title)
      : Hero(tag: titleTag, child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
    context: context,
    exitIcon: exitIcon,
    actions: actions
  );
}

/// 参考 buildAppBar
AppBar buildAppBarWidget({
  required Widget title,
  required BuildContext context,
  String? titleTag,
  List<Widget>? actions,
  IconData exitIcon = Icons.arrow_back,
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
    leading: hasLeading
      ? IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(exitIcon),
        style: styles.buttonStyle,
      )
      : null,
    title: title,
    backgroundColor: ColorScheme.of(context).surfaceContainer,
    actions: actions,
  );
}

/// 构建一个预定义了风格的TextButton
TextButton buildTextButton({
  required Widget child,
  required BuildContext context,
  required void Function()? onPressed,
  bool highlighted = true
}) {
  final currentScheme = ColorScheme.of(context);
  final backgroundColor = highlighted ? currentScheme.secondaryContainer : currentScheme.surfaceContainerLow;
  final foregroundColor = highlighted ? currentScheme.onSecondaryContainer : currentScheme.onSurface;
  return TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: styles.borderRadius),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    ),
    child: child,
  );
}

/// 构建一个预定义了风格的ElevatedButton
ElevatedButton buildElevatedButton({
  required Widget child,
  required BuildContext context,
  required void Function()? onPressed,
}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: ColorScheme.of(context).secondaryContainer,
      foregroundColor: ColorScheme.of(context).onSecondaryContainer,
      shape: styles.roundedBorder,
      padding: styles.pagePaddingAll,
    ),
    child: child,
  );
}

/// 构建一个预定义了风格的PopupMenuButton
PopupMenuButton buildPopupMenuButton({
  required List<PopupMenuItem> children,
  required BuildContext context,
  IconData icon = Icons.more_vert
}) {
  return PopupMenuButton(
    style: styles.buttonStyle,
    icon: Icon(icon),
    color: ColorScheme.of(context).secondaryContainer,
    itemBuilder: (_) => children,
  );
}

/// 构建一个PopupMenuItem，支持显示图标和文字
PopupMenuItem buildPopupMenuItem({
  required String description,
  void Function()? onTap,
  IconData? icon
}) {
  return PopupMenuItem(
    onTap: onTap,
    child: Row(
      spacing: styles.layoutSpacing,
      children: [Icon(icon), Text(description)],
    ),
  );
}

/// 构建一个代码编辑器，包含高亮和行指示器，配置为JSON格式
CodeEditor buildJsonEditor({
  required BuildContext context,
  CodeLineEditingController? controller,
  bool readOnly = false,
}) {
  return CodeEditor(
    readOnly: readOnly,
    wordWrap: false,
    controller: controller,
    style: CodeEditorStyle(
      codeTheme: CodeHighlightTheme(
        languages: {'json': CodeHighlightThemeMode(mode: langJson)},
        theme: ColorScheme.of(context).brightness == Brightness.light
            ? a11YLightTheme
            : a11YDarkTheme,
      ),
      fontFamily: "SourceCodePro",
      fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
      backgroundColor: ColorScheme.of(context).surfaceContainerLow,
    ),
    borderRadius: styles.borderRadius,
    indicatorBuilder: (context, editingController, chunkController, notifier) {
      return Row(
        children: [
          DefaultCodeLineNumber(
            controller: editingController,
            notifier: notifier,
          ),
          DefaultCodeChunkIndicator(
            width: 20,
            controller: chunkController,
            notifier: notifier,
          ),
        ],
      );
    },
  );
}
