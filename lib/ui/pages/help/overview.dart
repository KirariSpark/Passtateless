import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/ui/pages/help/doc_view.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/ui/widgets/styled_list_tile.dart';

class HelpOverviewPage extends StatefulWidget {
  const HelpOverviewPage({super.key});

  @override
  State<HelpOverviewPage> createState() => _HelpOverviewPageState();
}

class _HelpOverviewPageState extends State<HelpOverviewPage> {
  (String, String)? _selectedTag;

  static final double _widthThreshold =
      styles.tileWidthConstraint.maxWidth +
      styles.tileWidthConstraintSmall.maxWidth +
      styles.layoutSpacing;

  Widget _loadDoc((String, String) tag, bool isWide) {
    final mode = tag.$2;
    final docItem = DocItems.values.firstWhere((d) => d.mode == mode);
    return DocViewPage(
      title: docItem.displayName,
      docItem: docItem,
      key: ValueKey(tag),
      hasPadding: !isWide,
      hasAppBar: !isWide,
      useHero: !isWide,
    );
  }

  Widget _buildDocList(
    BuildContext context,
    bool isWide,
    void Function((String, String)) navigateTo,
    bool Function((String, String)) isSelected
  ) {
    final items = DocItems.values;
    return ConstrainedBox(
      constraints: isWide ? styles.tileWidthConstraintSmall : styles.tileWidthConstraint,
      child: ListView(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final tag = ("help", item.mode);
          final selected = isSelected(tag);
          return StyledListTileSimple(
            highlighted: selected,
            isFirst: index == 0,
            isLast: index == items.length - 1,
            title: item.displayName,
            subtitle: item.desc,
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              appLogger.logger.i("Opening doc ${item.name}");
              navigateTo(tag);
            },
          );
        }),
      ),
    );
  }

  Widget _buildRightPane(BuildContext context) {
    if (_selectedTag == null) {
      return styled.buildPlaceHolder(text: "未选择文档项", context: context);
    }
    return _loadDoc(_selectedTag!, true);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isWide = constraints.maxWidth > _widthThreshold;
        return Container(
          padding: styles.pagePaddingAll,
          child: isWide
            ? Row(
              spacing: styles.layoutSpacing,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDocList(
                  context,
                  isWide,
                  (tag) {
                    setState(() => _selectedTag = tag);
                  },
                  (tag) => _selectedTag == tag,
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _buildRightPane(context)),
              ],
            )
            : Align(
              alignment: Alignment.topCenter,
              child: _buildDocList(
                context,
                isWide,
                (tag) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => _loadDoc(tag, isWide)),
                  );
                },
                (_) => false,
              ),
            ),
        );
      },
    );
  }
}
