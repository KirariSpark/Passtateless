import 'package:flutter/material.dart';
import 'package:passtateless/ui/styles.dart' as styles;

/// 可展开的浮动操作按钮（竖排展开）。
///
/// 点击主按钮后，[children] 会从 FAB 位置垂直向上展开并淡入；
/// 再次点击关闭按钮（X）或主按钮时收起。
///
/// [distance] 控制子组件整体向上移动的距离。
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    this.initialOpen,
    required this.distance,
    required this.children,
  });

  /// 是否初始即展开
  final bool? initialOpen;
  /// 子组件展开时向上移动的最大距离
  final double distance;
  /// 展开后显示的子组件列表（竖排排列）
  final List<Widget> children;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          // 展开后显示的关闭按钮
          _buildTapToCloseFab(),
          // 竖排展开的子组件整体
          _buildExpandingActionButtons(),
          // 未展开时显示的主编辑按钮
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  /// 关闭按钮
  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56,
      height: 56,
      child: Center(
        child: Material(
          shape: styles.roundedBorder,
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: styles.uniInsetsSmall,
              child: Icon(Icons.close),
            ),
          ),
        ),
      ),
    );
  }

  /// 带动画的子组件整体
  Widget _buildExpandingActionButtons() {
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        return Positioned(
          right: 4.0,
          bottom: 4.0 + _expandAnimation.value * widget.distance,
          child: FadeTransition(
            opacity: _expandAnimation,
            child: child!,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: styles.layoutSpacing,
        children: widget.children,
      ),
    );
  }

  /// 打开按钮
  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeOutCubic),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            onPressed: _toggle,
            shape: styles.roundedBorder,
            child: const Icon(Icons.menu_outlined),
          ),
        ),
      ),
    );
  }
}