import 'package:flutter/material.dart';
import 'package:passtateless/ui/widgets/styled.dart' as styled;

class FullscreenPwd extends StatelessWidget {
  final String pwd;
  const FullscreenPwd(this.pwd, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: styled.buildAppBar(title: "查看密码", context: context),
      body: Center(
        child: Text(
          pwd,
          style: TextStyle(
            fontFamily: "SourceCodePro",
            fontSize: 24,
            fontWeight: FontWeight.w700
          ),
        ),
      )
    );
  }
}