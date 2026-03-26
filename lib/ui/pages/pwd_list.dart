import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passtateless/ui/widgets/uni_styles.dart' as styles;
import 'package:passtateless/ui/pages/pwd_edit.dart';
import 'package:passtateless/modules/utils/utils.dart' as utils;
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/modules/providers/pwd_provider.dart';

class PwdListPage extends StatelessWidget {
  const PwdListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pwdList = context.watch<PwdProvider>().pwdList;

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
      body: Padding(
        padding: styles.uniInsetsSmall,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1200),
            child: ListView.builder(
              itemCount: pwdList.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  onTap: (){
                    ui.showAlertQuickWidget(
                      pwdList[index]["identifier"] == "" ? "未命名" : pwdList[index]["identifier"],
                      SingleChildScrollView(
                        child: Column(
                          spacing: styles.layoutSpacing,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("用户名：${pwdList[index]["userName"]}"),
                            Text("账号：${pwdList[index]["account"]}"),
                            ? pwdList[index]["removeSp"] ? Text("不包含特殊字符") : null,
                            ? pwdList[index]["removeDigits"] ? Text("不包含数字") : null,
                            ? pwdList[index]["removeAlpha"] ? Text("不包含字母") : null
                          ],
                        ),
                      ),
                      "确定",
                      context
                    );
                  },
                  shape: styles.uniRoundedBorder,
                  title: Text(pwdList[index]["identifier"] == "" ? "未命名" : pwdList[index]["identifier"]),
                  subtitle: Text(utils.getPresetText(pwdList[index]["preset"])),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        style: styles.uniButtonStyle,
                        onPressed: (){},
                        icon: Icon(Icons.copy)
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
                );
              }
            ),
          ),
        ),
      ),
    );
  }
}