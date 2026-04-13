import 'package:flutter/material.dart';
import 'package:passtateless/modules/utils/utils.dart' as utils;
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/file_mgr/core_mgr.dart' as core_mgr;
import 'package:passtateless/modules/file_mgr/json_mgr.dart' as json_mgr;
import 'package:passtateless/modules/core/error_codes.dart';

class AppProvider extends ChangeNotifier {
  // ————UI相关状态————
  // 页面索引
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  set currentIndex(int index) {
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
    _remindMe = value;
    notifyListeners();
  }

  // 主题
  AvailableColors _currentColor = AvailableColors.indigo;
  AvailableColors get currentColor => _currentColor;
  ColorScheme get colorScheme => ColorScheme.fromSeed(seedColor: _currentColor.color);
  ColorScheme get darkColorScheme => ColorScheme.fromSeed(seedColor: _currentColor.color, brightness: Brightness.dark);
  set color(AvailableColors value) {
    _currentColor = value;
    notifyListeners();
  }

  // ————主密码相关————
  // 主密码
  String _masterPwd = "";
  String get masterPwd => _masterPwd;
  set masterPwd(String value) {
    _masterPwd = utils.toSHA256(value);
    notifyListeners();
  }

  // 是否需要更改主密码(为真时，表示需要更改)
  bool _needChangeMaster = false;
  bool get needChangeMaster => _needChangeMaster;

  // ————配置文件相关————
  /// 读取配置文件
  Future<ErrorCode> readConfig() async {
    final (stat, res) = await json_mgr.readJsonFile(Paths.config.toString());

    if (stat == ErrorCode.success && res != null && res is Map) {
      // 读取并还原提醒时间配置
      if (res.containsKey('remindMe') && res['remindMe'] is String) {
        remindMe = RemindDays.values.firstWhere(
          (e) => e.name == res['remindMe'],
          orElse: () => _remindMe, // 如果名称没找到对应的枚举，保持默认值
        );
      }

      // 读取并还原主题颜色配置
      if (res.containsKey('currentColor') && res['currentColor'] is String) {
        color = AvailableColors.values.firstWhere(
          (e) => e.name == res['currentColor'],
          orElse: () => _currentColor, // 如果名称没找到对应的枚举，保持默认值
        );
      }

      // 检查是否要更改主密码
      final lastChange = await masterLastChanged();
      if (lastChange.$1 == ErrorCode.success) {
        // 查看现在的时间是否在 上次更改的时间+提醒天数 之后
        // 如果在之后，则意味着该更改主密码了
        _needChangeMaster = DateTime.now().isAfter(
          lastChange.$2.add(_remindMe.value),
        );
      } else {
        return lastChange.$1;
      }

      return stat;
    } else {
      return stat;
    }
  }

  /// 保存配置文件
  Future<ErrorCode> saveConfig() async {
    final configMap = {
      'remindMe': _remindMe.name,
      'currentColor': _currentColor.name,
    };
    return await json_mgr.writeJsonFile(Paths.config.toString(), configMap);
  }

  Future<(ErrorCode, DateTime)> masterLastChanged() async {
    final res = await core_mgr.readLabelFile(Paths.masterPwdLabel.path);
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
