import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/file_mgr/core_mgr.dart' as core_mgr;
import 'package:passtateless/modules/file_mgr/json_mgr.dart' as json_mgr;
import 'package:passtateless/modules/utils/utils.dart' as utils;

class AppProvider extends ChangeNotifier {
  // ————UI相关状态————
  // 页面索引
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  set currentIndex(int index) {
    appLogger.logger.i("Switching to page $index");
    _currentIndex = index;
    notifyListeners();
  }

  // ————设置项————
  // 提醒我更改主密码
  var _remindMe = RemindDays.days180;
  RemindDays get remindMe => _remindMe;
  set remindMe(RemindDays value) {
    appLogger.logger.i("Setting remind days to ${value.name}");
    _remindMe = value;
    notifyListeners();
  }

  // 主题
  AvailableColors _currentColor = AvailableColors.indigo;
  AvailableColors get currentColor => _currentColor;
  ContrastLevels _currentContrast = ContrastLevels.normal;
  ContrastLevels get currentContrast => _currentContrast;
  ColorScheme get colorScheme => ColorScheme.fromSeed(seedColor: _currentColor.color, contrastLevel: _currentContrast.contrast);
  ColorScheme get darkColorScheme => ColorScheme.fromSeed(seedColor: _currentColor.color, brightness: Brightness.dark, contrastLevel: _currentContrast.contrast);
  set color(AvailableColors value) {
    appLogger.logger.i("Setting color to ${value.name}");
    _currentColor = value;
    notifyListeners();
  }
  set contrast(ContrastLevels value) {
    appLogger.logger.i("Setting contrast to ${value.name}");
    _currentContrast = value;
    notifyListeners();
  }

  // 动画速度
  AnimationDilation _currentDilation = AnimationDilation.normal;
  AnimationDilation get currentDilation => _currentDilation;
  set currentDilation(AnimationDilation value) {
    appLogger.logger.i("Setting time dilation to $value");
    timeDilation = value.dilation;
    _currentDilation = value;
    notifyListeners();
  }

  // 路由动画
  NavigatorMode _currentNavMode = NavigatorMode.material;
  NavigatorMode get currentNavMode => _currentNavMode;
  set currentNavMode(NavigatorMode value) {
    appLogger.logger.i("Setting navigator mode to ${value.name}");
    _currentNavMode = value;
    notifyListeners();
  }

  // 日志等级
  LogLevels _currentLogLevel = LogLevels.debug;
  LogLevels get currentLogLevel => _currentLogLevel;
  set currentLogLevel(LogLevels value) {
    appLogger.logger.i("Setting log level to ${value.name}");
    appLogger.setLevel(value.lvl);
    _currentLogLevel = value;
    notifyListeners();
  }

  // ————主密码相关————
  // 主密码
  String _masterPwd = "";
  String get masterPwd => _masterPwd;
  set masterPwd(String value) {
    appLogger.logger.i("Got master password");
    _masterPwd = utils.toSHA256(value);
    notifyListeners();
  }

  // 是否需要更改主密码(为真时，表示需要更改)
  bool _needChangeMaster = false;
  bool get needChangeMaster => _needChangeMaster;

  // ————配置文件相关————
  /// 读取配置文件
  Future<ErrorCode> readConfig() async {
    appLogger.logger.i("Reading config file");
    final (stat, res) = await json_mgr.readJsonFile(Paths.config.toString());
    appLogger.logger.i("Stat: ${stat.code}");

    if (stat == ErrorCode.success && res != null && res is Map) {
      try {
        appLogger.logger.i("Restoring config");
        _restoreConfig(res);
      } catch (e) {
        appLogger.logger.e("Restoring failed, config may be broken: ${e.toString()}");
        return ErrorCode.brokenConfig;
      }
      // 检查是否要更改主密码
      appLogger.logger.i("Checking if master password needs to be changed");
      final lastChange = await masterLastChanged();
      if (lastChange.$1 == ErrorCode.success) {
        appLogger.logger.d("Last changed at ${lastChange.$2.toString()}");
        appLogger.logger.d("Current time: ${DateTime.now().toString()}");
        // 查看现在的时间是否在 上次更改的时间+提醒天数 之后
        // 如果在之后，则意味着该更改主密码了
        _needChangeMaster = DateTime.now().isAfter(
          lastChange.$2.add(_remindMe.value),
        );
      } else {
        appLogger.logger.e("Can not check master password state: ${lastChange.$1.code}");
        return lastChange.$1;
      }
      appLogger.logger.i("Config reading completed");
      return stat;
    } else {
      appLogger.logger.e("Can not read config");
      return stat;
    }
  }

