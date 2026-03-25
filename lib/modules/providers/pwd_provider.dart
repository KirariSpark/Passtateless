import 'package:flutter/material.dart';

class PwdProvider extends ChangeNotifier {
  // List<Map<String, dynamic>> _pwdList = [];
  List<Map<String, dynamic>> _pwdList = [{
    "identifier": "测试数据1",
    "userName": "测试数据1",
    "platform": "测试数据1",
    "preset": "simple",
    "removeSp": true,
    "removeDigits": false,
    "removeAlpha": true,
    "starred": false
  },{
    "identifier": "测试数据2",
    "userName": "测试数据2",
    "platform": "测试数据2",
    "preset": "simple",
    "removeSp": true,
    "removeDigits": true,
    "removeAlpha": false,
    "starred": true
  }];
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
}