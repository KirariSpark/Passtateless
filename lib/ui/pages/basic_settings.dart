import 'package:flutter/material.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/modules/core/enums.dart';

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
    // final appProvider = context.watch<AppProvider>();
    // final label = RemindDays.fromValue(appProvider.remindDays).label;

    return Container(
      padding: styles.uniInsetsSmall,
      constraints: styles.pageWidthConstraint,
      child: SingleChildScrollView(
        child: Column(
          spacing: styles.layoutSpacing,
          children: [
            Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.security,
                  color: Theme.of(context).primaryColor,
                );
              },
            ),
            // 主密码
            ConstrainedBox(
              constraints: styles.pageWidthConstraint,
              child: styled.buildTextField(
                context: context,
                label: "主密码",
                alpha: styles.alphaSemitransparent,
                passwordMode: true,
              ),
            ),
            // 提醒我更改密码
            ConstrainedBox(
              constraints: styles.pageWidthConstraint,
              child: styled.buildListTile(
                leading: Icons.calendar_today,
                title: "提醒我更改主密码",
                subtitle: "在设置的天数后，将会要求您更改主密码",
                trailing: Icon(Icons.arrow_forward),
                onTapped: () {
                  ui.showAlertQuickWidget(
                    "选择时间",
                    Column(
                      children: <Widget>[
                        Text("定期提醒您更改主密码，可以增强你的档案的安全性，并降低泄漏风险"),
                        RadioGroup(
                          groupValue: RemindDays.days180,
                          onChanged: (value) {},
                          child: Column(
                            children: <Widget>[
                              RadioListTile(value: RemindDays.days180),
                            ],
                          ),
                        ),
                      ],
                    ),
                    "",
                    context,
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => const AdvancedSettingsPage(),
                    ),
                  );
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
