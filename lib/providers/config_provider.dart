import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:passtateless/scripts/file_manager.dart' as file_manager;

class ConfigProvider extends ChangeNotifier {
  bool _featureEnabled = false;
  bool get featureEnabled => _featureEnabled;
  set featureEnabled(bool value) {
    _featureEnabled = value;
    notifyListeners();
  }

  // 主密码
  final TextEditingController _masterPassword = TextEditingController();
  TextEditingController get masterPassword => _masterPassword;

  final TextEditingController _v2ConfigJson = TextEditingController();
  TextEditingController get v2ConfigJson => _v2ConfigJson;

  // 配置文件
  /// 加载示例文件
  Future<void> loadDemoFiles() async {
    if (_selectedDemo == "") {
      _v2ConfigJson.text = "请先选择文件";
      notifyListeners();
      return;
    }

    try {
      final String content = await rootBundle.loadString("assets/examples/$_selectedDemo");
      _v2ConfigJson.text = content;
      notifyListeners();
    } catch (e) {
      _v2ConfigJson.text = "$e";
      notifyListeners();
    }
  }

  // 可用示例文件列表
  final Map<String, String> _availableDemos = {
    "template.json": "模板 / 上一次选择",
    "complex.json": "复杂密码",
    "digits.json": "仅数字",
    "no_sp.json": "无特殊字符",
  };

  Map<String, String> get availableDemos => _availableDemos;

  // 选中的示例文件
  String _selectedDemo = "";
  String get selectedDemo => _selectedDemo;

  void selectDemo(String? value) {
    if (value != null) {
      _selectedDemo = value;
      notifyListeners();
    } else {
      _selectedDemo = "";
      notifyListeners();
    }
  }

  Future<(int stat, String info)> saveConfig() async {
    final saveRes = await file_manager.saveConfigEncrypted(masterPassword.text, v2ConfigJson.text);
    return saveRes;
  }

  Future<(int stat, String info)> loadConfig() async {
    final (int, String, String)loadRes = await file_manager.loadConfigEncrypted(masterPassword.text);
    if (loadRes.$1 == 0) {
      _v2ConfigJson.text = loadRes.$2;
      notifyListeners();
    }
    return (loadRes.$1, loadRes.$3);
  }

  Future<(int stat, String info)> deleteConfig() async {
    final delRes = await file_manager.deleteConfig();
    if (delRes.$1 == 0) {
      _v2ConfigJson.text = "";
      notifyListeners();
    }
    return delRes;
  }
}