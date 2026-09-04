import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/core/pwd_item.dart';

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

  group('标签辅助方法', () {
    test('addTag 添加新标签', () {
      final item = PwdItem(id: "a");
      item.addTag("work");
      expect(item.tags, ["work"]);
    });

    test('addTag 忽略空白标签', () {
      final item = PwdItem(id: "a");
      item.addTag("   ");
      item.addTag("");
      expect(item.tags, isEmpty);
    });

    test('addTag 不重复添加已有标签', () {
      final item = PwdItem(id: "a", tags: ["work"]);
      item.addTag("work");
      expect(item.tags, ["work"]);
    });

    test('removeTag 移除存在的标签', () {
      final item = PwdItem(id: "a", tags: ["work", "home"]);
      item.removeTag("work");
      expect(item.tags, ["home"]);
    });

    test('removeTag 对不存在的标签不做任何事', () {
      final item = PwdItem(id: "a", tags: ["work"]);
      item.removeTag("home");
      expect(item.tags, ["work"]);
    });

    test('hasTag 判断是否带有指定标签', () {
      final item = PwdItem(id: "a", tags: ["work"]);
      expect(item.hasTag("work"), true);
      expect(item.hasTag("home"), false);
    });
  });

  group('fromMap 标签整理', () {
    test('剔除空白标签并去重，保留原有顺序', () {
      final item = PwdItem.fromMap({
        "id": "a",
        "tags": ["work", "", "  ", "work", "home"],
      });
      expect(item.tags, ["work", "home"]);
    });

    test('缺失 tags 时默认为空列表', () {
      final item = PwdItem.fromMap({"id": "a"});
      expect(item.tags, isEmpty);
    });

    test('非字符串标签会被忽略', () {
      final item = PwdItem.fromMap({
        "id": "a",
        "tags": ["work", 123, true, null],
      });
      expect(item.tags, ["work"]);
    });

    test('toMap 与 fromMap 往返后内容一致', () {
      final item = PwdItem.fromMap({
        "id": "a",
        "identifier": "i",
        "userName": "u",
        "account": "ac",
        "starred": true,
        "tags": ["work", "home"],
      });
      final restored = PwdItem.fromMap(item.toMap());
      expect(restored.id, item.id);
      expect(restored.identifier, item.identifier);
      expect(restored.userName, item.userName);
      expect(restored.account, item.account);
      expect(restored.starred, item.starred);
      expect(restored.tags, item.tags);
    });
  });
}
