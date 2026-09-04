import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/ui/pages/help/doc_view.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/adaptive_view.dart';
import 'package:passtateless/ui/widgets/styled_list_tile.dart';
import 'package:provider/provider.dart';

class HelpOverviewPage extends StatelessWidget {
  const HelpOverviewPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    return AdaptiveView(
      placeholderText: "未选择文档项",
      pageBuilder: _loadDoc,
      leftPaneBuilder: _buildDocList,
      navMode: context.read<AppProvider>().currentNavMode,
      padding: styles.pagePaddingAll,
      widthThreshold: styles.tileWidthConstraint.maxWidth + styles.tileWidthConstraintSmall.maxWidth +
          styles.layoutSpacing,
    );
  }
}