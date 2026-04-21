import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/pages/settings/change_master.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/ui/widgets/adaptive_view.dart';
import 'package:provider/provider.dart';

/// 主密码设置页面
class MasterPwdSettingsPage extends StatelessWidget {
  /// 有AppBar时，是否要使用Hero动画
  final bool useHero;
  /// 是否要包含AppBar
  final bool hasAppBar;
  /// 是否有内边距
  final bool hasPadding;
  const MasterPwdSettingsPage({super.key, required this.useHero, this.hasAppBar = true, this.hasPadding = true});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    return Scaffold(
      appBar: hasAppBar
        ? styled.buildAppBar(title: "主密码", context: context, titleTag: useHero ? "masterPwd" : null)
        : null,
      body: AdaptiveView(
        leftPaneBuilder: (context, isWide, onItemTapped, isSelected) {
          return Container(
            alignment: Alignment.topCenter,
            child: Container(
              padding: hasPadding ? styles.pagePadding : EdgeInsets.zero,
              constraints: styles.pageWidthConstraint,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 更改主密码
                    ConstrainedBox(
                      constraints: styles.tileWidthConstraint,
                      child: styled.buildListTile(
                        active: isSelected(("master","change")),
                        isFirst: true,
                        leading: Icons.edit_outlined,
                        trailing: Icon(Icons.arrow_forward),
                        title: "更改主密码",
                        titleTag: "pages/settings/change_master",
                        onTapped: () {
                          onItemTapped(("master", "change"));
                        },
                        context: context
                      ),
                    ),
                    // 提醒我更改密码
                    ConstrainedBox(
                      constraints: styles.tileWidthConstraint,
                      child: styled.buildListTile(
                        active: isSelected(("master","remind")),
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
                                Text("你的主密码会在设置的天数后失效，并需要重新设置\n此行为可以增强你的档案的安全性，也能降低数据泄漏的风险"),
                                RadioGroup(
                                  groupValue: appProvider.remindMe,
                                  onChanged: (value) async {
                                    appProvider.remindMe = value!;
                                    await appProvider.saveConfig();
                                    if (context.mounted) {
                                      Navigator.of(context, rootNavigator: true).pop(context);
                                    }
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
          );
        },
        pageBuilder: (tag, isWide) {
          if (tag == ("master", "change")) {
            return MasterPwdPage(useHero: !isWide, hasPadding: !isWide, hasAppBar: !isWide);
          } else {
            return styled.buildPlaceHolder(text: "未选择项目", context: context);
          }
        }
      )
    );
  }
}