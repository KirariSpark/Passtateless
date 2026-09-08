import 'package:flutter_test/flutter_test.dart';
import 'package:passtateless/modules/generator/interpreter.dart';
import 'package:passtateless/modules/generator/presets.dart' as dsl_presets;

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
}
