import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:passtateless/widgets/correction_widget.dart';
import 'package:passtateless/scripts/utils.dart' as utils;
import 'package:passtateless/widgets/uni_styles.dart' as styles;
import 'package:passtateless/providers/app_provider.dart';

class CorrectionTab extends StatefulWidget {
  const CorrectionTab({super.key});

  @override
  State<CorrectionTab> createState() => _CorrectionTabState();
}

class _CorrectionTabState extends State<CorrectionTab> {
  int _correctionRuleCount = 1;
  late List<TextEditingController> _correctionControllers;
  late List<TextEditingController> _wrongControllers;
  String? _lastJsonText;

  @override
  void initState() {
    super.initState();
    _correctionControllers = [TextEditingController()];
    _wrongControllers = [TextEditingController()];
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncFromJson());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final currentText = appProvider.correctionInputController.text;

    if (_lastJsonText != currentText) {
      _lastJsonText = currentText;
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncFromJson());
    }
  }

  @override
  void dispose() {
    _cleanupControllers();
    super.dispose();
  }

  void _showSnackBarQuick(String content) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        utils.showSnackBarQuick(content, context);
        _syncFromJson();
      }
    });
  }

  void _popQuick() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  void _cleanupControllers() {
    for (var controller in _correctionControllers) {
      controller.dispose();
    }
    for (var controller in _wrongControllers) {
      controller.dispose();
    }
  }

  void _syncFromJson() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final jsonText = appProvider.correctionInputController.text.trim();

    if (jsonText.isEmpty) {
      _resetEditors();
      return;
    }

    final rules = utils.parseJSONSilently(jsonText);
    _updateEditorsFromRules(rules);
  }

  void _syncToJson() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final Map<String, String> rules = {};

    for (int i = 0; i < _correctionRuleCount; i++) {
      final wrong = _wrongControllers[i].text.trim();
      final correction = _correctionControllers[i].text.trim();

      if (wrong.isNotEmpty && correction.isNotEmpty) {
        rules[wrong] = correction;
      }
    }

    appProvider.correctionInputController.text = jsonEncode(rules);
  }

  void _updateEditorsFromRules(Map<String, String> rules) {
    _cleanupControllers();

    setState(() {
      _correctionControllers = [];
      _wrongControllers = [];
      _correctionRuleCount = rules.isEmpty ? 1 : rules.length;

      if (rules.isEmpty) {
        _correctionControllers.add(TextEditingController());
        _wrongControllers.add(TextEditingController());
      } else {
        rules.forEach((wrong, correction) {
          _wrongControllers.add(TextEditingController(text: wrong));
          _correctionControllers.add(TextEditingController(text: correction));
        });
      }
    });
  }

  void _resetEditors() {
    _cleanupControllers();

    setState(() {
      _correctionControllers = [TextEditingController()];
      _wrongControllers = [TextEditingController()];
      _correctionRuleCount = 1;
    });
  }

  void _onRuleCountChanged(bool increase, AppProvider provider) {
    if (!increase && _correctionRuleCount == 1) {
      _showSnackBarQuick("不能再减少了");
      return;
    }

    setState(() {
      if (increase) {
        _correctionRuleCount++;
        _correctionControllers.add(TextEditingController());
        _wrongControllers.add(TextEditingController());
      } else {
        _correctionRuleCount--;
        _correctionControllers.removeLast().dispose();
        _wrongControllers.removeLast().dispose();
      }
    });

    _syncToJson();
  }

  void _showJsonEditDialog() {
    _syncToJson();
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    final dialogController =
        TextEditingController(text: appProvider.correctionInputController.text);

    void formatAndUpdate() {
      final formatted = utils.formatJSON(dialogController.text);
      if (formatted.$2 == 0) {
        dialogController.text = formatted.$1;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("格式化失败：${formatted.$3}"), showCloseIcon: true));
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑JSON'),
        shape: styles.uniRoundedBorder,
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: dialogController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            maxLines: 15,
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: styles.uniButtonStyle,
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              appProvider.correctionInputController.text = dialogController.text;
              if (mounted) {_syncFromJson();}
              Navigator.pop(context);
            },
            style: styles.uniButtonStyle,
            child: const Text('接受'),
          ),
          TextButton(
            onPressed: formatAndUpdate,
            style: styles.uniButtonStyle,
            child: const Text("格式化"),
          )
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    utils.showConfirmDialogQuick(
      context,
      () async {
        final delRes = await appProvider.deleteCache();
        _showSnackBarQuick(delRes.$2);
        _popQuick();
      },
      "确认删除"
    );
  }

  void _showSaveCacheDialog(AppProvider appProvider) {
    _syncToJson();
    utils.showConfirmDialogQuick(
      context,
      () async {
        final saveRes = await appProvider.saveToCache();
        _showSnackBarQuick(saveRes.$2);
        _popQuick();
      },
      "确认覆盖"
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: styles.uniBoxConstraints,
          child: Container(
            alignment: Alignment.topCenter,
            padding: styles.uniInsetsSmall,
            child: Column(
              children: <Widget>[
                // 编辑按钮
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    // 增加一项
                    IconButton(
                      tooltip: "增加一项",
                      onPressed: () => _onRuleCountChanged(true, appProvider),
                      style: styles.uniButtonStyle,
                      icon: const Icon(Icons.add),
                    ),
                    // 减少一项
                    IconButton(
                      tooltip: "减少一项",
                      onPressed: () => _onRuleCountChanged(false, appProvider),
                      style: styles.uniButtonStyle,
                      icon: const Icon(Icons.remove),
                    ),
                    // 编辑json
                    IconButton(
                      tooltip: "编辑 JSON",
                      onPressed: _showJsonEditDialog,
                      style: styles.uniButtonStyle,
                      icon: const Icon(Icons.code)
                    ),
                    // 加载缓存
                    IconButton(
                      tooltip: "加载缓存",
                      onPressed: () async {
                        final loadRes = await appProvider.loadFromCache();
                        _showSnackBarQuick(loadRes.$2);
                      },
                      style: styles.uniButtonStyle,
                      icon: const Icon(Icons.folder_open),
                    ),
                    // 覆盖缓存
                    IconButton(
                      tooltip: "覆盖缓存",
                      onPressed: () => _showSaveCacheDialog(appProvider),
                      style: styles.uniButtonStyle,
                      icon: const Icon(Icons.save_outlined),
                    ),
                    // 删除缓存
                    IconButton(
                      tooltip: "删除缓存",
                      onPressed: _showDeleteDialog,
                      style: styles.uniButtonStyle,
                      icon: Icon(
                        Icons.delete_forever,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
                styles.uniSizedBoxMedium,

                // 中间可滚动部分
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        for (int i = 0; i < _correctionRuleCount; i++) CorrectionWidget(
                          wrongController: _wrongControllers[i],
                          correctionController: _correctionControllers[i],
                        ),
                        styles.uniSizedBoxMedium,
                        Text(
                          "JSON 编辑的方法可查看帮助页面",
                          style: styles.uniHintTextStyle,
                          textAlign: TextAlign.center,
                        ),
                        styles.uniSizedBoxMedium,
                      ],
                    ),
                  ),
                ),

                // 操作按钮
                styles.uniSizedBoxMedium,
                FilledButton(
                  onPressed: () {
                    _syncToJson();
                    final parseRes = appProvider.parseJSON(appProvider.correctionInputController.text);
                    utils.showSnackBarQuick(parseRes.$2, context);
                  },
                  style: styles.uniButtonStyle,
                  child: const Text("解析"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
