import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/file_mgr/core_mgr.dart';
import 'package:passtateless/ui/pages/settings/log_view.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;

// 高级设置页面
class AdvancedSettingsPage extends StatelessWidget {
  /// 有AppBar时，是否要使用Hero动画
  final bool useHero;
  /// 是否要包含AppBar
  final bool hasAppBar;
  /// 是否有内边距
  final bool hasPadding;
  const AdvancedSettingsPage({super.key, required this.useHero, this.hasAppBar = true, this.hasPadding = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hasAppBar
        ? styled.buildAppBar(title: "高级设置", titleTag: useHero ? "advanced" : null, context: context)
        : null,
      body: Container(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: styles.tileWidthConstraint,
          padding: hasPadding ? styles.pagePaddingAll : null,
          child: SingleChildScrollView(
            child: Column(
              children: [
                styled.buildListTile(
                  isFirst: true,
                  title: "日志等级",
                  trailing: Icon(Icons.arrow_drop_down),
                  context: context
                ),
                styled.buildListTile(
                  isLast: true,
                  title: "查看日志",
                  titleTag: "log_view",
                  trailing: Icon(Icons.arrow_forward),
                  onTapped: () async {
                    final res = await readTextFile(Paths.log.path);
                    if (context.mounted) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => LogViewPage(log: res.$2,)));
                    }
                  },
                  context: context
                )
              ],
            )
          ),
        ),
      ),
    );
  }
}