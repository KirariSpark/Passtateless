import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passtateless/modules/compability/flatten.dart';
import 'package:passtateless/modules/core/logger.dart';

const MethodChannel _pathProviderChannel = MethodChannel(
  'plugins.flutter.io/path_provider',
);

Future<void> _initLoggerForTest() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_pathProviderChannel, (call) async {
    if (call.method == 'getApplicationSupportDirectory') {
      final dir = await Directory.systemTemp.createTemp('passtateless_test');
      return dir.path;
    }
    return null;
  });
  await appLogger.init();
}

void main() {
  setUpAll(_initLoggerForTest);

  tearDownAll(() {
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pathProviderChannel, null);
  });

  group('flattenPwdMap', () {
    test('把文件夹并入 tags，空文件夹不产生标签', () {
      final oldMap = <String, List<Map<String, dynamic>>>{
        "": [
          {"id": "x", "identifier": "零散", "userName": "u", "account": "a"},
        ],
        "work": [
          {
            "identifier": "i1",
            "userName": "u1",
            "account": "a1",
            "starred": true,
          },
        ],
      };

      final res = flattenPwdMap(oldMap);

      expect(res, hasLength(2));

      final scattered = res[0];
      expect(scattered["id"], "x");
      expect(scattered["tags"], isEmpty);

      final inWork = res[1];
      expect(inWork["identifier"], "i1");
      expect(inWork["tags"], ["work"]);
      expect(inWork["starred"], true);
      expect((inWork["id"] as String).isNotEmpty, true);
    });

    test('合并已有 tags/tag 并去重', () {
      final oldMap = <String, List<Map<String, dynamic>>>{
        "work": [
          {
            "id": "abc",
            "identifier": "i2",
            "userName": "u2",
            "account": "a2",
            "tags": ["work", "extra"],
            "tag": "legacy",
          },
        ],
      };

      final res = flattenPwdMap(oldMap);

      expect(res, hasLength(1));
      expect(res[0]["tags"], ["work", "extra", "legacy"]);
    });

    test('空白文件夹名不产生标签', () {
      final oldMap = <String, List<Map<String, dynamic>>>{
        "   ": [
          {"id": "y", "identifier": "空白", "userName": "u", "account": "a"},
        ],
      };

      final res = flattenPwdMap(oldMap);

      expect(res, hasLength(1));
      expect(res[0]["tags"], isEmpty);
    });

    test('缺少 id 自动补 UUID，字段缺省取默认值', () {
      final oldMap = <String, List<Map<String, dynamic>>>{
        "f": [
          {},
        ],
      };

      final res = flattenPwdMap(oldMap);

      expect(res, hasLength(1));
      expect((res[0]["id"] as String).isNotEmpty, true);
      expect(res[0]["identifier"], "");
      expect(res[0]["userName"], "");
      expect(res[0]["account"], "");
      expect(res[0]["starred"], false);
    });
  });
}
