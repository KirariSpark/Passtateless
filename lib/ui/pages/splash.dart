import 'package:flutter/material.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final TextEditingController pwdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: styles.tileWidthConstraint,
        padding: styles.uniInsetsSmall,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: styles.layoutSpacing,
            children: [
              Image.asset(
                "assets/icon.png",
                width: 100,
              ),
              styles.spacingSizedBox,
              Text(
                "Passtateless 已被锁定",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Column(
                children: [
                  Text("请输入你的主密码以继续"),
                  Text("若你是第一次使用，则会自动创建主密码")
                ],
              ),
              styles.spacingSizedBox,
              styled.buildTextField(
                context: context,
                passwordMode: true,
                controller: pwdController,
                alpha: styles.alphaSemitransparent
              ),
              TextButton(
                onPressed: (){},
                style: styles.buttonStyle,
                child: Text("确定"),
              )
            ],
          ),
        ),
      ),
    );
  }
}