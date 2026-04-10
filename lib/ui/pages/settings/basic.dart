import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/ui/pages/settings/master_pwd.dart';
import 'package:passtateless/ui/pages/settings/about.dart';
import 'package:provider/provider.dart';

// 高级设置页面
class AdvancedSettingsPage extends StatelessWidget {
  const AdvancedSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('高级设置'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          style: styles.buttonStyle,
        ),
      ),
      body: Center(child: Placeholder()),
    );
  }
}

// 基础设置页面
class BasicSettingsPage extends StatelessWidget {
  const BasicSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    return Container(
      padding: styles.uniInsetsSmall,
      constraints: styles.pageWidthConstraint,
      child: SingleChildScrollView(
        child: Column(
          spacing: styles.layoutSpacing,
          children: [
            // 查看主密码
            ConstrainedBox(
              constraints: styles.pageWidthConstraint,
              child: styled.buildListTile(
                leading: Icons.visibility_outlined,
                trailing: Icon(Icons.arrow_forward),
                title: "查看主密码",
                onTapped: () {
                  ui.showAlertDialogQuick(
                    title: "危险操作",
                    content: Column(
                      spacing: styles.layoutSpacing,
                      children: [
                        const Text("你正在执行危险操作，因此需要验证密码。\n请确保你周围没有其他人会窥视到你的密码。"),
                        styled.buildTextField(
                          label: "主密码",
                          alpha: styles.alphaSemitransparent,
                          passwordMode: true,
                          context: context
                        )
                      ],
                    ),
                    action: () {
                      if (context.mounted) {
                        Navigator.pop(context);
                        ui.showInfoDialogQuick(title: "密码", content: "pwd", buttonText: "确定", context: context);
                      }
                    },
                    actionText: "确认",
                    action2: () {
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    action2Text: "取消",
                    context: context
                  );
                },
                context: context
              ),
            ),
            // 更改主密码
            ConstrainedBox(
              constraints: styles.pageWidthConstraint,
              child: styled.buildListTile(
                leading: Icons.key,
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
                leading: Icons.calendar_today,
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
            // 高级设置
            ConstrainedBox(
              constraints: styles.pageWidthConstraint,
              child: styled.buildListTile(
                context: context,
                leading: Icons.developer_mode,
                title: "高级设置",
                trailing: Icon(Icons.arrow_forward),
                onTapped: () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const AdvancedSettingsPage()));
                },
              ),
            ),
            // 关于
            ConstrainedBox(
              constraints: styles.pageWidthConstraint,
              child: styled.buildListTile(
                context: context,
                leading: Icons.info_outlined,
                title: "关于",
                trailing: Icon(Icons.arrow_forward),
                onTapped: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AboutPage()));
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}
