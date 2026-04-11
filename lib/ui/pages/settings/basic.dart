import 'package:flutter/material.dart';
import 'package:passtateless/ui/pages/settings/about.dart';
import 'package:passtateless/ui/pages/settings/master.dart';
import 'package:passtateless/ui/pages/settings/customize.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;

// 高级设置页面
class AdvancedSettingsPage extends StatelessWidget {
  const AdvancedSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: styled.buildAppBar(title: "高级设置", titleTag: "advanced", context: context),
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 主密码
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: styles.radius),
                color: ColorScheme.of(context).primaryContainer.withAlpha(styles.alphaAlmostTransparent),
              ),
              constraints: styles.tileWidthConstraint,
              child: styled.buildListTile(
                isFirst: true,
                leading: Icons.key,
                title: "主密码",
                titleTag: "masterPwd",
                trailing: Icon(Icons.arrow_forward),
                onTapped: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MasterPwdSettingsPage()));
                },
                alpha: 0,
                context: context,
              ),
            ),
            // 个性化
            Container(
              color: ColorScheme.of(context).primaryContainer.withAlpha(styles.alphaAlmostTransparent),
              constraints: styles.tileWidthConstraint,
              child: styled.buildListTile(
                leading: Icons.color_lens_outlined,
                title: "个性化",
                titleTag: "customize",
                trailing: Icon(Icons.arrow_forward),
                onTapped: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CustomizeSettingsPage()));
                },
                alpha: 0,
                context: context,
              ),
            ),
            // 高级设置
            Container(
              color: ColorScheme.of(context).primaryContainer.withAlpha(styles.alphaAlmostTransparent),
              constraints: styles.tileWidthConstraint,
              child: styled.buildListTile(
                context: context,
                leading: Icons.developer_mode,
                title: "高级设置",
                titleTag: "advanced",
                trailing: Icon(Icons.arrow_forward),
                onTapped: () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const AdvancedSettingsPage()));
                },
                alpha: 0
              ),
            ),
            // 关于
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(bottom: styles.radius),
                color: ColorScheme.of(context).primaryContainer.withAlpha(styles.alphaAlmostTransparent),
              ),
              constraints: styles.tileWidthConstraint,
              child: styled.buildListTile(
                context: context,
                leading: Icons.info_outlined,
                title: "关于",
                titleTag: "about",
                trailing: Icon(Icons.arrow_forward),
                onTapped: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AboutPage()));
                },
                alpha: 0,
                isLast: true
              ),
            ),
          ],
        ),
      ),
    );
  }
}
