import 'package:flutter/material.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/widgets/styled.dart' as styled;

class AboutPage extends StatelessWidget {
  /// 有AppBar时，是否要使用Hero动画
  final bool useHero;
  /// 是否要包含AppBar
  final bool hasAppBar;
  /// 是否有内边距
  final bool hasPadding;
  const AboutPage({super.key, required this.useHero, this.hasPadding = true, this.hasAppBar = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hasAppBar
        ? styled.buildAppBar(title: "关于", context: context, titleTag: useHero ? "about" : null)
        : null,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: hasPadding ? styles.pagePadding : EdgeInsets.zero,
            constraints: styles.pageWidthConstraint,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/icon.png", width: 100),
                styles.spacingSizedBox,
                styles.spacingSizedBox,
                Text("Passtateless", style: Theme.of(context).textTheme.bodyLarge),
                Text("0.1.7 - beta"),
                styles.spacingSizedBox,
                TextButton(
                  onPressed: () {
                    ui.showAlertDialogQuick(
                      title: "Passtateless",
                      content: Text("Passtateless 是一个无状态密码管理器\n使用 MIT 许可证"),
                      action: () => Navigator.of(context).pop(),
                      actionText: "确定",
                      action2: () {
                        Navigator.of(context).pop();
                        showLicensePage(context: context);
                      },
                      action2Text: "许可证",
                      context: context
                    );
                  },
                  style: styles.buttonStyle,
                  child: Text("详情")
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}