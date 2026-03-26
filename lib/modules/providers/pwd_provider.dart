import 'package:flutter/material.dart';

class PwdProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _pwdList = [
    {
      "identifier": "测试数据1",
      "userName": "测试数据1",
      "account": "测试数据1",
      "preset": "simple",
      "removeSp": true,
      "removeDigits": false,
      "removeAlpha": true,
      "starred": false
    },
    {
      "identifier": "测试数据2",
      "userName": "测试数据2",
      "account": "测试数据2",
      "preset": "complex",
      "removeSp": true,
      "removeDigits": true,
      "removeAlpha": false,
      "starred": true
    }
  ];

  List<Map<String, dynamic>> get pwdList => _pwdList;

  List<Map<String, dynamic>> get starredPwds {
    List<Map<String, dynamic>> stars = [];
    for (var item in _pwdList) {
      if (item["starred"]) {
        stars.add(item);
      }
    }
    return stars;
  }

  /// 更新指定项的数据
  (int stat, String info) setValue(int index, String key, dynamic value) {
    _pwdList[index][key] = value;
    notifyListeners();
    return (0, "");
  }
}
