import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:passtateless/modules/providers/doc_provider.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:provider/provider.dart';

class DocViewPage extends StatelessWidget {
  final String title;
  final String mode;

  /// 构造函数
  ///
  /// [mode] 决定了选择哪个文档来展示，支持的值和文档目录中文档的文件名相同
  const DocViewPage({super.key, required this.title, required this.mode});

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
      appBar: styled.buildAppBar(title: "帮助：$title", context: context),
      body: Container(
        padding: styles.uniInsetsSmall,
        alignment: AlignmentGeometry.topCenter,
        child: Container(
          decoration: BoxDecoration(
            color: ColorScheme.of(context).surfaceContainerLowest.withAlpha(styles.alphaSemitransparent),
            borderRadius: styles.borderRadius,
          ),
          constraints: styles.pageWidthConstraint,
          child: Markdown(data: doc),
        ),
      ),
    );
  }
}
