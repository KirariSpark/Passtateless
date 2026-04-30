import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/enums.dart' as enums;
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/file_mgr/json_mgr.dart';
import 'package:passtateless/modules/utils/utils.dart' as utils;
import 'package:uuid/uuid.dart';
import 'dart:convert';

const _uuid = Uuid();

class _PwdLocation {
  final String folder;
  final int index;
  const _PwdLocation({required this.folder, required this.index});

  @override
  String toString() {
    return "$folder/$index";
  }
}

class PwdProvider extends ChangeNotifier {
  Map<String, List<Map<String, dynamic>>> _pwdMap = {"": []};
  List<Map<String, dynamic>> _stars = [];

  List<Map<String, dynamic>> get starredPwds {
    _stars = [];
    _pwdMap.forEach((folder, items) {
      for (var item in items) {
        if (item["starred"]) {
          _stars.add(item);
        }
      }
    });
    return _stars;
  }

  List<String> get pwdFolders => _pwdMap.keys.toList();

  List<Map<String, dynamic>> getPwdList(String folder) => _pwdMap[folder] ?? [];

  /// 对 _pwdMap 的键进行排序，同时确保空字符串 "" 永远在最后
  void _sortPwdMapKeys() {
    appLogger.logger.i("Sorting passwords");
    final sortedKeys = _pwdMap.keys.toList()..sort((a, b) {
        if (a.isEmpty && b.isEmpty) return 0;
        if (a.isEmpty) return 1; // a 是空字符串，排到后面
        if (b.isEmpty) return -1; // b 是空字符串，排到后面
        return a.compareTo(b); // 其他情况按字母顺序排序
      });

    // 按照排序后的键重新构建 Map，以保持新的顺序
    final sortedMap = <String, List<Map<String, dynamic>>>{};
    for (var key in sortedKeys) {
      sortedMap[key] = _pwdMap[key]!;
    }
    _pwdMap = sortedMap;
    appLogger.logger.i("Password sorted");
  }

  /// 通过 id 查找该记录在 _pwdMap 中的真实位置
  _PwdLocation? _findLocationById(String id) {
    appLogger.logger.i("Finding password id $id");
    for (var folder in _pwdMap.keys) {
      for (var (index, item) in _pwdMap[folder]!.indexed) {
        if (item["id"] == id) {
          final loc = _PwdLocation(folder: folder, index: index);
          appLogger.logger.i("Found password id $id at $loc");
          return loc;
        }
      }
    }
    appLogger.logger.i("No password matching id $id");
    return null;
  }

  /// 解析字典，补上UUID，并设置自身的_pwdMap
  ErrorCode _parsePwdMap(Map map, {bool allowExistingUuid = true}) {
    final newPwdMap = <String, List<Map<String, dynamic>>>{};

    for (final entry in map.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      if (value is List) {
        final processedList = <Map<String, dynamic>>[];
        for (final item in value) {
          final itemMap = Map<String, dynamic>.from(item as Map);
          final hasUuid = itemMap.containsKey("id") &&
              itemMap["id"] != null &&
              itemMap["id"].toString().isNotEmpty;

          // 不允许已存在的UUID时直接返回错误
          if (!allowExistingUuid && hasUuid) {
            return ErrorCode.existingUuid;
          }

          // 没有UUID则自动生成
          if (!hasUuid) {
            appLogger.logger.d("Generating id for password");
            itemMap["id"] = _uuid.v4();
          }

          processedList.add(itemMap);
        }
        newPwdMap[key] = processedList;
      }
    }

    // 只有全部成功才更新 _pwdMap，并保留原有不相关的键
    _pwdMap.addAll(newPwdMap);
    if (!_pwdMap.containsKey("")) {
      _pwdMap[""] = [];
    }

    notifyListeners();
    return ErrorCode.success;
  }

