import 'package:flutter/material.dart';
import 'package:passtateless/ui/pages/settings/change_master.dart';
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
              children: [
                // 更改主密码
                ConstrainedBox(
                  constraints: styles.tileWidthConstraint,
                  child: styled.buildListTile(
                    alpha: styles.alphaAlmostTransparent,
                    isFirst: true,
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
                  constraints: styles.tileWidthConstraint,
                  child: styled.buildListTile(
                    alpha: styles.alphaAlmostTransparent,
                    isLast: true,
                    leading: Icons.lock_clock_outlined,
                    title: "提醒我更改主密码",
                    trailing: Icon(Icons.arrow_forward),
                    onTapped: () {
                      ui.showAlertDialogQuick(
                        title: "选择时间",
                        content: Column(
                          spacing: styles.layoutSpacing,
                          children: <Widget>[
                            Text("定期提醒您更改主密码\n此行为可以增强你的档案的安全性\n也能降低数据泄漏的风险"),
                            RadioGroup(
                              groupValue: appProvider.remindMe,
                              onChanged: (value) {
                                appProvider.remindMe = value!;
                                Navigator.of(context, rootNavigator: true).pop(context);
                              },
                              child: Column(
                                children: <Widget>[
                                  for (var item in RemindDays.values) RadioListTile(
                                    value: item,
                                    title: Text(item.displayName),
                                    shape: styles.roundedBorder,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        context: context,
                        action: () {
                          if (context.mounted) {
                            Navigator.of(context, rootNavigator: true).pop(context);
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