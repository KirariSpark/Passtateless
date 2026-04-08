import 'package:flutter/material.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/widgets/styled.dart' as styled;

class MasterPwdPage extends StatefulWidget {
  const MasterPwdPage({super.key});

  @override
  State<MasterPwdPage> createState() => _MasterPwdPageState();
}

class _MasterPwdPageState extends State<MasterPwdPage> {
  bool pwdMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: styled.buildAppBar(
        title: "更改主密码",
        exitIcon: Icons.close,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                pwdMode = !pwdMode;
              });
            },
            icon: Icon(pwdMode ? Icons.visibility_outlined : Icons.visibility_off_outlined),
            style: styles.buttonStyle
          ),
          IconButton(onPressed: (){}, icon: Icon(Icons.check), style: styles.buttonStyle)
        ],
        context: context
      ),
      body: Container(
        alignment: Alignment.topCenter,
        child: Container(
          padding: styles.uniInsetsSmall,
          constraints: styles.pageWidthConstraint,
          child: SingleChildScrollView(
            child: Column(
              spacing: styles.layoutSpacing,
              children: [
                styled.buildTextField(
                  context: context,
                  label: "旧密码",
                  passwordMode: pwdMode,
                  alpha: styles.alphaSemitransparent
                ),
                styled.buildTextField(
                  context: context,
                  label: "新密码",
                  passwordMode: pwdMode,
                  alpha: styles.alphaSemitransparent
                ),
                styled.buildTextField(
                  context: context,
                  label: "确认密码",
                  passwordMode: pwdMode,
                  alpha: styles.alphaSemitransparent
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}