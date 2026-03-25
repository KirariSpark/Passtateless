import 'package:passtateless/widgets/uni_styles.dart' as styles;

/// 计算Wrap组件在当前约束下应占据的宽度
/// [availableWidth]: 父容器提供的最大可用宽度
/// [useSpacing]: 是否在计算中加入间隔，true则使用layoutSpacing，false则间隔为0
/// [maxColumns]: 允许的最大列数限制，默认为100（即相当于不限制）
double calculateWrapWidth(double availableWidth, bool useSpacing, {int maxColumns = 100}) {
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
