import 'package:flutter/material.dart';
import 'package:passtateless/ui/widgets/uni_styles.dart' as styles;
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:provider/provider.dart';

class PwdEditPage extends StatefulWidget {
  final int _index;
  const PwdEditPage({super.key, required int index}) : _index = index;

  @override
  State<PwdEditPage> createState() => _PwdEditPageState();
}

class _PwdEditPageState extends State<PwdEditPage> {
  late TextEditingController _identifierController;
  late TextEditingController _userNameController;
  late TextEditingController _accountController;

  @override
  void initState() {
    super.initState();
    final data = Provider.of<PwdProvider>(context, listen: false).pwdList[widget._index];
    _identifierController = TextEditingController(text: data["identifier"]);
    _userNameController = TextEditingController(text: data["userName"]);
    _accountController = TextEditingController(text: data["account"]);
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _userNameController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pwdList = context.watch<PwdProvider>().pwdList;
    final currentItem = pwdList[widget._index];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_outlined),
          style: styles.uniButtonStyle,
        ),
        title: Text("编辑：${currentItem['identifier'] == '' ? '未命名' : currentItem['identifier']}"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: styles.uniInsetsSmall,
          child: Center(
            child: Column(
              spacing: 8,
              children: <Widget>[
                // 文本框区域
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ConstrainedBox(
                      constraints: styles.tileWidthConstraint,
                      child: TextField(
                        controller: _identifierController,
                        onChanged: (value) {
                          Provider.of<PwdProvider>(context, listen: false).setValue(
                            widget._index, "identifier", value
                          );
                        },
                        decoration: const InputDecoration(
                          label: Text("档案名"),
                          border: OutlineInputBorder()
                        ),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: styles.tileWidthConstraint,
                      child: TextField(
                        controller: _userNameController,
                        onChanged: (value) {
                          Provider.of<PwdProvider>(context, listen: false).setValue(
                            widget._index, "userName", value
                          );
                        },
                        decoration: const InputDecoration(
                          label: Text("用户名"),
                          border: OutlineInputBorder()
                        ),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: styles.tileWidthConstraint,
                      child: TextField(
                        controller: _accountController,
                        onChanged: (value) {
                          Provider.of<PwdProvider>(context, listen: false).setValue(
                            widget._index, "account", value
                          );
                        },
                        decoration: const InputDecoration(
                          label: Text("账号"),
                          border: OutlineInputBorder()
                        ),
                      ),
                    )
                  ]
                ),

                // 开关区域
                Wrap(
                  spacing: 8,
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: styles.tileWidthConstraint,
                      child: SwitchListTile(
                        value: currentItem["removeDigits"],
                        onChanged: (bool value){
                          Provider.of<PwdProvider>(context, listen: false).setValue(
                            widget._index, "removeDigits", value
                          );
                        },
                        title: const Text("移除数字"),
                        shape: styles.uniRoundedBorder
                      ),
                    ),
                    ConstrainedBox(
                      constraints: styles.tileWidthConstraint,
                      child: SwitchListTile(
                        value: currentItem["removeAlpha"],
                        onChanged: (bool value){
                          Provider.of<PwdProvider>(context, listen: false).setValue(
                            widget._index, "removeAlpha", value
                          );
                        },
                        title: const Text("移除字母"),
                        shape: styles.uniRoundedBorder
                      ),
                    ),
                    ConstrainedBox(
                      constraints: styles.tileWidthConstraint,
                      child: SwitchListTile(
                        value: currentItem["removeSp"],
                        onChanged: (bool value){
                          Provider.of<PwdProvider>(context, listen: false).setValue(
                            widget._index, "removeSp", value
                          );
                        },
                        title: const Text("移除特殊字符"),
                        shape: styles.uniRoundedBorder
                      ),
                    ),
                    ConstrainedBox(
                      constraints: styles.tileWidthConstraint,
                      child: ListTile(
                        title: const Text("生成预设"),
                        trailing: DropdownMenu(
                          initialSelection: currentItem["preset"], // 设置初始值
                          onSelected: (value) {
                            Provider.of<PwdProvider>(context, listen: false).setValue(
                              widget._index, "preset", value
                            );
                          },
                          dropdownMenuEntries: const [
                            DropdownMenuEntry(value: "simple", label: "简易"),
                            DropdownMenuEntry(value: "complex", label: "复杂"),
                            DropdownMenuEntry(value: "bank", label: "支付"),
                            DropdownMenuEntry(value: "custom", label: "自定义")
                          ]
                        ),
                        shape: styles.uniRoundedBorder
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
