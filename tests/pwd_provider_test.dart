import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';

const MethodChannel _pathProviderChannel = MethodChannel(
  'plugins.flutter.io/path_provider',
);

late Directory _testDir;

Future<void> _initForTest() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  _testDir = await Directory.systemTemp.createTemp('passtateless_provider_test');
  TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_pathProviderChannel, (call) async {
    if (call.method == 'getApplicationSupportDirectory') {
      return _testDir.path;
    }
    return null;
  });
  await appLogger.init();
}

void main() {
  setUpAll(_initForTest);

  tearDownAll(() async {
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pathProviderChannel, null);
    if (_testDir.existsSync()) {
      await _testDir.delete(recursive: true);
    }
  });

  group('记录操作', () {
    test('初始状态为空', () {
      final provider = PwdProvider();
      expect(provider.pwdList, isEmpty);
      expect(provider.starredPwdList, isEmpty);
      expect(provider.getItemById("any"), isNull);
    });

    test('addEmptyRecord 创建带默认值的空记录', () {
      final provider = PwdProvider();
      final id = provider.addEmptyRecord();
      expect(id, isNotEmpty);
      final record = provider.getItemById(id);
      expect(record, isNotNull);
      expect(record!.identifier, "");
      expect(record.userName, "example");
      expect(record.account, "example.com");
      expect(record.tags, isEmpty);
      expect(provider.pwdList, hasLength(1));
    });

    test('addEmptyRecord 支持附带初始标签', () {
      final provider = PwdProvider();
      final id = provider.addEmptyRecord(tags: ["work", "home"]);
      final record = provider.getItemById(id);
      expect(record!.tags, ["work", "home"]);
    });

    test('mutateById 修改字段并通知监听者', () {
      final provider = PwdProvider();
      final id = provider.addEmptyRecord();
      var notified = false;
      provider.addListener(() => notified = true);

      final stat = provider.mutateById(
        id,
        (record) {
          record.identifier = "我的邮箱";
          record.userName = "kirari";
          record.account = "google.com";
        },
      );

      expect(stat, ErrorCode.success);
      expect(notified, true);
      final record = provider.getItemById(id)!;
      expect(record.identifier, "我的邮箱");
      expect(record.userName, "kirari");
      expect(record.account, "google.com");
    });

    test('mutateById 对不存在的 id 返回 noSuchId', () {
      final provider = PwdProvider();
      var notified = false;
      provider.addListener(() => notified = true);
      final stat = provider.mutateById("missing", (record) {});
      expect(stat, ErrorCode.noSuchId);
      expect(notified, false);
    });

    test('removeRecordById 移除记录，重复移除返回 noSuchId', () {
      final provider = PwdProvider();
      final id = provider.addEmptyRecord();
      expect(provider.removeRecordById(id), ErrorCode.success);
      expect(provider.pwdList, isEmpty);
      expect(provider.removeRecordById(id), ErrorCode.noSuchId);
    });

    test('switchStarStateById 切换收藏状态', () {
      final provider = PwdProvider();
      final starred = provider.addEmptyRecord();
      provider.addEmptyRecord();
      provider.switchStarStateById(starred);
      expect(provider.getItemById(starred)!.starred, true);
      expect(provider.starredPwdList, hasLength(1));
      provider.switchStarStateById(starred);
      expect(provider.starredPwdList, isEmpty);
    });
  });
}