  /// 使用 id 更新指定项的数据
  ErrorCode setValueById(String id, String key, String value) {
    appLogger.logger.i("Updating password id $id");
    final loc = _findLocationById(id);
    if (loc == null) {
      appLogger.logger.e("No such password");
      return ErrorCode.noSuchId;
    } else {
      _pwdMap[loc.folder]![loc.index][key] = value;
      appLogger.logger.i("Password updated successfully");
      notifyListeners();
      return ErrorCode.success;
    }
  }

  /// 使用 id 从所有密码中移除指定项
  ErrorCode removeRecordById(String id) {
    appLogger.logger.i("Removing password id $id");
    final loc = _findLocationById(id);
    if (loc == null) {
      appLogger.logger.e("No such password");
      return ErrorCode.noSuchId;
    } else {
      _pwdMap[loc.folder]!.removeAt(loc.index);
      appLogger.logger.i("Password removed successfully");
      notifyListeners();
      return ErrorCode.success;
    }
  }

  /// 在指定文件夹中增加一条空记录
  String addEmptyRecordTo(String folder) {
    appLogger.logger.i("Adding empty password to folder $folder");
    final id = _uuid.v4();
    appLogger.logger.d("Password id: $id");
    if (!_pwdMap.containsKey("")) {
      _pwdMap[""] = [];
    }
    _pwdMap[folder]!.add({
      "id": id,
      "identifier": "",
      "userName": "example",
      "account": "example.com",
      "starred": false,
    });
    appLogger.logger.i("Successfully added password");
    notifyListeners();
    return id;
  }

  /// 通过 id 修改收藏状态
  void switchStarStateById(String id) {
    appLogger.logger.i("Switching star state of password id $id");
    final loc = _findLocationById(id);
    if (loc != null) {
      _pwdMap[loc.folder]![loc.index]["starred"] = !_pwdMap[loc.folder]![loc.index]["starred"];
      appLogger.logger.i("Successfully switched star state");
      notifyListeners();
    } else {
      appLogger.logger.e("No such password");
    }
  }

  /// 通过 id 查找记录
  Map<String, dynamic> getItemById(String id) {
    appLogger.logger.i("Getting password by id $id");
    final loc = _findLocationById(id);
    if (loc != null) return _pwdMap[loc.folder]![loc.index];
    return {};
  }

  /// 新增一个文件夹
  ErrorCode addFolder(String name) {
    appLogger.logger.i("Adding folder $name");
    if (name == "") {
      appLogger.logger.e("Empty folder name");
      return ErrorCode.emptyFolderName;
    } else if (_pwdMap.containsKey(name)) {
      appLogger.logger.e("Duplicate folder name");
      return ErrorCode.duplicateFolderName;
    } else {
      _pwdMap.addAll({name: []});
      _sortPwdMapKeys(); // 先排序
      notifyListeners(); // 再通知
      appLogger.logger.i("Successfully added folder");
      return ErrorCode.success;
    }
  }

  /// 移除一个文件夹
  ErrorCode removeFolder(String name) {
    appLogger.logger.i("Removing folder $name");
    _pwdMap.remove(name);
    notifyListeners();
    return ErrorCode.success;
  }

  /// 重命名文件夹
  ErrorCode renameFolder(String before, String after) {
    appLogger.logger.i("Renaming folder $before to $after");
    if (after == "") {
      appLogger.logger.e("New name is empty");
      return ErrorCode.emptyFolderName;
    } else if (_pwdMap.containsKey(after)) {
      appLogger.logger.e("New name duplicated");
      return ErrorCode.duplicateFolderName;
    } else {
      _pwdMap[after] = _pwdMap[before]!;
      _pwdMap.remove(before);
      _sortPwdMapKeys(); // 先排序
      notifyListeners(); // 再通知
      appLogger.logger.i("Renamed successfully");
      return ErrorCode.success;
    }
  }

