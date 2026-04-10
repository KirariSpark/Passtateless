import 'package:flutter/material.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/ui/pages/pwd/edit.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/widgets/pwd_tile.dart';
import 'package:passtateless/ui/pages/pwd/view.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:provider/provider.dart';

class PwdListPage extends StatelessWidget {
  final String folder;
  const PwdListPage({super.key, required this.folder});

  List<Widget> _buildList(List<Map<String, dynamic>> pwdList, BuildContext context){
    if (pwdList.isEmpty) {
      return <Widget>[
        ConstrainedBox(
          constraints: styles.tileWidthConstraint,
          child: styled.buildListTile(
            title: "没有密码",
            subtitle: "点击页面右下角的 + 以新增一条密码",
            leading: Icons.not_interested,
            alpha: styles.alphaSemitransparent,
            context: context
          )
        )
      ];
    } else {
      List<Widget> temp = [];
      // 构建列表
      for (var(index, _) in pwdList.indexed) {
        temp.add(
          PwdTile(
            pwdRecord: pwdList[index],
            onStarPressed: (){
              Provider.of<PwdProvider>(context, listen: false).switchStarState(
                PwdLocation(folder: folder, index: index)
              );
            },
            onEditPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => PwdEditPage(
                location: PwdLocation(folder: folder, index: index)))
              );
            },
            onTapped: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => PwdViewPage(
                identifier: pwdList[index]["identifier"],
                userName: pwdList[index]["userName"],
                account: pwdList[index]["account"]
              )));
            },
            alpha: styles.alphaSemitransparent,
          ),
        );
      }
      return temp;
    }
  }

  Scaffold _buildUi(List<Map<String, dynamic>> pwdList, BuildContext context) {
    return Scaffold(
      appBar: styled.buildAppBar(title: "查看：${folder.isEmpty ? '未分类' : folder}", context: context),
      body: Container(
        padding: styles.uniInsetsSmall,
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 主列表区域
              Wrap(
                spacing: styles.layoutSpacing,
                runSpacing: styles.layoutSpacing,
                children: _buildList(pwdList, context),
              ),
              // 防止列表被FAB挡住
              SizedBox(height: 25),
              // TODO
              TextField(
                decoration: InputDecoration(
                  border: InputBorder.none
                ),
              )
            ],
          ),
        )
      ),
      floatingActionButton: PopupMenuButton(
        popUpAnimationStyle: AnimationStyle(
            curve: Curves.easeInOut,
            duration: Duration(milliseconds: 300),
            reverseCurve: Curves.easeInOut,
            reverseDuration: Duration(milliseconds: 300)
        ),
        tooltip: "更多功能",
        iconSize: 30,
        icon: Icon(Icons.menu),
        itemBuilder: (_) {
          return [
            // 保存更改
            PopupMenuItem(
              child: Row(
                spacing: styles.layoutSpacing,
                children: [
                  Icon(Icons.save_outlined),
                  Text("保存更改")
                ],
              ),
              onTap: () async {
                ui.showSnackBarQuick("正在保存", context);
                var stat = await Provider.of<PwdProvider>(context, listen: false).saveArchive(
                    Provider.of<AppProvider>(context, listen: false).masterPwd
                );
                if (context.mounted) {
                  if (stat == ErrorCode.success) {
                    ui.showSnackBarQuick("你的档案已保存", context);
                  } else {
                    ui.showSnackBarQuick(stat.generic, context);
                  }
                }
              },
            ),
            // 新建记录
            PopupMenuItem(
              child: Row(
                spacing: styles.layoutSpacing,
                children: [
                  Icon(Icons.add),
                  Text("新建记录")
                ],
              ),
              onTap: (){
                Provider.of<PwdProvider>(context, listen: false).addEmptyRecordTo(folder);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PwdEditPage(location: PwdLocation(folder: folder, index: pwdList.length - 1))
                  )
                );
              },
            )
          ];
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pwdList = context.watch<PwdProvider>().getPwdList(folder);
    return _buildUi(pwdList, context);
  }
}