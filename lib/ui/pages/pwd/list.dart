import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/ui/pages/pwd/edit.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/expandable_fab.dart';
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/widgets/pwd_tile.dart';
import 'package:passtateless/ui/pages/pwd/view.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:provider/provider.dart';

/// 查看资料夹中所有密码的页面
///
/// 资料夹名称将会被用于 Hero 动画
class PwdListPage extends StatelessWidget {
  final String folder;
  /// 是否使用 Hero 动画
  final bool useHero;
  /// 页面是否有 AppBar
  final bool hasAppBar;
  /// 页面是否有内边距
  final bool hasPadding;
  /// 是否要显示Fab
  final bool hasFab;

  const PwdListPage({
    super.key,
    required this.folder,
    required this.useHero,
    this.hasAppBar = true,
    this.hasPadding = true,
    this.hasFab = true
  });

  List<Widget> _buildList(List<Map<String, dynamic>> pwdList, BuildContext context){
    if (pwdList.isEmpty) {
      return <Widget>[
        ConstrainedBox(
          constraints: styles.tileWidthConstraint,
          child: styled.buildListTile(
            title: "没有密码",
            subtitle: "点击页面右下角的 + 以新增一条密码",
            leading: Icons.not_interested,
            isFirst: true,
            isLast: true,
            context: context
          )
        )
      ];
    } else {
      List<Widget> temp = [];
      // 构建列表
      for (final (index, item) in pwdList.indexed) {
        temp.add(
          PwdTile(
            pwdRecord: item,
            isFirst: index == 0,
            isLast: index == pwdList.length - 1,
            onStarPressed: (){
              Provider.of<PwdProvider>(context, listen: false).switchStarStateById(item["id"]);
            },
            onEditPressed: (){
              appLogger.logger.i("Pushing to edit page for ${item["id"]}");
              Navigator.push(context, MaterialPageRoute(builder: (context) => PwdEditPage(id: item["id"])));
            },
            onTapped: (){
              appLogger.logger.i("Pushing to view page for ${item["id"]}");
              Navigator.push(context, MaterialPageRoute(builder: (context) => PwdViewPage(id: item["id"], useHero: true)));
            }
          ),
        );
      }
      return temp;
    }
  }

  Scaffold _buildUi(
    List<Map<String, dynamic>> pwdList,
    BuildContext context, {
      required bool useHero,
      required bool hasAppBar,
      required bool hasPadding,
      required bool hasFab
    }
  ) {
    return Scaffold(
      appBar: hasAppBar ? styled.buildAppBar(
        title: folder.isEmpty ? '未分类' : folder, context: context, titleTag: useHero ? folder : null
      ) : null,
      body: Container(
        padding: hasPadding ? styles.uniInsetsSmall : EdgeInsets.zero,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 主列表区域
              Column(children: _buildList(pwdList, context)),
              // 防止列表被FAB挡住
              SizedBox(height: 25),
              // TODO: 增加实际功能
              TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              )
            ],
          ),
        )
      ),
      floatingActionButton: hasFab ? ExpandableFab(
        distance: 64,
        children: [
          styled.buildElevatedButton(
            child: Row(
              spacing: styles.layoutSpacing,
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.save_outlined), Text("保存更改")],
            ),
            context: context,
            onPressed: () async {
              appLogger.logger.i("Saving changes in password archive");
              ui.showSnackBarQuick("正在保存", context);
              var stat = await Provider.of<PwdProvider>(context, listen: false).saveArchive(
                  Provider.of<AppProvider>(context, listen: false).masterPwd
              );
              if (context.mounted) {
                if (stat == ErrorCode.success) {
                  appLogger.logger.i("Saved successfully");
                  ui.showSnackBarQuick("你的档案已保存", context);
                } else {
                  appLogger.logger.i("Can not save archive: ${stat.code}");
                  ui.showSnackBarQuick(stat.generic, context);
                }
              }
            }
          ),
          styled.buildElevatedButton(
            child: Row(
              spacing: styles.layoutSpacing,
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.add), Text("新档案")],
            ),
            context: context,
            onPressed: (){
              appLogger.logger.i("Adding empty record to folder $folder");
              final newId = Provider.of<PwdProvider>(context, listen: false).addEmptyRecordTo(folder);
              appLogger.logger.i("Record added, pushing to edit page for new record $newId");
              Navigator.push(context, MaterialPageRoute(builder: (context) => PwdEditPage(id: newId)));
            }
          ),
        ]
      ) : null
    );
  }

  @override
  Widget build(BuildContext context) {
    final pwdList = context.watch<PwdProvider>().getPwdList(folder);
    return _buildUi(pwdList, context, useHero: useHero, hasAppBar: hasAppBar, hasPadding: hasPadding, hasFab: hasFab);
  }
}
