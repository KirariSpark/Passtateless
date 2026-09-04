import 'package:flutter/material.dart';
import 'package:passtateless/modules/compability/flatten.dart';
import 'package:passtateless/modules/core/enums.dart' as enums;
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/core/pwd_item.dart';
import 'package:passtateless/modules/file_mgr/json_mgr.dart';
import 'package:passtateless/modules/utils/utils.dart' as utils;
import 'package:uuid/uuid.dart';
import 'dart:convert';

const _uuid = Uuid();

class PwdProvider extends ChangeNotifier {
  /// 当前全部密码记录的扁平列表，标签随每条记录存储
  final List<PwdItem> _pwdList = [];

  /// 已开启"移除"的字符类型队列，队首为最旧的项
  final List<enums.CharType> _removedQueue = [];

  bool get removeDigits => _removedQueue.contains(enums.CharType.digits);
  bool get removeAlpha => _removedQueue.contains(enums.CharType.alpha);
  bool get removeSp => _removedQueue.contains(enums.CharType.specialChar);

  set removeDigits(bool value) => _setRemoved(enums.CharType.digits, value);
  set removeAlpha(bool value) => _setRemoved(enums.CharType.alpha, value);
  set removeSp(bool value) => _setRemoved(enums.CharType.specialChar, value);

  void _setRemoved(enums.CharType type, bool enabled) {
    if (enabled) {
      // 若已开启则视为重新确认：摘除后重新入队
      _removedQueue.remove(type);
      // 队列已达上限(2)时，最旧的(队首)项自动取消移除
      if (_removedQueue.length >= 2) {
        _removedQueue.removeAt(0);
      }
      _removedQueue.add(type);
    } else {
      // 单独取消移除，从队列中任意位置摘除
      _removedQueue.remove(type);
    }
    notifyListeners();
  }

  /// 全部密码记录
  List<PwdItem> get pwdList => _pwdList;

  /// 被收藏的密码记录
  List<PwdItem> get starredPwdList =>
      pwdList.where((item) => item.starred).toList();

  /// 通过 id 查找记录，找不到时返回 null
  PwdItem? getItemById(String id) {
    appLogger.logger.i("Getting password by id $id");
    for (final item in _pwdList) {
      if (item.isMe(id)) return item;
    }
    appLogger.logger.e("No password matching id $id");
    return null;
  }

  /// 使用 [changes] 就地修改指定记录，随后通知监听者
  ///
  /// 找不到对应 id 时返回 [ErrorCode.noSuchId]，不做任何修改。
  ErrorCode mutateById(String id, void Function(PwdItem record) changes) {
    appLogger.logger.i("Updating password id $id");
    final item = getItemById(id);
    if (item == null) {
      appLogger.logger.e("No such password");
      return ErrorCode.noSuchId;
    }
    changes(item);
    appLogger.logger.i("Password updated successfully");
    notifyListeners();
    return ErrorCode.success;
  }

  /// 使用 id 从所有密码中移除指定项
  ErrorCode removeRecordById(String id) {
    appLogger.logger.i("Removing password id $id");
    final int before = _pwdList.length;
    _pwdList.removeWhere((item) => item.isMe(id));
    if (_pwdList.length == before) {
      appLogger.logger.e("No such password");
      return ErrorCode.noSuchId;
    }
    appLogger.logger.i("Password removed successfully");
    notifyListeners();
    return ErrorCode.success;
  }

  /// 增加一条空记录，可附带初始 [tags]
  String addEmptyRecord({List<String> tags = const []}) {
    appLogger.logger.i("Adding empty password record");
    final String id = _uuid.v4();
    appLogger.logger.d("Password id: $id");
    _pwdList.add(
      PwdItem(
        id: id,
        userName: "example",
        account: "example.com",
        tags: tags,
      ),
    );
    appLogger.logger.i("Successfully added password");
    notifyListeners();
    return id;
  }

  /// 通过 id 修改收藏状态
  void switchStarStateById(String id) {
    appLogger.logger.i("Switching star state of password id $id");
    final item = getItemById(id);
    if (item == null) {
      appLogger.logger.e("No such password");
      return;
    }
    item.starred = !item.starred;
    appLogger.logger.i("Successfully switched star state");
    notifyListeners();
  }

  /// 把解码后的存档内容解析为密码记录列表
  ///
  /// 新版存档的根节点是“条目字典”的列表；旧版存档的根节点是
  /// “文件夹名 -> 条目列表”的字典，旧版会被展平，文件夹名自动并入标签
  /// （详见 flatten.dart）。格式无法识别时抛出 [FormatException]。
  List<PwdItem> _parsePwdData(dynamic decoded) {
    if (decoded is List) {
      return [
        for (final item in decoded)
          PwdItem.fromMap(Map<String, dynamic>.from(item as Map)),
      ];
    } else if (decoded is Map) {
      final oldMap = <String, List<Map<String, dynamic>>>{};
      for (final entry in decoded.entries) {
        final key = entry.key.toString();
        final value = entry.value;
        if (value is List) {
          oldMap[key] = [
            for (final item in value)
              Map<String, dynamic>.from(item as Map),
          ];
        }
      }
      return flattenAndGetItemList(oldMap);
    }
    throw const FormatException("Decoded data is neither a List nor a Map");
  }

  /// 获取当前密码的 JSON 字符串（导出）
  ///
  /// [master] 用户输入的主密码明文
  /// [masterSHA] 来自 Provider 的主密码哈希
  (ErrorCode, String) getPwdJson(String master, String masterSHA) {
    appLogger.logger.i("Getting JSON text of current password list");
    if (utils.toSHA256(master) == masterSHA) {
      appLogger.logger.i("Correct password, getting JSON");
      final list = [for (final item in _pwdList) item.toMap()];
      return (ErrorCode.success, utils.formatJSON(json.encode(list)).$2);
    } else {
      appLogger.logger.e("Wrong password");
      return (ErrorCode.wrongPwd, "");
    }
  }

  /// 用 JSON 全文替换当前的所有密码记录（导入）
  ///
  /// 兼容新版扁平列表与旧版文件夹字典格式。
  ErrorCode setPwdByJson(String jsonText) {
    try {
      appLogger.logger.i("Setting passwords by json");
      final res = json.decode(jsonText);
      final parsed = _parsePwdData(res);
      _pwdList
        ..clear()
        ..addAll(parsed);
      appLogger.logger.i("Passwords successfully imported");
      return ErrorCode.success;
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
      try {
        final parsed = _parsePwdData(res);
        _pwdList
          ..clear()
          ..addAll(parsed);
        appLogger.logger.i("Successfully read archive");
        return ErrorCode.success;
      } catch (e) {
        appLogger.logger.e("Failed to parse archive: ${e.toString()}");
        return ErrorCode.jsonFormatError;
      }
    } else if (stat == ErrorCode.fileNotExist) {
      appLogger.logger.w(
        "No archive file found, creating empty archive using current master password",
      );
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
    final stat = await writeEncryptedJsonFile(
      enums.Paths.pwdRecord.path,
      [for (final item in _pwdList) item.toMap()],
      masterPwd,
    );
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
          appLogger.logger.i(
            "Verifying passed, saving archive using new password",
          );
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