  /// 从文本恢复配置
  ErrorCode restoreConfigFromText(String text, {bool fallback = true}) {
    try {
      appLogger.logger.i("Restoring config from text");
      final res = json.decode(text);
      _restoreConfig(res, fallback: fallback);
      return ErrorCode.success;
    } catch (e) {
      appLogger.logger.e("Can not restore config fron text: ${e.toString()}");
      return ErrorCode.brokenConfig;
    }
  }

  /// 获取当前配置对应的字典
  Map<String, String> _getConfigMap() {
    return {
      'remindMe': _remindMe.name,
      'currentColor': _currentColor.name,
      'currentDilation': _currentDilation.name,
      'currentContrast': _currentContrast.name,
      'currentLogLevel': _currentLogLevel.name,
      'currentNavMode': _currentNavMode.name
    };
  }

  /// 恢复配置项的值
  void _restoreConfig(Map res, {bool fallback = true}) {
    remindMe = utils.restoreEnumSetting<RemindDays>(
      jsonMap: res,
      key: 'remindMe',
      enumValues: RemindDays.values,
      defaultValue: _remindMe,
      fallback: fallback
    );

    color = utils.restoreEnumSetting<AvailableColors>(
      jsonMap: res,
      key: 'currentColor',
      enumValues: AvailableColors.values,
      defaultValue: _currentColor,
      fallback: fallback
    );

    currentDilation = utils.restoreEnumSetting<AnimationDilation>(
      jsonMap: res,
      key: 'currentDilation',
      enumValues: AnimationDilation.values,
      defaultValue: _currentDilation,
      fallback: fallback
    );

    contrast = utils.restoreEnumSetting<ContrastLevels>(
      jsonMap: res,
      key: 'currentContrast',
      enumValues: ContrastLevels.values,
      defaultValue: _currentContrast,
      fallback: fallback
    );

    currentLogLevel = utils.restoreEnumSetting<LogLevels>(
      jsonMap: res,
      key: 'currentLogLevel',
      enumValues: LogLevels.values,
      defaultValue: _currentLogLevel,
      fallback: fallback
    );

    currentNavMode = utils.restoreEnumSetting<NavigatorMode>(
      jsonMap: res,
      key: 'currentNavMode',
      enumValues: NavigatorMode.values,
      defaultValue: _currentNavMode,
      fallback: fallback
    );
  }

  /// 保存配置文件
  Future<ErrorCode> saveConfig() async {
    appLogger.logger.i("Saving config");
    return await json_mgr.writeJsonFile(Paths.config.toString(), _getConfigMap());
  }

  /// 获取配置文件的JSON字符串
  String getSettingsJson() {
    appLogger.logger.i("Getting settings JSON");
    final (stat, res) = utils.formatJSON(json.encode(_getConfigMap()));
    if (stat == ErrorCode.success) {
      appLogger.logger.i("Successfully got settings JSON");
      return res;
    } else {
      appLogger.logger.e("Can not get settings JSON: ${stat.code}");
      return "";
    }
  }

  Future<(ErrorCode, DateTime)> masterLastChanged() async {
    appLogger.logger.i("Checking last changed time for master password");
    final res = await core_mgr.readLabelFile(Paths.masterPwdLabel.path, autoCreate: true);
    if (res.$1 == ErrorCode.success) {
      return (ErrorCode.success, res.$2!);
    } else {
      return (res.$1, DateTime.now());
    }
  }
}
