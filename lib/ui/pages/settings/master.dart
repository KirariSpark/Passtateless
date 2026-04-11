import 'package:flutter/material.dart';
import 'package:passtateless/ui/pages/settings/master_pwd.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/modules/core/enums.dart';
import 'package:provider/provider.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/ui/styles.dart' as styles;

class MasterPwdSettingsPage extends StatelessWidget {
  final bool useHero;
  const MasterPwdSettingsPage({super.key, required this.useHero});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    return Scaffold(
      appBar: styled.buildAppBar(title: "主密码", context: context, titleTag: useHero ? "masterPwd" : null),
      body: Container(
        alignment: Alignment.topCenter,
        child: Container(
          padding: styles.pagePadding,
          constraints: styles.pageWidthConstraint,
          child: SingleChildScrollView(
            child: Column(
              spacing: styles.layoutSpacing,
              children: [
                // 更改主密码
                ConstrainedBox(
                  constraints: styles.pageWidthConstraint,
                  child: styled.buildListTile(
                    leading: Icons.edit_outlined,
                    trailing: Icon(Icons.arrow_forward),
                    title: "更改主密码",
                    onTapped: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MasterPwdPage()));
                    },
                    context: context
                  ),
                ),
                // 提醒我更改密码
                ConstrainedBox(
                  constraints: styles.pageWidthConstraint,
                  child: styled.buildListTile(
                    leading: Icons.lock_clock_outlined,
                    title: "提醒我更改主密码",
                    trailing: Icon(Icons.arrow_forward),
                    onTapped: () {
                      ui.showAlertDialogQuick(
                        title: "选择时间",
                        content: Column(
                          spacing: styles.layoutSpacing,
                          children: <Widget>[
                            Text("定期提醒您更改主密码，可以增强你的档案的安全性，并降低泄漏风险"),
                            RadioGroup(
                              groupValue: appProvider.remindMe,
                              onChanged: (value) {
                                appProvider.remindMe = value!;
                                Navigator.pop(context);
                              },
                              child: Column(
                                children: <Widget>[
                                  RadioListTile(
                                    value: RemindDays.days60,
                                    title: Text(RemindDays.days60.displayName),
                                    shape: styles.roundedBorder,
                                  ),
                                  RadioListTile(
                                    value: RemindDays.days90,
                                    title: Text(RemindDays.days90.displayName),
                                    shape: styles.roundedBorder,
                                  ),
                                  RadioListTile(
                                    value: RemindDays.days180,
                                    title: Text(RemindDays.days180.displayName),
                                    shape: styles.roundedBorder,
                                  ),
                                  RadioListTile(
                                    value: RemindDays.never,
                                    title: Text(RemindDays.never.displayName),
                                    shape: styles.roundedBorder,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        context: context,
                        action: () {
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        actionText: '取消',
                      );
                    },
                    context: context,
                  ),
                ),
              ]
            )
          )
        ),
      )
    );
  }
}