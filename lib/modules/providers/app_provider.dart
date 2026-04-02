import 'package:flutter/material.dart';

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
  final TextEditingController _inputTextController = TextEditingController();
  TextEditingController get inputTextController => _inputTextController;
  final PageController _pageController = PageController();
  PageController get pageController => _pageController;

  @override
  void dispose() {
    _inputTextController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
