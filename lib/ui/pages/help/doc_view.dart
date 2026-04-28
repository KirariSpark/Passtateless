import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;

class DocViewPage extends StatefulWidget {
  final String title;
  /// 要加载的帮助文档项
  final DocItems docItem;
  final bool useHero;
  final bool hasAppBar;
  final bool hasPadding;

  const DocViewPage({
    super.key,
    required this.title,
    required this.docItem,
    this.useHero = true,
    this.hasAppBar = true,
    this.hasPadding = true,
  });

  @override
  State<DocViewPage> createState() => _DocViewPageState();
}

class _DocViewPageState extends State<DocViewPage> {
  late final Future<String> _docFuture;

  @override
  void initState() {
    super.initState();
    _docFuture = rootBundle.loadString(widget.docItem.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.hasAppBar ? styled.buildAppBarWidget(
        title: Row(
          children: [
            const Text("帮助："),
            widget.useHero ? Hero(
              tag: widget.title,
              child: Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
            ) : Text(widget.title),
          ],
        ),
        context: context,
      ) : null,
      body: FutureBuilder<String>(
        future: _docFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '文档加载失败',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }
          final docText = snapshot.data!;
          return Container(
            padding: widget.hasPadding ? styles.pagePadding : EdgeInsets.zero,
            alignment: Alignment.topCenter,
            child: Container(
              decoration: BoxDecoration(
                color: ColorScheme.of(context).surfaceContainerLow,
                borderRadius: styles.borderRadius,
              ),
              constraints: styles.pageWidthConstraint,
              child: Markdown(data: docText),
            ),
          );
        },
      ),
    );
  }
}