import 'package:flutter/material.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:provider/provider.dart';

class MasterPwdPage extends StatefulWidget {
  const MasterPwdPage({super.key});

  @override
  State<MasterPwdPage> createState() => _MasterPwdPageState();
}

class _MasterPwdPageState extends State<MasterPwdPage> {
  bool pwdModeOld = true;
  bool pwdModeNew = true;
  bool pwdModeConfirm = true;
  final TextEditingController _pwdOldController = TextEditingController();
  final TextEditingController _pwdNewController = TextEditingController();
  final TextEditingController _pwdConfirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ValueKey("change_master"),
      appBar: styled.buildAppBar(
        title: "更改主密码",
        titleTag: "pages/settings/change_master",
        exitIcon: Icons.close,
        context: context
      ),
      body: Container(
        alignment: Alignment.topCenter,
        child: Container(
          padding: styles.pagePadding,
          constraints: styles.tileWidthConstraint,
          child: SingleChildScrollView(
            child: Column(
              spacing: styles.layoutSpacing,
              children: [
                styles.spacingSizedBox,
                // 旧密码
                Row(
                  spacing: styles.layoutSpacing,
                  children: [
                    Expanded(
                      child: styled.buildTextField(
                        context: context,
                        label: "旧密码",
                        controller: _pwdOldController,
                        passwordMode: pwdModeOld,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          pwdModeOld = !pwdModeOld;
                        });
                      },
                      icon: Icon(pwdModeOld ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      style: styles.buttonStyle
                    ),
                  ],
                ),
                // 新密码
                Row(
                  spacing: styles.layoutSpacing,
                  children: [
                    Expanded(
                      child: styled.buildTextField(
                        context: context,
                        label: "新密码",
                        controller: _pwdNewController,
                        passwordMode: pwdModeNew,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          pwdModeNew = !pwdModeNew;
                        });
                      },
                      icon: Icon(pwdModeNew ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      style: styles.buttonStyle
                    ),
                  ],
                ),
                // 确认密码
                Row(
                  spacing: styles.layoutSpacing,
                  children: [
                    Expanded(
                      child: styled.buildTextField(
                        context: context,
                        label: "确认密码",
                        controller: _pwdConfirmController,
                        passwordMode: pwdModeConfirm,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          pwdModeConfirm = !pwdModeConfirm;
                        });
                      },
                      icon: Icon(pwdModeConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      style: styles.buttonStyle
                    ),
                  ],
                ),
                // 按钮区
                Row(
                  spacing: styles.layoutSpacing,
                  children: [
                    // 切换可见性
                    Expanded(
                      child: ElevatedButton(
                        style: styles.buttonStyle,
                        onPressed: () {
                          setState(() {
                            pwdModeOld = pwdModeNew = pwdModeConfirm = pwdModeConfirm && pwdModeNew && pwdModeOld ? false : true;
                          });
                        },
                        child: Text(pwdModeConfirm && pwdModeNew && pwdModeOld ? "全部显示" : "全部隐藏")
                      ),
                    ),
                    // 确认更改
                    Expanded(
                      child: ElevatedButton(
                        style: styles.buttonStyle,
                        onPressed: () async {
                          var res = await Provider.of<PwdProvider>(context, listen: false).changeMasterPwd(
                            currentMaster: Provider.of<AppProvider>(context, listen: false).masterPwd,
                            inputOld: _pwdOldController.text,
                            inputNew: _pwdNewController.text,
                            inputConfirm: _pwdConfirmController.text
                          );
                          if (context.mounted) {
                            ui.showSnackBarQuick(res.generic, context);
                          }
                        },
                        child: Text("确定")
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}