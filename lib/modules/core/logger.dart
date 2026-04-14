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

class _AppLogger {
  late Logger _logger;
  bool _isInitialized = false;

  Logger get logger => _logger;

  Future<void> init() async {
    if (_isInitialized) {
      return;
    } else {
      final logDir = await getApplicationSupportDirectory();
      final logPath = p.join(logDir.path, Paths.log.path);

      _logger = Logger(
        printer: _MyPrinter(),
        output: FileOutput(file: File(logPath), encoding: utf8, overrideExisting: true),
        level: Level.debug
      );

      _logger.i("Logger initialized");

      _isInitialized = true;
      return;
    }
  }
}

final appLogger = _AppLogger();