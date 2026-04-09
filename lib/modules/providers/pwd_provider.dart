import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/file_mgr/json_mgr.dart';
import 'package:passtateless/modules/core/enums.dart' as enums;

class PwdLocation {
  final String folder;
  final int index;
  const PwdLocation({required this.folder, required this.index});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PwdLocation &&
              runtimeType == other.runtimeType &&
              folder == other.folder &&
              index == other.index;

  @override
  int get hashCode => folder.hashCode ^ index.hashCode;
}


class PwdProvider extends ChangeNotifier {
  Map<String, List<Map<String, dynamic>>> _pwdMap = {
    "": [
      {
        "identifier": "test",
        "userName": "test",
        "account": "test",
        "starred": false
      }
    ],
    "test": [
      {
        "identifier": "test",
        "userName": "test",
        "account": "test",
        "starred": true
      }
    ]
  };
  List<Map<String, dynamic>> _stars = [];
  List<PwdLocation> _starredLocation = [];

  // TODO: 实现完整功能
  List<Map<String, dynamic>> get pwdList => _pwdMap[""] ?? [];

  List<Map<String, dynamic>> get starredPwds {
    _stars = [];
    _starredLocation = [];
    _pwdMap.forEach((folder, items) {
      for (var (index, item) in items.indexed) {
        if (item["starred"]) {
          _stars.add(item);
          _starredLocation.add(PwdLocation(folder: folder, index: index));
        }
      }
    });
    return _stars;
  }

  List<String> get pwdFolders => _pwdMap.keys.toList();

  /// 更新指定项的数据
  (int stat, String info) setValue(PwdLocation loc, String key, dynamic value) {
    // 包含这个文件夹，且索引未越界
    if (_pwdMap.containsKey(loc.folder) && loc.index < _pwdMap[loc.folder]!.length) {
      _pwdMap[loc.folder]![loc.index][key] = value;
      notifyListeners();
      return (0, "");
    }
    return (-1, "Location not found");
  }

  /// 更新指定项的收藏状态
  void switchStarState(PwdLocation loc) {
    if (_pwdMap.containsKey(loc.folder) && loc.index < _pwdMap[loc.folder]!.length) {
      _pwdMap[loc.folder]![loc.index]["starred"] = !_pwdMap[loc.folder]![loc.index]["starred"];
      notifyListeners();
    }
  }

  /// 从收藏列表更新指定项的收藏状态 - 它会同步更新完整列表
  void switchStarStateFromStarred(int index) {
    PwdLocation loc = _starredLocation[index];
    _stars.removeAt(index);
    _starredLocation.removeAt(index);
    _pwdMap[loc.folder]![loc.index]["starred"] = !_pwdMap[loc.folder]![loc.index]["starred"];
    notifyListeners();
  }

  /// 从所有密码中移除指定项
  void removeRecord(PwdLocation loc) {
    if (_pwdMap.containsKey(loc.folder) && loc.index < _pwdMap[loc.folder]!.length) {
      _pwdMap[loc.folder]!.removeAt(loc.index);
      notifyListeners();
    }
  }

  /// 在未分类记录条目结尾增加一条空记录
  void addEmptyRecord() {
    if (!_pwdMap.containsKey("")) {
      _pwdMap[""] = [];
    }
    _pwdMap[""]!.add({
      "identifier": "",
      "userName": "example",
      "account": "example.com",
      "starred": false
    });
    notifyListeners();
  }

  /// 新增一个文件夹
  ErrorCode addFolder(String name) {
    if (name == "") {
      return ErrorCode.emptyKey;
    } else if (_pwdMap.containsKey(name)) {
      return ErrorCode.duplicateKey;
    } else {
      _pwdMap.addAll({name: []});
      notifyListeners();
      return ErrorCode.success;
    }
  }

  /// 读取加密的归档文件
  Future<ErrorCode> readArchive(String masterPwd) async {
    final (errorCode, res) = await readEncryptedJsonFile(enums.Paths.pwdRecord.path, masterPwd);
    if (errorCode == ErrorCode.success) {
      if (res is Map) {
        _pwdMap = {};
        res.forEach((key, value) {
          if (value is List) {
            _pwdMap[key.toString()] = value.cast<Map<String, dynamic>>();
          }
        });
        if (!_pwdMap.containsKey("")) {
          _pwdMap[""] = [];
        }
        notifyListeners();
        return ErrorCode.success;
      } else {
        return ErrorCode.jsonFormatError;
      }
    }
    return errorCode;
  }

  /// 保存当前数据到加密的归档文件
  Future<ErrorCode> saveArchive(String masterPwd) async {
    final (errorCode, _) = await writeEncryptedJsonFile(enums.Paths.pwdRecord.path, _pwdMap, masterPwd);
    return errorCode;
  }
}
