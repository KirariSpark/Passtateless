import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
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
  late final TextEditingController _identifierController;
  late final TextEditingController _userNameController;
  late final TextEditingController _accountController;
  late final PwdProvider _pwdProvider;
  late final AppProvider _appProvider;


  @override
  void initState() {
    super.initState();
    appLogger.logger.i("Editing password id ${widget.id}");
    _pwdProvider = context.read<PwdProvider>();
    _appProvider = context.read<AppProvider>();

    final data = _pwdProvider.getItemById(widget.id);
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

  AppBar? _buildAppBar() {
    return styled.buildAppBar(
      title: "编辑：${_identifierController.text == '' ? '未命名' : _identifierController.text}",
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topCenter,
          padding: styles.pagePaddingAll,
          child: ConstrainedBox(
            constraints: styles.tileWidthConstraint,
            child: Column(
              spacing: styles.layoutSpacing,
              children: <Widget>[
                styled.buildTextField(
                  context: context,
                  controller: _identifierController,
                  onChanged: (value) {
                    _appProvider.hasUnsavedChanges = true;
                    final stat = _pwdProvider.setValueById(widget.id, "identifier", value);
                    if (stat != ErrorCode.success) {
                      appLogger.logger.e("Failed to rename archive ${widget.id}: $stat");
                      ui.showSnackBarQuick(stat.generic, context);
                    }
                  },
                  label: "档案名",
                ),
                styled.buildTextField(
                  context: context,
                  controller: _userNameController,
                  onChanged: (value) {
                    _appProvider.hasUnsavedChanges = true;
                    final stat = _pwdProvider.setValueById(widget.id, "userName", value);
                    if (stat != ErrorCode.success) {
                      appLogger.logger.e("Cannot change userName for archive ${widget.id}: $stat");
                      ui.showSnackBarQuick(stat.generic, context);
                    }
                  },
                  label: "用户名",
                ),
                styled.buildTextField(
                  context: context,
                  controller: _accountController,
                  onChanged: (value) {
                    _appProvider.hasUnsavedChanges = true;
                    final stat = _pwdProvider.setValueById(widget.id, "account", value);
                    if (stat != ErrorCode.success) {
                      appLogger.logger.e("Cannot change account for archive ${widget.id}: $stat");
                      ui.showSnackBarQuick(stat.generic, context);
                    }
                  },
                  label: "账号",
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
