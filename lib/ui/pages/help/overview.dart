import 'package:flutter/material.dart';
import 'package:passtateless/ui/pages/help/doc_view.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/ui/widgets/adaptive_view.dart';

class HelpOverviewPage extends StatefulWidget {
  const HelpOverviewPage({super.key});

  @override
  State<HelpOverviewPage> createState() => _HelpOverviewPageState();
}

class _HelpOverviewPageState extends State<HelpOverviewPage> {
  final List<_DocItem> _docItems = const [
    _DocItem(tag: ("help", "basic"), title: "基础信息", subtitle: "本软件的介绍", isFirst: true),
    _DocItem(tag: ("help", "faq"), title: "常见问题", subtitle: "你可能会遇到的问题"),
    _DocItem(tag: ("help", "get_started"), title: "开始使用", subtitle: "查看此文档以快速上手"),
    _DocItem(tag: ("help", "json"), title: "JSON 基础", subtitle: "了解基础的 JSON 语法"),
    _DocItem(tag: ("help", "formatting"), title: "格式化与可读性", subtitle: "了解配置编辑器的特性"),
    _DocItem(tag: ("help", "cfg"), title: "生成配置", subtitle: "了解生成器的功能及其参数"),
    _DocItem(tag: ("help", "cfg_tips"), title: "生成配置提示", subtitle: "在配置生成算法时，你应该注意的一些事情", isLast: true),
  ];

  // 根据选中的 tag 构建对应的右侧页面
  Widget _buildPage((String, String) tag, bool isWide) {
    final item = _docItems.firstWhere((item) => item.tag == tag);
    return DocViewPage(
      title: item.title,
      mode: item.tag.$2,
      key: ValueKey(tag),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveView(
      placeholderText: "未选择文档项",
      pageBuilder: _buildPage,
      leftPaneBuilder: (context, isWide, onItemTapped, isSelected) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _docItems.map((item) {
              final selected = isSelected(item.tag);
              final alpha = selected ? styles.alphaOpaque : styles.alphaAlmostTransparent;
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 100),
                child: ConstrainedBox(
                  key: selected ? const ValueKey("selected") : const ValueKey("notSelected"),
                  constraints: styles.tileWidthConstraint,
                  child: styled.buildListTile(
                    alpha: alpha,
                    isFirst: item.isFirst,
                    isLast: item.isLast,
                    title: item.title,
                    titleTag: isWide ? null : item.tag.$2,
                    subtitle: item.subtitle,
                    trailing: const Icon(Icons.arrow_forward),
                    onTapped: () => onItemTapped(item.tag),
                    context: context,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _DocItem {
  final (String, String) tag;
  final String title;
  final String subtitle;
  final bool isFirst;
  final bool isLast;

  const _DocItem({
    required this.tag,
    required this.title,
    required this.subtitle,
    this.isFirst = false,
    this.isLast = false,
  });
}
