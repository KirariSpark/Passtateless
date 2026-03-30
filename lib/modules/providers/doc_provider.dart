import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class DocProvider extends ChangeNotifier {
  DocProvider() {
    _loadHelp();
  }

  String _jsonDoc = "正在加载";
  String get jsonDoc => _jsonDoc;

  String _formattingDoc = "正在加载";
  String get formattingDoc => _formattingDoc;

  // 加载JSON文档
  Future<void> _loadHelp() async {
    try {
      _jsonDoc = await rootBundle.loadString('assets/docs/json_basic.md');
    } catch (e) {
      _jsonDoc = "加载失败: $e";
    }
    try {
      _formattingDoc = await rootBundle.loadString("assets/docs/formatting.md");
    } catch (e) {
      _formattingDoc = "加载失败: $e";
    }
    notifyListeners();
  }
}