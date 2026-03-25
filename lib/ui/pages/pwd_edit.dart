import 'package:flutter/material.dart';
import 'package:passtateless/ui/widgets/uni_styles.dart' as styles;
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:provider/provider.dart';

class PwdEditPage extends StatelessWidget {
  final int index;
  const PwdEditPage({super.key, required this.index});

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
        title: Text("编辑：${pwdList[index]["identifier"]}"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: styles.uniInsetsSmall,
          child: Center(
            child: Column(
              spacing: 8,
              children: <Widget>[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ConstrainedBox(
                      constraints: styles.tileWidthConstraint,
                      child: TextField(
                        decoration: InputDecoration(
                            label: const Text("档案名"),
                            border: const OutlineInputBorder()
                        ),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: styles.tileWidthConstraint,
                      child: TextField(
                        decoration: const InputDecoration(
                          label: Text("用户名"),
                          border: OutlineInputBorder()
                        ),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: styles.tileWidthConstraint,
                      child: TextField(
                        decoration: InputDecoration(
                          label: Text("账号"),
                          border: OutlineInputBorder()
                        ),
                      ),
                    )
                  ]
                ),
                Wrap(
                  spacing: 8,
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: styles.tileWidthConstraint,
                      child: SwitchListTile(
                        value: false,
                        onChanged: (bool value){},
                        title: Text("移除数字"),
                        shape: styles.uniRoundedBorder
                      ),
                    ),
                    ConstrainedBox(
                      constraints: styles.tileWidthConstraint,
                      child: SwitchListTile(
                        value: false,
                        onChanged: (bool value){},
                        title: Text("移除字母"),
                        shape: styles.uniRoundedBorder
                      ),
                    ),
                    ConstrainedBox(
                      constraints: styles.tileWidthConstraint,
                      child: SwitchListTile(
                        value: false,
                        onChanged: (bool value){},
                        title: Text("移除特殊字符"),
                        shape: styles.uniRoundedBorder
                      ),
                    ),
                    ConstrainedBox(
                      constraints: styles.tileWidthConstraint,
                      child: ListTile(
                        title: Text("生成预设"),
                        trailing: DropdownMenu(
                          dropdownMenuEntries: [
                            DropdownMenuEntry(
                              value: "simple",
                              label: "简易",
                              style: styles.uniButtonStyle
                            ),
                            DropdownMenuEntry(
                              value: "complex",
                              label: "复杂",
                              style: styles.uniButtonStyle
                            ),
                            DropdownMenuEntry(
                              value: "bank",
                              label: "支付",
                              style: styles.uniButtonStyle
                            ),
                            DropdownMenuEntry(
                              value: "custom",
                              label: "自定义",
                              style: styles.uniButtonStyle
                            )
                          ]
                        ),
                        shape: styles.uniRoundedBorder
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: styles.tileWidthConstraint,
                      child: ElevatedButton(
                        onPressed: (){},
                        style: styles.uniButtonStyle,
                        child: Text("保存"),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: styles.tileWidthConstraint,
                      child: ElevatedButton(
                        onPressed: (){},
                        style: styles.uniButtonStyle,
                        child: Text("放弃"),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ),
      ),
    );
  }

}