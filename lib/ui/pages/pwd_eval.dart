import 'package:passtateless/ui/widgets/eval_res.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class PwdEvalPage extends StatelessWidget {
  const PwdEvalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("评估密码"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_outlined),
          style: styles.buttonStyle,
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: styles.pageWidthConstraint,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(

                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}