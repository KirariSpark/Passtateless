import 'package:flutter/material.dart';
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
}
