import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/core/pwd_item.dart';
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
  final TextEditingController _newTagController = TextEditingController();
  final TextEditingController _renameController = TextEditingController();
  late final PwdProvider _pwdProvider;
  late final AppProvider _appProvider;
  late List<String> _tags;


  @override
  void initState() {
    super.initState();
    appLogger.logger.i("Editing password id ${widget.id}");
    _pwdProvider = context.read<PwdProvider>();
    _appProvider = context.read<AppProvider>();

    final record = _pwdProvider.getItemById(widget.id);
    _identifierController = TextEditingController(text: record?.identifier ?? "");
    _userNameController = TextEditingController(text: record?.userName ?? "");
    _accountController = TextEditingController(text: record?.account ?? "");
    _tags = List.of(record?.tags ?? const <String>[]);
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _userNameController.dispose();
    _accountController.dispose();
    _newTagController.dispose();
    _renameController.dispose();
    super.dispose();
  }

  void _applyChange(void Function(PwdItem record) changes) {
    _appProvider.hasUnsavedChanges = true;
    final stat = _pwdProvider.mutateById(widget.id, changes);
    if (stat != ErrorCode.success) {
      appLogger.logger.e("Failed to change archive ${widget.id}: $stat");
      ui.showSnackBarQuick(stat.generic, context);
    }
  }

  void _addTag() {
    final tag = _newTagController.text.trim();
    if (tag.isEmpty) return;
    setState(() {
      _newTagController.clear();
      _tags.add(tag);
    });
    _applyChange((record) => record.addTag(tag));
  }

  void _deleteTag(int index) {
    final tag = _tags[index];
    setState(() => _tags.removeAt(index));
    _applyChange((record) => record.removeTag(tag));
  }

  void _renameTag(int index) {
    _renameController.text = _tags[index];
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: styles.roundedBorder,
        title: const Text("重命名标签"),
        content: styled.buildTextField(
          context: dialogContext,
          controller: _renameController,
          label: "新名称",
        ),
        actions: [
          styled.buildTextButton(
            context: dialogContext,
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("取消"),
            highlighted: false
          ),
          styled.buildTextButton(
            context: dialogContext,
            onPressed: () {
              final newTag = _renameController.text.trim();
              if (newTag.isEmpty) return;
              setState(() => _tags[index] = newTag);
              _applyChange((record) => record.tags[index] = newTag);
              Navigator.pop(dialogContext);
            },
            child: const Text("确定"),
          ),
        ],
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final tag = _tags.removeAt(oldIndex);
      _tags.insert(newIndex, tag);
    });
    _applyChange((record) {
      final t = record.tags.removeAt(oldIndex);
      record.tags.insert(newIndex, t);
    });
  }

  AppBar? _buildAppBar() {
    final String title =
        _pwdProvider.getItemById(widget.id)?.displayName ?? "未命名";
    return styled.buildAppBar(
      title: "编辑：$title",
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
                  onChanged: (value) => _applyChange((record) => record.identifier = value),
                  label: "档案名",
                ),
                styled.buildTextField(
                  context: context,
                  controller: _userNameController,
                  onChanged: (value) => _applyChange((record) => record.userName = value),
                  label: "用户名",
                ),
                styled.buildTextField(
                  context: context,
                  controller: _accountController,
                  onChanged: (value) => _applyChange((record) => record.account = value),
                  label: "账号",
                ),
                const Divider(),
                Column(
                  spacing: styles.layoutSpacing,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "标签",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Row(
                      spacing: styles.layoutSpacing,
                      children: <Widget>[
                        Expanded(
                          child: styled.buildTextField(
                            context: context,
                            controller: _newTagController,
                            label: "新增标签",
                          ),
                        ),
                        styled.buildTextButton(
                          context: context,
                          onPressed: _addTag,
                          child: const Text("添加"),
                        ),
                      ],
                    ),
                    ReorderableListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      onReorder: _onReorder,
                      children: <Widget>[
                        for (int i = 0; i < _tags.length; i++) ListTile(
                          key: ValueKey(i),
                          contentPadding: EdgeInsets.zero,
                          title: Text(_tags[i]),
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _renameTag(i),
                                style: styles.buttonStyle,
                                tooltip: "重命名",
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _deleteTag(i),
                                style: styles.buttonStyle,
                                tooltip: "删除",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
