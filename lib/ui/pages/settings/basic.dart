import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/pages/settings/about.dart';
import 'package:passtateless/ui/pages/settings/master_pwd.dart';
import 'package:passtateless/ui/pages/settings/master.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
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
    return Container(
      padding: styles.pagePaddingAll,
      constraints: styles.pageWidthConstraint,
      child: SingleChildScrollView(
        child: Column(
          spacing: styles.layoutSpacing,
          children: [
            // 主密码
            ConstrainedBox(
              constraints: styles.pageWidthConstraint,
              child: styled.buildListTile(
                leading: Icons.key,
                title: "主密码",
                trailing: Icon(Icons.arrow_forward),
                onTapped: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MasterPwdSettingsPage()));
                },
                context: context,
              ),
            ),
            // 个性化
            ConstrainedBox(
              constraints: styles.pageWidthConstraint,
              child: styled.buildListTile(
                leading: Icons.color_lens_outlined,
                title: "个性化",
                trailing: Icon(Icons.arrow_forward),
                onTapped: () {
                  ui.showSnackBarQuick("Coming S∞n", context);
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
