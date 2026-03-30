import 'package:flutter/material.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
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
          style: styles.buttonStyle,
        ),
        // 就是看这个档案有没有被命名，没有就显示未命名
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
                    // 档案名
                    ConstrainedBox(
                      constraints: styles.tileWidthConstraint,
                      child: styled.buildTextField(
                        context: context,
                        controller: _identifierController,
                        onChanged: (value) {
                          Provider.of<PwdProvider>(context, listen: false).setValue(
                            widget._index, "identifier", value
                          );
                        },
                        label: "档案名",
                        alpha: styles.alphaSemitransparent
                      )
                    ),
                    // 用户名
                    ConstrainedBox(
                      constraints: styles.tileWidthConstraint,
                      child: styled.buildTextField(
                        context: context,
                        controller: _userNameController,
                        onChanged: (value) {
                          Provider.of<PwdProvider>(context, listen: false).setValue(
                            widget._index, "userName", value
                          );
                        },
                        label: "用户名",
                        alpha: styles.alphaSemitransparent
                      )
                    ),
                    // 账号
                    ConstrainedBox(
                      constraints: styles.tileWidthConstraint,
                      child: styled.buildTextField(
                        context: context,
                        controller: _accountController,
                        onChanged: (value) {
                          Provider.of<PwdProvider>(context, listen: false).setValue(
                            widget._index, "account", value
                          );
                        },
                        label: "账号",
                        alpha: styles.alphaSemitransparent
                      ),
                    )
                  ]
                ),
                // 开关区域
                Wrap(
                  spacing: styles.layoutSpacing,
                  runSpacing: styles.layoutSpacing,
                  children: <Widget>[
                    // 移除数字
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
                        shape: styles.roundedBorder,
                        tileColor: ColorScheme.of(context).surfaceContainerLowest.withAlpha(200),
                      ),
                    ),
                    // 移除字母
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
                        shape: styles.roundedBorder,
                        tileColor: ColorScheme.of(context).surfaceContainerLowest.withAlpha(200),
                      ),
                    ),
                    // 移除特殊字符
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
                        shape: styles.roundedBorder,
                        tileColor: ColorScheme.of(context).surfaceContainerLowest.withAlpha(200),
                      ),
                    )
                  ],
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
                    style: ElevatedButton.styleFrom(
                      shape: styles.roundedBorder,
                      backgroundColor: ColorScheme.of(context).errorContainer
                    ),
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
