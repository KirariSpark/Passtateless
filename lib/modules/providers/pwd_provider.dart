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
      "starred": false,
      "custom": ""
    },
    {
      "identifier": "测试数据2",
      "userName": "测试数据2",
      "account": "测试数据2",
      "preset": "complex",
      "removeSp": true,
      "removeDigits": true,
      "removeAlpha": false,
      "starred": true,
      "custom": ""
    },
    {
      "identifier": "测试数据3",
      "userName": "测试数据3",
      "account": "测试数据3",
      "preset": "custom",
      "removeSp": true,
      "removeDigits": false,
      "removeAlpha": false,
      "starred": true,
      "custom": ""
    }
  ];

  List<Map<String, dynamic>> _stars = [];
  List<int> _mapStarredIndex2Original = []; // 收藏列表的每一项对应在完整列表的位置

  List<Map<String, dynamic>> get pwdList => _pwdList;

  List<Map<String, dynamic>> get starredPwds {
    _stars = [];
    _mapStarredIndex2Original = [];
    for (var(index, item) in _pwdList.indexed) {
      if (item["starred"]) {
        _stars.add(item);
        _mapStarredIndex2Original.add(index);
      }
    }
    return _stars;
  }

  /// 更新指定项的数据
  (int stat, String info) setValue(int index, String key, dynamic value) {
    _pwdList[index][key] = value;
    notifyListeners();
    return (0, "");
  }

  /// 更新指定项的收藏状态
  void switchStarState(int index) {
    _pwdList[index]["starred"] = !_pwdList[index]["starred"];
    notifyListeners();
  }

  /// 从收藏列表更新指定项的收藏状态 - 它会同步更新完整列表
  void switchStarStateFromStarred(int index) {
    int indexInOriginal = _mapStarredIndex2Original[index];
    _stars.removeAt(index);
    _pwdList[indexInOriginal]["starred"] = !_pwdList[indexInOriginal]["starred"];
    notifyListeners();
  }

  /// 从所有密码中移除指定项
  void removeRecord(int index) {
    _pwdList.removeAt(index);
    notifyListeners();
  }

  /// 在所有记录条目结尾增加一条空记录，通常用于新增
  void addEmptyRecord() {
    _pwdList.add(
      {
        "identifier": "",
        "userName": "",
        "account": "",
        "preset": "simple",
        "removeSp": false,
        "removeDigits": false,
        "removeAlpha": false,
        "starred": false,
        "custom": ""
      }
    );
    notifyListeners();
  }
}
