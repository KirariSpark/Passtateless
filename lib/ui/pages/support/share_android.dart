import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;

class AndroidShareGuidePage extends StatelessWidget {
  final bool hasAppBar;
  final bool hasPadding;

  const AndroidShareGuidePage({super.key, this.hasAppBar = true, this.hasPadding = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hasAppBar
        ? styled.buildAppBar(title: "分享 Android 版本", context: context, titleTag: "share_android")
        : null,
      body: Padding(
        padding: hasPadding ? styles.pagePadding : EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: styles.borderRadius,
            color: ColorScheme.of(context).surfaceContainerLow,
          ),
          child: Markdown(data: "要在 Android 设备上分享软件，请在桌面长按软件图标，点击弹出菜单中的信息按钮（图标通常是i）  \n进入应用信息页面后，点击菜单按钮（通常是位于角落的三点），选择分享后，选择你习惯的渠道即可。  \n请放心，你的数据不会和应用本身一起被打包。"),
        ),
      ),
    );
  }
}
