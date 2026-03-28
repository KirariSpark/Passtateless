import 'package:passtateless/ui/widgets/eval_res.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:zxcvbn/zxcvbn.dart';

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
      body: Container(
        alignment: Alignment.topCenter,
        child: Container(
          padding: styles.uniInsetsSmall,
          constraints: styles.pageWidthConstraint,
          child: SingleChildScrollView(
            child: Column(
              spacing: styles.layoutSpacing,
              children: <Widget>[
                styled.buildTextField(
                  context: context,
                  label: "评估对象",
                  alpha: styles.alphaSemitransparent
                ),
                EvalRes(
                  evalRes: Zxcvbn().evaluate("i am using this as password come fight me lol"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}