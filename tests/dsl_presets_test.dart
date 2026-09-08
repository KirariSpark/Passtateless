import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/generator/dsl/interpreter.dart';
import 'package:passtateless/modules/generator/dsl/presets.dart' as dsl_presets;
import 'package:passtateless/modules/generator/parser.dart' as json_parser;

/// 运行一段 DSL 预设源码并返回成功时的密码
Future<String> _runPreset(String source, String seed) async {
  final r = await runDsl(source, {'master': 'm', 'seedString': seed});
  expect(r.ok, isTrue, reason: 'detail: ${r.error?.toString()}');
  return r.value!;
}

void main() {
  // seedString 即 JSON 方案 composeSeed 的拼接结果
  const seed = 'myIdentifier: myUserName @ myAccount';

  group('DSL 预设属性', () {
    test('simple 可运行、非空且长度不超过 12', () async {
      final pwd = await _runPreset(dsl_presets.simple, seed);
      expect(pwd, isNotEmpty);
      expect(pwd.length, lessThanOrEqualTo(12));
    });

    test('complex 可运行且长度恰为 16', () async {
      final pwd = await _runPreset(dsl_presets.complex, seed);
      expect(pwd.length, 16);
    });

    test('bank 可运行且为 6 位纯数字', () async {
      final pwd = await _runPreset(dsl_presets.bank, seed);
      expect(pwd, matches(RegExp(r'^\d{6}$')));
    });

    test('三个预设均确定性输出', () async {
      for (final src in [dsl_presets.simple, dsl_presets.complex, dsl_presets.bank]) {
        expect(await _runPreset(src, seed), await _runPreset(src, seed));
      }
    });
  });

  group('与 JSON 方案输出逐字符一致', () {
    // 交叉方案需要运行 JSON 方案，其内部使用 appLogger（依赖 path_provider），
    // 因此用 mock channel 初始化 logger 指向临时目录。
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      const channel = MethodChannel('plugins.flutter.io/path_provider');
      TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => Directory.systemTemp.path);
      await appLogger.init();
    });

    for (final (name, preset, dslSource) in [
      ('simple', Presets.simple, dsl_presets.simple),
      ('complex', Presets.complex, dsl_presets.complex),
      ('bank', Presets.bank, dsl_presets.bank),
    ]) {
      test('$name 输出一致', () async {
        final json = await json_parser.parseBuiltins(preset, seed);
        expect(json.$1, ErrorCode.success,
            reason: 'JSON 方案生成失败: ${json.$2}');
        final dsl = await _runPreset(dslSource, seed);
        expect(dsl, json.$2);
      });
    }
  });
}
