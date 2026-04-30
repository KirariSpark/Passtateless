import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/ui/pages/help/doc_view.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/ui/widgets/adaptive_view.dart';
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

  @override
  Widget build(BuildContext context) {
    return AdaptiveView(
      placeholderText: "未选择文档项",
      pageBuilder: _loadDoc,
      leftPaneBuilder: (context, isWide, onItemTapped, isSelected) {
        final items = DocItems.values;
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final tag = ("help", item.mode);
              final selected = isSelected(tag);
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 100),
                child: ConstrainedBox(
                  key: selected ? const ValueKey("selected") : const ValueKey("notSelected"),
                  constraints: isWide ? styles.tileWidthConstraintSmall : styles.tileWidthConstraint,
                  child: styled.buildListTile(
                    active: selected,
                    isFirst: index == 0,
                    isLast: index == items.length - 1,
                    title: item.displayName,
                    titleTag: isWide ? null : item.displayName,
                    subtitle: item.desc,
                    trailing: const Icon(Icons.arrow_forward),
                    onTapped: () {
                      appLogger.logger.i("Opening doc ${item.name}");
                      onItemTapped(tag);
                    },
                    context: context,
                  ),
                ),
              );
            }),
          ),
        );
      },
      navMode: Provider.of<AppProvider>(context, listen: false).currentNavMode,
      padding: styles.pagePaddingAll,
      widthThreshold: styles.tileWidthConstraint.maxWidth + styles.tileWidthConstraintSmall.maxWidth +
          styles.layoutSpacing,
    );
  }
}