import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passtateless/scripts/main_generator.dart';

class AppProvider extends ChangeNotifier {
  // ————UI相关状态————
  // 页面索引
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // 帮助内容
  String _helpContent = '正在加载帮助';
  String get helpContent => _helpContent;

  // ————控制器————
  final TextEditingController _inputTextController = TextEditingController();
  TextEditingController get inputTextController => _inputTextController;

  AppProvider() {
    _loadHelp();
  }

  // ————密码相关状态————
  // 移除特殊字符
  bool _removeSpChar = false;
  bool get removeSpChar => _removeSpChar;
  set removeSpChar(bool value) {
    _removeSpChar = value;
    notifyListeners();
  }

  // 移除字母
  bool _removeAlpha = false;
  bool get removeAlpha => _removeAlpha;
  set removeAlpha(bool value) {
    _removeAlpha = value;
    notifyListeners();
  }

  // 移除数字
  bool _removeDigits = false;
  bool get removeDigits => _removeDigits;
  set removeDigits(bool value) {
    _removeDigits = value;
    notifyListeners();
  }

  // 密码生成状态
  (int stat, String res) _generateRes = (-1, "暂未生成");
  (int stat, String res) get generateRes => _generateRes;
  // v2算法警告
  String _v2Warnings = "";
  String get v2Warnings => _v2Warnings;
  void refreshWarnings() {
    _v2Warnings = getParserWarnings();
    notifyListeners();
  }

  /// 生成密码
  ///
  /// [v2Config] 可选参数，用于传递 V2 的 JSON 配置
  /// [master] 用于V2算法的主密码
  void genPassword({String? v2Config, String? master}) {
    final rawInput = _inputTextController.text;

    String effectiveV2Config = "";
    String effectiveV2Master = "";

    if (rawInput.isEmpty) {
      _generateRes = (1, "输入为空");
    } else {
      effectiveV2Config = v2Config ?? "";
      effectiveV2Master = master ?? "";
      if (effectiveV2Config.isEmpty) {
        _generateRes = (1, "未提供 V2 配置");
        notifyListeners();
        return;
      }

      _generateRes = uniPasswordGen(
        input: rawInput,
        removeSpChar: _removeSpChar,
        removeAlpha: _removeAlpha,
        removeDigits: _removeDigits,
        configJson: effectiveV2Config,
        master: effectiveV2Master
      );
    }

    notifyListeners();
  }

  // 加载帮助内容
  Future<void> _loadHelp() async {
    try {
      final String content = await rootBundle.loadString('assets/help.md');
      _helpContent = content;
      notifyListeners();
    } catch (e) {
      _helpContent = "加载失败: $e";
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _inputTextController.dispose();
    super.dispose();
  }
}
