import 'package:flutter/material.dart';
import 'package:passtateless/modules/utils/utils.dart' as utils;
import 'package:passtateless/modules/core/enums.dart';

class AppProvider extends ChangeNotifier {
  // ————UI相关状态————
  // 页面索引
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // ————控制器————
  final PageController _pageController = PageController();
  PageController get pageController => _pageController;

  // ————设置项————
  // 提醒我更改主密码
  var _remindMe = RemindDays.days180;
  RemindDays get remindMe => _remindMe;
  set remindMe(RemindDays value) {
    _remindMe = value;
    notifyListeners();
  }

  // 主题
  var _color = Colors.blueGrey;
  var _colorScheme = ColorScheme.fromSeed(seedColor: Colors.blueGrey);
  var _darkColorScheme = ColorScheme.fromSeed(seedColor: Colors.blueGrey, brightness: Brightness.dark);
  MaterialColor get color => _color;
  ColorScheme get colorScheme => _colorScheme;
  ColorScheme get darkColorScheme => _darkColorScheme;
  set color(MaterialColor value) {
    _color = value;
    _colorScheme = ColorScheme.fromSeed(seedColor: value);
    _darkColorScheme = ColorScheme.fromSeed(seedColor: value, brightness: Brightness.dark);
    notifyListeners();
  }

  // 主密码
  String _masterPwd = "";
  String get masterPwd => _masterPwd;
  set masterPwd(String value) {
    _masterPwd = utils.toSHA256(value);
    notifyListeners();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
