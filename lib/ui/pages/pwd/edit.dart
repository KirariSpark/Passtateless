import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:provider/provider.dart';

/// 密码编辑页面
class PwdEditPage extends StatefulWidget {
  /// 要编辑的密码条目的UUID
  final String id;
  const PwdEditPage({super.key, required this.id});

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
    final data = Provider.of<PwdProvider>(context, listen: false).getItemById(widget.id);
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

    final currentItem = context.watch<PwdProvider>().getItemById(widget.id);

    return Scaffold(
      appBar: styled.buildAppBar(
        title:
            "编辑：${currentItem['identifier'] == '' ? '未命名' : currentItem['identifier']}",
        context: context,
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topCenter,
          padding: styles.uniInsetsSmall,
          child: Column(
            spacing: 8,
            children: <Widget>[
              // 文本框区域
              Wrap(
                spacing: styles.layoutSpacing,
                runSpacing: styles.layoutSpacing,
                children: [
                  // 档案名
                  ConstrainedBox(
                    constraints: styles.tileWidthConstraint,
                    child: styled.buildTextField(
                      context: context,
                      controller: _identifierController,
                      onChanged: (value) {
                        var res = Provider.of<PwdProvider>(
                          context, listen: false
                        ).setValueById(widget.id, "identifier", value);
                        if (res != ErrorCode.success) {
                          ui.showSnackBarQuick(res.generic, context);
                        }
                      },
                      label: "档案名",
                    ),
                  ),
                  // 用户名
                  ConstrainedBox(
                    constraints: styles.tileWidthConstraint,
                    child: styled.buildTextField(
                      context: context,
                      controller: _userNameController,
                      onChanged: (value) {
                        var res = Provider.of<PwdProvider>(
                          context, listen: false,
                        ).setValueById(widget.id, "userName", value);
                        if (res != ErrorCode.success) {
                          ui.showSnackBarQuick(res.generic, context);
                        }
                      },
                      label: "用户名",
                    ),
                  ),
                  // 账号
                  ConstrainedBox(
                    constraints: styles.tileWidthConstraint,
                    child: styled.buildTextField(
                      context: context,
                      controller: _accountController,
                      onChanged: (value) {
                        var res = Provider.of<PwdProvider>(
                          context, listen: false,
                        ).setValueById(widget.id, "account", value);
                        if (res != ErrorCode.success) {
                          ui.showSnackBarQuick(res.generic, context);
                        }
                      },
                      label: "账号",
                    ),
                  ),
                ],
              ),
              // 删除按钮
              TextButton(
                onPressed: () {
                  ui.showConfirmDialogQuick(
                    context: context,
                    function: () {
                      setState(() {
                        _isDeleting = true;
                      });
                      final res = Provider.of<PwdProvider>(context, listen: false).removeRecordById(widget.id);
                      if (res != ErrorCode.success) {
                        ui.showSnackBarQuick(res.generic, context);
                      }
                      Navigator.of(context, rootNavigator: true).pop();
                      Navigator.pop(context);
                    },
                    title: "确认删除",
                    info: "你无法撤销此操作",
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: styles.roundedBorder,
                  backgroundColor: ColorScheme.of(context).errorContainer,
                ),
                child: Text(
                  "删除这条记录",
                  style: TextStyle(
                    color: ColorScheme.of(context).error,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
