import 'package:flutter/material.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;

/// 自适应双栏布局，带自定义嵌套导航
class AdaptiveView extends StatefulWidget {
  /// 构建左侧面板<br>
  /// [isWide] 当前是否为宽屏<br>
  /// [onItemTapped] 点击左侧项的回调，内部已处理宽窄屏路由分发逻辑<br>
  /// [isSelected] 判断某项是否被选中（内部已包含 isWide 判断，窄屏下永远返回 false）<br>
  final Widget Function(
    BuildContext context,
    bool isWide,
    void Function((String, String) tag) onItemTapped,
    bool Function((String, String) tag) isSelected,
  ) leftPaneBuilder;

  /// 根据选中的 tag 构建对应的右侧页面
  final Widget Function((String, String) tag, bool isWide) pageBuilder;

  /// 右侧未选择任何项时的占位符文本
  final String placeholderText;

  /// 宽屏下右侧内容区的可选约束
  final BoxConstraints? rightPaneConstraints;

  /// 内边距值
  final EdgeInsets padding;

  const AdaptiveView({
    super.key,
    required this.leftPaneBuilder,
    required this.pageBuilder,
    this.placeholderText = "未选择项目",
    this.rightPaneConstraints,
    this.padding = EdgeInsets.zero
  });

  @override
  State<AdaptiveView> createState() => _AdaptiveViewState();
}

class _AdaptiveViewState extends State<AdaptiveView> {
  (String, String)? _selectedTag;
  final GlobalKey<NavigatorState> _rightNavigatorKey = GlobalKey<NavigatorState>();

  // 点击处理逻辑
  void _onItemTapped((String, String) tag, bool isWide) {
    if (isWide) {
      setState(() {
        _selectedTag = tag;
      });
      _rightNavigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => widget.pageBuilder(tag, isWide)), (route) => false,
      );
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => widget.pageBuilder(tag, isWide)));
    }
  }

  // 判断是否选中（仅在宽屏下生效）
  bool _isSelected((String, String) tag, bool isWide) {
    return _selectedTag == tag && isWide;
  }

  // 构建右侧内容（独立 Navigator）
  Widget _buildRightContent(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 200) {
          return styled.buildPlaceHolder(text: '', context: context);
        } else if (_selectedTag != null) {
          return Navigator(
            observers: [HeroController()],
            key: _rightNavigatorKey,
            onGenerateRoute: (_) {
              return MaterialPageRoute(
                builder: (context) => widget.pageBuilder(_selectedTag!, true),
              );
            },
          );
        } else {
          return Navigator(
            observers: [HeroController()],
            key: _rightNavigatorKey,
            onGenerateRoute: (_) {
              return MaterialPageRoute(
                builder: (context) => styled.buildPlaceHolder(text: widget.placeholderText, context: context),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildWideLayout(BuildContext context, bool isWide) {
    return Container(
      key: const ValueKey('wide-layout'),
      padding: widget.padding,
      child: Row(
        spacing: styles.layoutSpacing,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.leftPaneBuilder(context, isWide, (tag) => _onItemTapped(tag, isWide), (tag) => _isSelected(tag, isWide)),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: widget.rightPaneConstraints != null
              ? ConstrainedBox(constraints: widget.rightPaneConstraints!, child: _buildRightContent(context))
              : _buildRightContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context, bool isWide) {
    return Container(
      key: const ValueKey('narrow-layout'),
      padding: widget.padding,
      alignment: Alignment.topCenter,
      child: widget.leftPaneBuilder(context, isWide, (tag) => _onItemTapped(tag, isWide), (tag) => _isSelected(tag, isWide)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isWide = constraints.maxWidth > (styles.tileWidthConstraint.maxWidth * 2 + styles.layoutSpacing);
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 100),
          child: isWide ? _buildWideLayout(context, isWide) : _buildNarrowLayout(context, isWide),
        );
      },
    );
  }
}
