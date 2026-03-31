import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/file_mgr/json_mgr.dart';
import 'package:passtateless/modules/core/enums.dart' as enums;

class PwdProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _pwdList = [];
  List<Map<String, dynamic>> _stars = [];
  // 收藏列表的每一项对应在完整列表的位置
  List<int> _mapStarredIndex2Original = [];

  List<Map<String, dynamic>> get pwdList => _pwdList;
  List<Map<String, dynamic>> get starredPwds {
    _stars = [];
    _mapStarredIndex2Original = [];
    for (var (index, item) in _pwdList.indexed) {
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
    _pwdList.add({
      "identifier": "",
      "userName": "example",
      "account": "example.com",
      "removeSp": false,
      "removeDigits": false,
      "removeAlpha": false,
      "starred": false
    });
    notifyListeners();
  }

  /// 读取加密的归档文件
  ///
  /// [masterPwd] 主密码，用于解密文件
  /// 返回错误码
  Future<ErrorCode> readArchive(String masterPwd) async {
    final (errorCode, res) = await readEncryptedJsonFile(
      enums.Paths.pwdRecord.path,
      masterPwd,
    );

    if (errorCode == ErrorCode.success) {
      if (res is List) {
        // 将读取到的 dynamic List 转换为 List<Map<String, dynamic>>
        _pwdList = res.cast<Map<String, dynamic>>();
        notifyListeners();
        return ErrorCode.success;
      } else {
        return ErrorCode.jsonFormatError;
      }
    }
    return errorCode;
  }

  /// 保存当前数据到加密的归档文件
  ///
  /// [masterPwd] 主密码，用于加密文件
  /// 返回错误码
  Future<ErrorCode> saveArchive(String masterPwd) async {
    final (errorCode, _) = await writeEncryptedJsonFile(
      enums.Paths.pwdRecord.path,
      _pwdList,
      masterPwd,
    );
    return errorCode;
  }
}
