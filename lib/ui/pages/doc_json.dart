import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:passtateless/modules/providers/doc_provider.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:provider/provider.dart';

class JsonDocPage extends StatelessWidget {
  const JsonDocPage({super.key});

  @override
  Widget build(BuildContext context) {
    final docProvider = Provider.of<DocProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("帮助：JSON 语法"),
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
          child: Markdown(data: docProvider.jsonDoc)
        ),
      ),
    );
  }
}