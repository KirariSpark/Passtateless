import 'package:flutter/material.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/ui/pages/pwd/edit.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/ui/widgets/pwd_tile.dart';
import 'package:passtateless/ui/pages/pwd/view.dart';
import 'package:provider/provider.dart';

class PwdListPage extends StatelessWidget {
  const PwdListPage({super.key});

  List<Widget> _buildList(List<Map<String, dynamic>> pwdList, BuildContext context){
    if (pwdList.isEmpty) {
      return <Widget>[
        ConstrainedBox(
          constraints: styles.tileWidthConstraint,
          child: styled.buildListTile(
            title: "没有密码",
            subtitle: "点击页面底部的 + 以新增一条密码",
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
                  PwdLocation(folder: "", index: index)
              );
            },
            onEditPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => PwdEditPage(location: PwdLocation(folder: "", index: index))));
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
      appBar: styled.buildAppBar(title: "所有密码", context: context),
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
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Provider.of<PwdProvider>(context, listen: false).addEmptyRecord();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PwdEditPage(location: PwdLocation(folder: "", index: pwdList.length - 1))
            )
          );
        },
        shape: styles.roundedBorder,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pwdList = context.watch<PwdProvider>().pwdList;
    return _buildUi(pwdList, context);
  }
}