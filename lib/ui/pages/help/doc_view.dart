import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;

class DocViewPage extends StatelessWidget {
  /// 页面标题
  final String title;
  /// 决定了选择哪个文档来展示
  final String docText;
  /// 有AppBar时，是否要使用Hero动画
  final bool useHero;
  /// 是否要包含AppBar
  final bool hasAppBar;
  /// 是否有内边距
  final bool hasPadding;

  const DocViewPage({
    super.key,
    required this.title,
    required this.docText,
    this.useHero = true,
    this.hasPadding = true,
    this.hasAppBar = true
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hasAppBar ? styled.buildAppBarWidget(
        title: Row(
          children: [
            Text("帮助："),
            useHero ? Hero(tag: title, child: Text(title, style: Theme.of(context).textTheme.titleLarge)) : Text(title)
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
          child: Markdown(data: docText),
        ),
      ),
    );
  }
}
