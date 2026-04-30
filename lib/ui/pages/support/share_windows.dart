import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;

class WindowsShareGuidePage extends StatelessWidget {
  final bool hasAppBar;
  final bool hasPadding;

  const WindowsShareGuidePage({super.key, this.hasAppBar = true, this.hasPadding = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hasAppBar
        ? styled.buildAppBar(title: "分享 Windows 版本", context: context, titleTag: "share_windows")
        : null,
      body: Padding(
        padding: hasPadding ? styles.pagePadding : EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: styles.borderRadius,
            color: ColorScheme.of(context).surfaceContainerLow,
          ),
          child: Markdown(data: "Passtateless 在 Windows 上是便携版。  \n你可以直接打包压缩，然后选择合适的渠道分享。  \n请放心，你的数据不会和应用本身一起被打包。"),
        ),
      ),
    );
  }
}
