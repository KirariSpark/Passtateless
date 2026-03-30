import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class DocProvider extends ChangeNotifier {
  DocProvider() {
    _loadHelp();
  }

  String _jsonDoc = "正在加载";
  String get jsonDoc => _jsonDoc;

  // 加载JSON文档
  Future<void> _loadHelp() async {
    try {
      final String content = await rootBundle.loadString('assets/docs/json_basic.md');
      _jsonDoc = content;
      notifyListeners();
    } catch (e) {
      _jsonDoc = "加载失败: $e";
      notifyListeners();
    }
  }
}