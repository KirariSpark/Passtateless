import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/ui/pages/help/doc_view.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/ui/widgets/adaptive_view.dart';
import 'package:provider/provider.dart';

class HelpOverviewPage extends StatefulWidget {
  const HelpOverviewPage({super.key});

  @override
  State<HelpOverviewPage> createState() => _HelpOverviewPageState();
}

class _HelpOverviewPageState extends State<HelpOverviewPage> {
  DocItems? _currentLoadingItem;
  String _currentDocText = "正在加载";

  // 根据选中的 tag 构建对应的右侧页面
  Widget _loadDoc((String, String) tag, bool isWide) {
    final mode = tag.$2;
    final docItem = DocItems.values.firstWhere((d) => d.mode == mode);
    return DocViewPage(
      title: docItem.displayName,
      docText: _currentDocText,
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
                  constraints: styles.tileWidthConstraint,
                  child: styled.buildListTile(
                    enabled: _currentLoadingItem == null,
                    active: selected,
                    isFirst: index == 0,
                    isLast: index == items.length - 1,
                    title: item.displayName,
                    titleTag: isWide ? null : item.mode,
                    subtitle: item.desc,
                    trailing: _currentLoadingItem == item
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator())
                      : Icon(Icons.arrow_forward),
                    onTapped: () async {
                      appLogger.logger.i("Loading doc ${item.name}");
                      setState(() {
                        _currentLoadingItem = item;
                        _currentDocText = "正在加载";
                      });
                      final res = await rootBundle.loadString(item.path);
                      setState(() {
                        _currentLoadingItem = null;
                        _currentDocText = res;
                      });
                      appLogger.logger.i("Successfully loaded doc");
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
    );
  }
}