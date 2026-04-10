import 'package:flutter/material.dart';
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

  // 设置项
  var _remindMe = RemindDays.days180;
  RemindDays get remindMe => _remindMe;
  set remindMe(RemindDays value) {
    _remindMe = value;
    notifyListeners();
  }

  // 主密码
  String _masterPwd = "";
  String get masterPwd => _masterPwd;
  set masterPwd(String value) {
    _masterPwd = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
