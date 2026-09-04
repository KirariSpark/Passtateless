import 'package:flutter/material.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;

class AboutPage extends StatelessWidget {
  /// 是否要包含AppBar
  final bool hasAppBar;

  /// 是否有内边距
  final bool hasPadding;

  const AboutPage({super.key, this.hasPadding = true, this.hasAppBar = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hasAppBar ? styled.buildAppBar(title: "关于", context: context) : null,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: hasPadding ? styles.pagePaddingHorizontal : EdgeInsets.zero,
            constraints: styles.pageWidthConstraint,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/icon.png", width: 100),
                styles.spacingSizedBox,
                Text("Passtateless", style: Theme.of(context).textTheme.bodyLarge),
                Text("0.2.0 - alpha 2"),
                styles.spacingSizedBox,
                styled.buildTextButton(
                  onPressed: () => showLicensePage(context: context),
                  child: Text("许可证"),
                  context: context,
                  highlighted: false
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}