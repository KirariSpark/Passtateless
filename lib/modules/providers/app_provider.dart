import 'package:flutter/material.dart';
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

  // ————控制器————
  final PageController _pageController = PageController();
  PageController get pageController => _pageController;

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
  ColorScheme get colorScheme => ColorScheme.fromSeed(seedColor: _currentColor.color);
  ColorScheme get darkColorScheme => ColorScheme.fromSeed(seedColor: _currentColor.color, brightness: Brightness.dark);
  set color(AvailableColors value) {
    appLogger.logger.i("Setting color to ${value.name}");
    _currentColor = value;
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
      // 读取并还原提醒时间配置
      if (res.containsKey('remindMe') && res['remindMe'] is String) {
        appLogger.logger.i("Restoring remind settings");
        remindMe = RemindDays.values.firstWhere(
          (e) => e.name == res['remindMe'],
          orElse: () => _remindMe, // 如果名称没找到对应的枚举，保持默认值
        );
      }

      // 读取并还原主题颜色配置
      if (res.containsKey('currentColor') && res['currentColor'] is String) {
        appLogger.logger.i("Restoring color settings");
        color = AvailableColors.values.firstWhere(
          (e) => e.name == res['currentColor'],
          orElse: () => _currentColor, // 如果名称没找到对应的枚举，保持默认值
        );
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

  /// 保存配置文件
  Future<ErrorCode> saveConfig() async {
    appLogger.logger.i("Saving config");
    final configMap = {
      'remindMe': _remindMe.name,
      'currentColor': _currentColor.name,
    };
    return await json_mgr.writeJsonFile(Paths.config.toString(), configMap);
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
