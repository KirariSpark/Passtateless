import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:passtateless/modules/providers/doc_provider.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:provider/provider.dart';

class DocPage extends StatelessWidget {
  final String title;
  final String mode;

  /// 构造函数
  ///
  /// [mode] 决定了选择哪个文档来展示，支持 json、formatting、tip和cfg
  const DocPage({super.key, required this.title, required this.mode});

  @override
  Widget build(BuildContext context) {
    final docProvider = Provider.of<DocProvider>(context);
    late final String doc;

    if (mode == "json") {
      doc = docProvider.jsonDoc;
    } else if (mode == "formatting") {
      doc = docProvider.formattingDoc;
    } else if (mode == "tip"){
      doc = docProvider.tipDoc;
    } else if (mode == "cfg"){
      doc = docProvider.cfgDoc;
    } else {
      doc = "不存在此文档";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("帮助：$title"),
        leading: IconButton(
          onPressed: () {Navigator.pop(context);},
          icon: const Icon(Icons.arrow_back_outlined),
          style: styles.buttonStyle,
        ),
      ),
      body: Container(
        padding: styles.uniInsetsSmall,
        alignment: AlignmentGeometry.topCenter,
        child: Container(
          decoration: BoxDecoration(
            color: ColorScheme.of(context).surfaceContainerLowest.withAlpha(styles.alphaSemitransparent),
            borderRadius: styles.borderRadius
          ),
          constraints: styles.pageWidthConstraint,
          child: Markdown(data: doc)
        ),
      ),
    );
  }
}