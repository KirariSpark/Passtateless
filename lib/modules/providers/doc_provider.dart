import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:passtateless/modules/core/logger.dart';

class DocProvider extends ChangeNotifier {
  DocProvider() {
    _loadHelp();
  }

  String _jsonDoc = "正在加载";
  String get jsonDoc => _jsonDoc;

  String _formattingDoc = "正在加载";
  String get formattingDoc => _formattingDoc;

  String _tipDoc = "正在加载";
  String get tipDoc => _tipDoc;

  String _cfgDoc = "正在加载";
  String get cfgDoc => _cfgDoc;

  String _basicDoc = "正在加载";
  String get basicDoc => _basicDoc;

  String _faqDoc = "正在加载";
  String get faqDoc => _faqDoc;

  String _getStartedDoc = "正在加载";
  String get getStartedDoc => _getStartedDoc;

  // 加载JSON文档
  Future<void> _loadHelp() async {
    appLogger.logger.i("Loading docs");
    try {
      _jsonDoc = await rootBundle.loadString('assets/docs/json_basic.md');
    } catch (e) {
      appLogger.logger.e("Failed to load doc assets/docs/json_basic.md: $e");
      _jsonDoc = "加载失败: $e";
    }
    try {
      _formattingDoc = await rootBundle.loadString("assets/docs/formatting.md");
    } catch (e) {
      appLogger.logger.e("Failed to load doc assets/docs/formatting.md: $e");
      _formattingDoc = "加载失败: $e";
    }
    try {
      _tipDoc = await rootBundle.loadString("assets/docs/cfg_tips.md");
    } catch (e) {
      appLogger.logger.e("Failed to load doc assets/docs/cfg_tips.md: $e");
      _tipDoc = "加载失败: $e";
    }
    try {
      _cfgDoc = await rootBundle.loadString("assets/docs/cfg.md");
    } catch (e) {
      appLogger.logger.e("Failed to load doc assets/docs/cfg.md: $e");
      _cfgDoc = "加载失败: $e";
    }
    try {
      _basicDoc = await rootBundle.loadString("assets/docs/basic.md");
    } catch (e) {
      appLogger.logger.e("Failed to load doc assets/docs/basic.md: $e");
      _basicDoc = "加载失败: $e";
    }
    try {
      _faqDoc = await rootBundle.loadString("assets/docs/faq.md");
    } catch (e) {
      appLogger.logger.e("Failed to load doc assets/docs/faq.md: $e");
      _faqDoc = "加载失败: $e";
    }
    try {
      _getStartedDoc = await rootBundle.loadString("assets/docs/get_started.md");
    } catch (e) {
      appLogger.logger.e("Failed to load doc assets/docs/get_started.md: $e");
      _getStartedDoc = "加载失败: $e";
    }
    notifyListeners();
  }
}