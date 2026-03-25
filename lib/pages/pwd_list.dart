import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passtateless/widgets/uni_styles.dart' as styles;
import 'package:passtateless/modules/utils/utils.dart' as utils;
import 'package:passtateless/modules/providers/pwd_provider.dart';

class PwdList extends StatelessWidget {
  const PwdList({super.key});

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
      body: ListView.builder(
        itemCount: pwdList.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: Text(
              "${index+1}",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            title: Text(pwdList[index]["identifier"]),
            subtitle: Text(utils.getPresetText(pwdList[index]["preset"])),
          );
        }
      ),
    );
  }

}