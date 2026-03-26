import 'package:flutter/material.dart';
import 'package:passtateless/ui/widgets/uni_styles.dart' as styles;
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/modules/utils/utils.dart' as utils;
import 'package:passtateless/modules/utils/ui.dart' as ui;
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

  bool _isDeleting = false;

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
    // 如果正在删除，直接返回一个静态的处理中页面
    // 避免使用旧索引去访问已变短的列表，从而防止报错或显示错误数据
    if (_isDeleting) {
      return Scaffold(
        appBar: AppBar(title: const Text("正在删除...")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final pwdList = context.watch<PwdProvider>().pwdList;
    final currentItem = pwdList[widget._index];

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
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
                  ],
                ),
                // 预设
                ConstrainedBox(
                  constraints: styles.tileWidthConstraint,
                  child: ListTile(
                    onTap: (){
                      ui.showAlertQuickWidget(
                        "选择预设",
                        SingleChildScrollView(
                          child: RadioGroup(
                            groupValue: pwdList[widget._index]["preset"].toString(),
                            onChanged: (value){
                              Provider.of<PwdProvider>(context, listen: false).setValue(
                                widget._index, "preset", value
                              );
                              Navigator.pop(context);
                            },
                            child: Column(
                              children: [
                                RadioListTile(
                                  title: Text(utils.getPresetText("simple")),
                                  subtitle: Text("简易预设"),
                                  shape: styles.uniRoundedBorder,
                                  value: "simple",
                                ),
                                RadioListTile(
                                  title: Text(utils.getPresetText("complex")),
                                  subtitle: Text("复杂预设，使用更复杂的生成流程"),
                                  shape: styles.uniRoundedBorder,
                                  value: "complex"
                                ),
                                RadioListTile(
                                  title: Text(utils.getPresetText("bank")),
                                  subtitle: Text("生成六位的纯数字密码"),
                                  shape: styles.uniRoundedBorder,
                                  value: "bank"
                                ),
                                RadioListTile(
                                  title: Text(utils.getPresetText("custom")),
                                  subtitle: Text("完全自定义整个生成流程"),
                                  shape: styles.uniRoundedBorder,
                                  value: "custom"
                                )
                              ],
                            )
                          ),
                        ),
                        "取消",
                        context
                      );
                    },
                    title: const Text("生成预设"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          utils.getPresetText(currentItem["preset"]),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Icon(Icons.arrow_drop_down)
                      ],
                    ),
                    shape: styles.uniRoundedBorder
                  ),
                ),
                // 危险区
                ConstrainedBox(
                  constraints: styles.tileWidthConstraint,
                  child: TextButton(
                    onPressed: (){
                      ui.showConfirmDialogQuick(
                        context,
                        (){
                          // 让 build 方法在接下来的重建中直接返回静态页面，避免后续的数据访问操作
                          setState(() {
                            _isDeleting = true;
                          });

                          Provider.of<PwdProvider>(context, listen: false).removeRecord(widget._index);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        "确认删除"
                      );
                    },
                    style: styles.uniButtonStyle,
                    child: Text(
                      "删除这条记录",
                      style: TextStyle(
                        color: ColorScheme.of(context).error,
                        fontWeight: FontWeight.w800
                      ),
                    )
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
