import 'package:flutter/gestures.dart';
import "package:flutter/material.dart";
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/styles.dart' as styles;

class StyledListTileSimple extends StatelessWidget {
  /// 这个ListTile的标题文本
  final String title;

  /// 这个ListTile的副标题文本
  final String? subtitle;

  /// 这个ListTile最前面的图标
  final IconData? leadingIcon;

  /// 这个ListTile最后面的Widget
  final Widget? trailing;

  /// 这个ListTile被点击后要做什么
  final void Function()? onTap;

  /// 这个ListTile是第一个吗（若是，则上边框会有圆角）
  final bool isFirst;

  /// 这个ListTile是最后一个吗（若是，则下边框会有圆角）
  final bool isLast;

  /// 这个ListTile是否已经启用
  final bool enabled;

  /// 这个ListTile是否处于高亮状态（高亮状态下，它的颜色会有变化）
  final bool highlighted;

  /// 一个简单的ListTile，能够处理点击事件，但仅此而已。
  ///
  /// 预先定义好了样式。
  const StyledListTileSimple({
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailing,
    this.onTap,
    this.isFirst = false,
    this.isLast = false,
    this.enabled = true,
    this.highlighted = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    late final Color contentColor;
    late final Color backgroundColor;

    if (highlighted) {
      contentColor = ColorScheme.of(context).onSecondaryContainer;
      backgroundColor = ColorScheme.of(context).secondaryContainer;
    } else {
      contentColor = ColorScheme.of(context).onSurface;
      backgroundColor = ColorScheme.of(context).surfaceContainerLow;
    }

    return ListTile(
      onTap: onTap,
      leading: leadingIcon == null ? null : Icon(leadingIcon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: trailing,
      shape: RoundedRectangleBorder(
        borderRadius: ui.calcRadius(isFirst: isFirst, isLast: isLast),
      ),
      enabled: enabled,
      iconColor: contentColor,
      textColor: contentColor,
      tileColor: backgroundColor,
    );
  }
}

class StyledMenuListTile extends StatelessWidget {
  /// 这个ListTile的标题文本
  final String title;

  /// 这个ListTile的副标题文本
  final String? subtitle;

  /// 这个ListTile最前面的图标
  final IconData? leadingIcon;

  /// 这个ListTile最后面的Widget
  final Widget? trailing;

  /// 这个ListTile被点击后要做什么
  final void Function()? onTap;

  /// 这个ListTile是第一个吗（若是，则上边框会有圆角）
  final bool isFirst;

  /// 这个ListTile是最后一个吗（若是，则下边框会有圆角）
  final bool isLast;

  /// 这个ListTile是否已经启用
  final bool enabled;

  /// 这个ListTile是否处于高亮状态（高亮状态下，它的颜色会有变化）
  final bool highlighted;

  /// 上下文菜单的内容
  final List<PopupMenuEntry> menuItems;

  /// （暂时没有用处）触发上下文菜单时要做的事，若提供了它，则menuItems无效
  final void Function(TapUpDetails)? onMenuTriggered;

  /// 外观类似于StyledListTileSimple，但是具备上下文菜单。
  const StyledMenuListTile({
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailing,
    this.onTap,
    this.isFirst = false,
    this.isLast = false,
    this.enabled = true,
    this.highlighted = false,
    this.menuItems = const [],
    this.onMenuTriggered,
    super.key,
  });

  void _showMenu(PositionedGestureDetails details, BuildContext context) {
    showMenu(
      context: context,
      elevation: 1,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx, 
        details.globalPosition.dy, 
        details.globalPosition.dx, 
        details.globalPosition.dy, 
      ),
      shape: styles.roundedBorder,
      items: menuItems,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) => _showMenu(details, context),
      onSecondaryTapUp: (details) => _showMenu(details, context),
      child: StyledListTileSimple(
        title: title,
        subtitle: subtitle,
        leadingIcon: leadingIcon,
        trailing: trailing,
        onTap: onTap,
        isFirst: isFirst,
        isLast: isLast,
        enabled: enabled,
        highlighted: highlighted,
      ),
    );
  }
}
