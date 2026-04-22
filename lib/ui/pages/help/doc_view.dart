import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:passtateless/modules/providers/doc_provider.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:provider/provider.dart';

class DocViewPage extends StatelessWidget {
  final String title;
  /// 决定了选择哪个文档来展示，支持的值和文档目录中文档的文件名相同
  final String mode;
  /// 有AppBar时，是否要使用Hero动画
  final bool useHero;
  /// 是否要包含AppBar
  final bool hasAppBar;
  /// 是否有内边距
  final bool hasPadding;

  const DocViewPage({
    super.key,
    required this.title,
    required this.mode,
    this.useHero = true,
    this.hasPadding = true,
    this.hasAppBar = true
  });

  @override
  Widget build(BuildContext context) {
    final docProvider = Provider.of<DocProvider>(context);
    late final String doc;

    if (mode == "json") {
      doc = docProvider.jsonDoc;
    } else if (mode == "formatting") {
      doc = docProvider.formattingDoc;
    } else if (mode == "cfg_tips") {
      doc = docProvider.tipDoc;
    } else if (mode == "cfg") {
      doc = docProvider.cfgDoc;
    } else if (mode == "basic") {
      doc = docProvider.basicDoc;
    } else if (mode == "faq") {
      doc = docProvider.faqDoc;
    } else if (mode == "get_started") {
      doc = docProvider.getStartedDoc;
    } else {
      doc = "不存在此文档";
    }

    return Scaffold(
      appBar: hasAppBar ? styled.buildAppBarWidget(
        title: Row(
          children: [
            Text("帮助："),
            useHero ? Hero(tag: mode, child: Text(title, style: Theme.of(context).textTheme.titleLarge)) : Text(title)
          ],
        ), context: context
      ) : null,
      body: Container(
        padding: hasPadding ? styles.pagePadding : EdgeInsets.zero,
        alignment: AlignmentGeometry.topCenter,
        child: Container(
          decoration: BoxDecoration(
            color: ColorScheme.of(context).surfaceContainerLow,
            borderRadius: styles.borderRadius,
          ),
          constraints: styles.pageWidthConstraint,
          child: Markdown(data: doc),
        ),
      ),
    );
  }
}