  /// 获取当前密码的 JSON 字符串
  /// [master] 用户输入的主密码明文
  /// [masterSHA] 来自 Provider 的主密码哈希
  (ErrorCode, String) getPwdJson(String master, String masterSHA) {
    appLogger.logger.i("Getting JSON text of current password map");
    if (utils.toSHA256(master) == masterSHA) {
      appLogger.logger.i("Correct password, getting JSON");
      return (ErrorCode.success, utils.formatJSON(json.encode(_pwdMap)).$2);
    } else {
      appLogger.logger.e("Wrong password");
      return (ErrorCode.wrongPwd, "");
    }
  }

  ErrorCode setPwdByJson(String jsonText) {
    try {
      appLogger.logger.i("Setting password by json");
      final res = json.decode(jsonText);
      if (res is Map) {
        appLogger.logger.d("JSON decoded successfully");
        final stat = _parsePwdMap(res, allowExistingUuid: false);
        if (stat == ErrorCode.success) {
          appLogger.logger.i("Password successfully imported");
          return ErrorCode.success;
        } else {
          appLogger.logger.e("Can not import password: $stat");
          return stat;
        }
      } else {
        appLogger.logger.e("Input data type is not Map");
        return ErrorCode.isNotMap;
      }
    } catch (e) {
      appLogger.logger.e(ErrorCode.jsonFormatError.format(e.toString()));
      return ErrorCode.jsonFormatError;
    }
  }

  /// 读取加密的归档文件
  Future<ErrorCode> readArchive(String masterPwd) async {
    appLogger.logger.i("Reading password archive");
    final (stat, res) = await readEncryptedJsonFile(
      enums.Paths.pwdRecord.path,
      masterPwd,
    );
    appLogger.logger.d("Read stat: ${stat.code}");
    if (stat == ErrorCode.success) {
      if (res is Map) {
        _pwdMap = {};
        _parsePwdMap(res);
        appLogger.logger.i("Successfully read archive");
        return ErrorCode.success;
      } else {
        appLogger.logger.i("Reading result is not a Map");
        return ErrorCode.jsonFormatError;
      }
    } else if (stat == ErrorCode.fileNotExist) {
      appLogger.logger.w("No archive file found, creating empty archive using current master password");
      await saveArchive(masterPwd);
      return await readArchive(masterPwd);
    } else {
      appLogger.logger.e("Failed to read archive, code: ${stat.code}");
      return stat;
    }
  }

  /// 保存当前数据到加密的归档文件
  Future<ErrorCode> saveArchive(String masterPwd) async {
    appLogger.logger.i("Writing password archive");
    final stat = await writeEncryptedJsonFile(enums.Paths.pwdRecord.path, _pwdMap, masterPwd);
    appLogger.logger.d("Stat: ${stat.code}");
    return stat;
  }

  /// 更改主密码
  Future<ErrorCode> changeMasterPwd({
    required String currentMaster,
    required String inputOld,
    required String inputNew,
    required String inputConfirm,
  }) async {
    String oldHash = utils.toSHA256(inputOld);
    appLogger.logger.i("Changing master password");
    if (currentMaster == oldHash) {
      // 旧密码验证通过，验证新密码与确认密码是否相同
      if (inputNew == inputConfirm) {
        // 再验证它们是否为空
        if ((inputNew.isNotEmpty) && (inputConfirm.isNotEmpty)) {
          appLogger.logger.i("Verifying passed, saving archive using new password");
          // 新密码和确认密码验证通过，执行重新加密保存
          return await saveArchive(utils.toSHA256(inputNew));
        } else {
          appLogger.logger.e("Empty new password");
          return ErrorCode.emptyPwd;
        }
      } else {
        appLogger.logger.e("Confirm password not same as new password");
        return ErrorCode.wrongConfirmPwd;
      }
    } else {
      appLogger.logger.e("Wrong old password");
      return ErrorCode.wrongPwd;
    }
  }
}
