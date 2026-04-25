import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:passtateless/modules/core/enums.dart';
import "package:logger/logger.dart";

class _MyPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    return ["${event.time.toString()} - ${event.level.name} : ${event.message}"];
  }
}

// 支持动态修改等级的 Filter
class _DynamicLevelFilter extends LogFilter {
  Level _currentLevel;

  _DynamicLevelFilter(this._currentLevel);

  @override
  bool shouldLog(LogEvent event) {
    // 只有当事件的等级大于等于当前设置的等级时才记录
    return event.level.value >= _currentLevel.value;
  }

  void setLevel(Level newLevel) {
    _currentLevel = newLevel;
  }
}

class _AppLogger {
  late Logger _logger;
  late _DynamicLevelFilter _filter; // 持有 Filter 的引用

  Future<void> init() async {
    final logDir = await getApplicationSupportDirectory();
    final logPath = p.join(logDir.path, Paths.log.path);

    _filter = _DynamicLevelFilter(Level.debug);

    _logger = Logger(
      printer: _MyPrinter(),
      output: FileOutput(file: File(logPath), encoding: utf8, overrideExisting: true),
      filter: _filter,
    );

    _logger.i("Logger initialized");
  }

  Logger get logger => _logger;

  // 运行时修改等级
  void setLevel(Level newLevel) {
    _filter.setLevel(newLevel);
    _logger.i("Log level changed to ${newLevel.name}");
  }
}

final appLogger = _AppLogger();
