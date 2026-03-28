import 'package:flutter/material.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/ui/pages/pwd_edit.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/pwd_tile.dart';
import 'package:provider/provider.dart';

class PwdListPage extends StatelessWidget {
  const PwdListPage({super.key});

  List<Widget> _buildList(List<Map<String, dynamic>> pwdList, BuildContext context){
    if (pwdList.isEmpty) {
      return <Widget>[
        ConstrainedBox(
          constraints: styles.tileWidthConstraint,
          child: ListTile(
            onTap: (){},
            shape: styles.roundedBorder,
            leading: Icon(Icons.not_interested),
            title: Text("没有密码"),
          ),
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
              Provider.of<PwdProvider>(context, listen: false).switchStarState(index);
            },
            onEditPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => PwdEditPage(index: index)));
            }
          ),
        );
      }
      return temp;
    }
  }

  Scaffold _buildUi(List<Map<String, dynamic>> pwdList, BuildContext context) {
    if (pwdList.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_outlined),
            style: styles.buttonStyle,
          ),
          title: const Text("所有密码"),
        ),
        body: Container(
          padding: styles.uniInsetsSmall,
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: styles.tileWidthConstraint,
            child: ListTile(
              onTap: (){},
              shape: styles.roundedBorder,
              leading: Icon(Icons.not_interested),
              title: const Text("没有密码"),
              subtitle: const Text("点击页面底部的 + 以增加一条密码"),
              tileColor: ColorScheme.of(context).surfaceContainer,
            ),
          )
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            Provider.of<PwdProvider>(context, listen: false).addEmptyRecord();
            Navigator.push(context, MaterialPageRoute(builder: (context) => PwdEditPage(index: pwdList.length - 1)));
          },
          shape: styles.roundedBorder,
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_outlined),
            style: styles.buttonStyle,
          ),
          title: const Text("所有密码"),
        ),
        body: Container(
          padding: styles.uniInsetsSmall,
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Wrap(
              spacing: styles.layoutSpacing,
              runSpacing: styles.layoutSpacing,
              children: _buildList(pwdList, context),
            ),
          )
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            Provider.of<PwdProvider>(context, listen: false).addEmptyRecord();
            Navigator.push(context, MaterialPageRoute(builder: (context) => PwdEditPage(index: pwdList.length - 1)));
          },
          shape: styles.roundedBorder,
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pwdList = context.watch<PwdProvider>().pwdList;

    return _buildUi(pwdList, context);
  }
}