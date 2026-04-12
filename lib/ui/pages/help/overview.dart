import 'package:flutter/material.dart';
import 'package:passtateless/ui/pages/help/doc_view.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;

class HelpOverviewPage extends StatefulWidget {
  const HelpOverviewPage({super.key});

  @override
  State<HelpOverviewPage> createState() => _HelpOverviewPageState();
}

class _HelpOverviewPageState extends State<HelpOverviewPage> {
  String? _selectedTag;

  final List<_DocItem> _docItems = const [
    _DocItem(
      tag: "basic",
      title: "基础信息",
      subtitle: "关于无状态密码管理器和 Passtateless，你需要知道的一切",
      isFirst: true,
    ),
    _DocItem(
      tag: "faq",
      title: "常见问题",
      subtitle: "你可能会遇到的问题",
    ),
    _DocItem(
      tag: "get_started",
      title: "开始使用",
      subtitle: "第一次使用？查看此文档以快速上手",
    ),
    _DocItem(
      tag: "json",
      title: "JSON 基础",
      subtitle: "了解基础的 JSON 语法，用于编写自定义生成设置",
    ),
    _DocItem(
      tag: "formatting",
      title: "格式化与可读性",
      subtitle: "了解配置编辑器的特性，包括自动格式化、语法高亮等",
    ),
    _DocItem(
      tag: "cfg",
      title: "生成配置",
      subtitle: "了解如何自定义生成配置，可用功能及其参数",
    ),
    _DocItem(
      tag: "cfg_tips",
      title: "生成配置提示",
      subtitle: "在配置生成算法时，你应该注意的一些事情",
      isLast: true,
    ),
  ];

  Widget _buildPage(String tag, bool isWide) {
    final item = _docItems.firstWhere((item) => item.tag == tag);
    return DocViewPage(title: item.title, mode: item.tag, key: ValueKey(tag));
  }

  void _onItemTapped(_DocItem item, bool isWide) {
    if (isWide) {
      setState(() {
        _selectedTag = item.tag;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _buildPage(item.tag, isWide)),
      );
    }
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Container(
      key: const ValueKey("narrow"),
      padding: styles.pagePaddingAll,
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _buildDocTiles(context, false),
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, bool isWide) {
    return Container(
      key: const ValueKey("wide"),
      padding: styles.pagePaddingAll,
      child: Row(
        spacing: styles.layoutSpacing,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 文档项列表
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _buildDocTiles(context, true),
            ),
          ),
          // 选中项的内容
          Expanded(
            child: Container(
              constraints: styles.tileWidthConstraint,
              child: _buildRightContent(context, isWide),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightContent(BuildContext context, bool isWide) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 250) {
          return styled.buildPlaceHolder(text: "", context: context);
        } else if (_selectedTag == null) {
          return styled.buildPlaceHolder(text: "未选择文档项", context: context);
        } else {
          return AnimatedSwitcher(
            switchOutCurve: Curves.easeOutCubic,
            switchInCurve: Curves.easeOutCubic,
            duration: Duration(milliseconds: 200),
            child: _buildPage(_selectedTag!, isWide),
          );
        }
      },
    );
  }

  List<Widget> _buildDocTiles(BuildContext context, bool isWide) {
    final List<Widget> tiles = [];

    for (int i = 0; i < _docItems.length; i++) {
      final item = _docItems[i];
      final isSelected = _selectedTag == item.tag;
      final alpha = isSelected && isWide
        ? styles.alphaOpaque : styles.alphaAlmostTransparent;

      Widget tile = AnimatedSwitcher(
        duration: Duration(milliseconds: 100),
        child: ConstrainedBox(
          key: isSelected ? ValueKey("selected") : ValueKey("notSelected"),
          constraints: isWide ? styles.tileWidthConstraint : styles.tileWidthConstraintWider,
          child: styled.buildListTile(
            alpha: alpha,
            isFirst: item.isFirst,
            isLast: item.isLast,
            title: item.title,
            titleTag: isWide ? null : item.tag,
            subtitle: item.subtitle,
            trailing: const Icon(Icons.arrow_forward),
            onTapped: () => _onItemTapped(item, isWide),
            context: context,
          ),
        ),
      );

      tiles.add(tile);
    }

    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > styles.tileWidthConstraint.maxWidth * 2 + styles.layoutSpacing;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 100),
          child: isWide
              ? _buildWideLayout(context, isWide)
              : _buildNarrowLayout(context),
        );
      },
    );
  }
}

class _DocItem {
  final String tag;
  final String title;
  final String subtitle;
  final bool isFirst;
  final bool isLast;

  const _DocItem({
    required this.tag, required this.title, required this.subtitle, this.isFirst = false, this.isLast = false
  });
}
