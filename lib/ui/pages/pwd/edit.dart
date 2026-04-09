import 'package:flutter/material.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:provider/provider.dart';

class PwdEditPage extends StatefulWidget {
  final PwdLocation _location;
  const PwdEditPage({super.key, required PwdLocation location}) : _location = location;

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
    final data = Provider.of<PwdProvider>(context, listen: false).pwdList[widget._location.index];
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
    if (_isDeleting) {
      return Scaffold(
        appBar: AppBar(title: const Text("正在删除...")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final pwdList = context.watch<PwdProvider>().pwdList;
    final currentItem = pwdList[widget._location.index];

    return Scaffold(
      appBar: styled.buildAppBar(
          title: "编辑：${currentItem['identifier'] == '' ? '未命名' : currentItem['identifier']}",
          context: context
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
                          child: styled.buildTextField(
                              context: context,
                              controller: _identifierController,
                              onChanged: (value) {
                                Provider.of<PwdProvider>(context, listen: false).setValue(
                                    widget._location, "identifier", value
                                );
                              },
                              label: "档案名",
                              alpha: styles.alphaSemitransparent
                          )
                      ),
                      ConstrainedBox(
                          constraints: styles.tileWidthConstraint,
                          child: styled.buildTextField(
                              context: context,
                              controller: _userNameController,
                              onChanged: (value) {
                                Provider.of<PwdProvider>(context, listen: false).setValue(
                                    widget._location, "userName", value
                                );
                              },
                              label: "用户名",
                              alpha: styles.alphaSemitransparent
                          )
                      ),
                      ConstrainedBox(
                        constraints: styles.tileWidthConstraint,
                        child: styled.buildTextField(
                            context: context,
                            controller: _accountController,
                            onChanged: (value) {
                              Provider.of<PwdProvider>(context, listen: false).setValue(
                                  widget._location, "account", value
                              );
                            },
                            label: "账号",
                            alpha: styles.alphaSemitransparent
                        ),
                      )
                    ]
                ),
                ConstrainedBox(
                  constraints: styles.tileWidthConstraint,
                  child: TextButton(
                      onPressed: (){
                        ui.showConfirmDialogQuick(
                            context,
                                (){
                              setState(() {
                                _isDeleting = true;
                              });
                              Provider.of<PwdProvider>(context, listen: false).removeRecord(widget._location);
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
