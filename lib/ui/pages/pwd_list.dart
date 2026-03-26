import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passtateless/ui/widgets/uni_styles.dart' as styles;
import 'package:passtateless/ui/pages/pwd_edit.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';

class PwdListPage extends StatelessWidget {
  const PwdListPage({super.key});

  List<Widget> _buildList(List<Map<String, dynamic>> pwdList, BuildContext context){
    if (pwdList.isEmpty) {
      return <Widget>[
        ConstrainedBox(
          constraints: styles.tileWidthConstraint,
          child: ListTile(
            onTap: (){},
            shape: styles.uniRoundedBorder,
            leading: Icon(Icons.not_interested),
            title: Text("没有密码"),
          ),
        )
      ];
    } else {
      List<Widget> temp = [];
      // 构建列表
      for (var(index, item) in pwdList.indexed) {
        temp.add(
          ConstrainedBox(
            constraints: styles.tileWidthConstraint,
            child: ListTile(
              onTap: (){
                throw UnimplementedError("暂未实现点击复制逻辑");
              },
              shape: styles.uniRoundedBorder,
              tileColor: ColorScheme.of(context).surfaceContainer,
              title: Text(item["identifier"] == "" ? "未命名" : item["identifier"]),
              subtitle: Text("${item["userName"]} @ ${item["account"]}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    style: styles.uniButtonStyle,
                    onPressed: (){
                      Provider.of<PwdProvider>(context, listen: false).switchStarState(index);
                    },
                    icon: item["starred"] ? Icon(Icons.star) : Icon(Icons.star_border)
                  ),
                  IconButton(
                    style: styles.uniButtonStyle,
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PwdEditPage(index: index)));
                    },
                    icon: Icon(Icons.edit)
                  ),
                ],
              ),
            )
          )
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
            style: styles.uniButtonStyle,
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
              shape: styles.uniRoundedBorder,
              leading: Icon(Icons.not_interested),
              title: const Text("没有密码"),
              subtitle: const Text("点击右下角的 + 以增加一条密码"),
              tileColor: ColorScheme.of(context).surfaceContainer,
            ),
          )
        ),
        floatingActionButton: ElevatedButton(
          onPressed: (){
            Provider.of<PwdProvider>(context, listen: false).addEmptyRecord();
            Navigator.push(context, MaterialPageRoute(builder: (context) => PwdEditPage(index: pwdList.length - 1)));
          },
          style: styles.uniButtonStyle,
          child: const Icon(Icons.add),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_outlined),
            style: styles.uniButtonStyle,
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
        floatingActionButton: ElevatedButton(
          onPressed: (){
            Provider.of<PwdProvider>(context, listen: false).addEmptyRecord();
            Navigator.push(context, MaterialPageRoute(builder: (context) => PwdEditPage(index: pwdList.length - 1)));
          },
          style: styles.uniButtonStyle,
          child: const Icon(Icons.add),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pwdList = context.watch<PwdProvider>().pwdList;

    return _buildUi(pwdList, context);
  }
}