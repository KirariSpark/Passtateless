import 'package:flutter/material.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: styled.buildAppBar(title: "关于", titleTag: "about", context: context),
      body: Center(
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
              Text("0.0.9 - alpha"),
              styles.spacingSizedBox,
              TextButton(
                onPressed: (){},
                style: styles.buttonStyle,
                child: Text("开源许可证")
              )
            ],
          ),
        ),
      ),
    );
  }
}