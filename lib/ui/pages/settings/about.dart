import 'package:flutter/material.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/widgets/styled.dart' as styled;

class AboutPage extends StatelessWidget {
  final bool useHero;
  const AboutPage({super.key, required this.useHero});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: styled.buildAppBar(title: "关于", context: context, titleTag: useHero ? "about" : null),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: styles.uniInsetsSmall,
            constraints: styles.pageWidthConstraint,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/icon.png",
                  width: 100,
                ),
                styles.spacingSizedBox,
                styles.spacingSizedBox,
                Text(
                  "Passtateless",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text("0.0.10 - alpha"),
                styles.spacingSizedBox,
                TextButton(
                  onPressed: () {
                    ui.showAlertDialogQuick(
                      title: "Passtateless",
                      content: Text("Passtateless 是一个无状态密码管理器\n使用 Apache 2.0 许可证"),
                      action: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      actionText: "确定",
                      action2: () {
                        Navigator.of(context, rootNavigator: true).pop();
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