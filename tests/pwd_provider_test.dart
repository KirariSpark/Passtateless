import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/file_mgr/json_mgr.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/modules/utils/utils.dart' as utils;
import 'package:path/path.dart' as p;

const MethodChannel _pathProviderChannel = MethodChannel(
  'plugins.flutter.io/path_provider',
);

const String _master = "testMaster";
const String _archivePath = "saved_pwds.bin";

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

Future<void> _cleanArchive() async {
  final file = File(p.join(_testDir.path, _archivePath));
  if (await file.exists()) {
    await file.delete();
  }
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

  group('存档往返与旧格式迁移', () {
    test('saveArchive 后 readArchive 能还原内容', () async {
      await _cleanArchive();
      final writer = PwdProvider();
      final id = writer.addEmptyRecord(tags: ["work"]);
      writer.mutateById(
        id,
        (record) {
          record.identifier = "i";
          record.userName = "u";
          record.account = "a";
        },
      );

      expect(await writer.saveArchive(_master), ErrorCode.success);

      final reader = PwdProvider();
      expect(await reader.readArchive(_master), ErrorCode.success);
      expect(reader.pwdList, hasLength(1));
      final restored = reader.pwdList.first;
      expect(restored.id, id);
      expect(restored.identifier, "i");
      expect(restored.userName, "u");
      expect(restored.account, "a");
      expect(restored.tags, ["work"]);
    });

    test('readArchive 在存档不存在时自动创建空档', () async {
      await _cleanArchive();
      final provider = PwdProvider();
      expect(await provider.readArchive(_master), ErrorCode.success);
      expect(provider.pwdList, isEmpty);
      final file = File(p.join(_testDir.path, _archivePath));
      expect(await file.exists(), true);
    });

    test('读取旧版文件夹字典格式会自动展平迁移', () async {
      await _cleanArchive();
      final legacy = <String, dynamic>{
        "": [
          {"id": "u1", "identifier": "零散", "userName": "u", "account": "a"},
        ],
        "work": [
          {
            "identifier": "i",
            "userName": "u2",
            "account": "a2",
            "starred": true,
          },
        ],
      };
      final writeStat = await writeEncryptedJsonFile(
        _archivePath,
        legacy,
        _master,
      );
      expect(writeStat, ErrorCode.success);

      final provider = PwdProvider();
      expect(await provider.readArchive(_master), ErrorCode.success);
      expect(provider.pwdList, hasLength(2));

      final scattered = provider.pwdList.firstWhere((item) => item.isMe("u1"));
      expect(scattered.tags, isEmpty);

      final workItem = provider.pwdList.firstWhere(
        (item) => item.identifier == "i",
      );
      expect(workItem.tags, ["work"]);
      expect(workItem.starred, true);
      expect(workItem.id, isNotEmpty);
    });
  });

  group('导入导出', () {
    test('getPwdJson 导出为扁平列表格式', () {
      final provider = PwdProvider();
      final id = provider.addEmptyRecord(tags: ["work"]);
      provider.mutateById(
        id,
        (record) {
          record.identifier = "i";
          record.userName = "u";
          record.account = "a";
        },
      );
      provider.addEmptyRecord();

      final (stat, json) = provider.getPwdJson(
        "master",
        utils.toSHA256("master"),
      );
      expect(stat, ErrorCode.success);

      final decoded = jsonDecode(json);
      expect(decoded, isA<List>());
      final list = decoded as List;
      expect(list, hasLength(2));
      expect((list[0] as Map)["tags"], ["work"]);
      expect((list[0] as Map).containsKey("folder"), false);
    });

    test('getPwdJson 主密码错误时返回 wrongPwd', () {
      final provider = PwdProvider();
      final (stat, json) = provider.getPwdJson(
        "wrong",
        utils.toSHA256("master"),
      );
      expect(stat, ErrorCode.wrongPwd);
      expect(json, "");
    });

    test('setPwdByJson 全量替换为新版列表', () {
      final provider = PwdProvider();
      provider.addEmptyRecord();
      provider.addEmptyRecord();

      final importText = jsonEncode([
        {
          "identifier": "imported",
          "userName": "u",
          "account": "a",
          "starred": false,
          "tags": ["new"],
        },
      ]);
      expect(provider.setPwdByJson(importText), ErrorCode.success);
      expect(provider.pwdList, hasLength(1));
      final record = provider.pwdList.first;
      expect(record.identifier, "imported");
      expect(record.tags, ["new"]);
      expect(record.id, isNotEmpty);
    });

    test('setPwdByJson 兼容旧版文件夹字典并迁移', () {
      final provider = PwdProvider();
      provider.addEmptyRecord();

      final importText = jsonEncode({
        "work": [
          {"identifier": "legacy", "userName": "u", "account": "a"},
        ],
      });
      expect(provider.setPwdByJson(importText), ErrorCode.success);
      expect(provider.pwdList, hasLength(1));
      expect(provider.pwdList.first.identifier, "legacy");
      expect(provider.pwdList.first.tags, ["work"]);
    });

    test('setPwdByJson 对无效 JSON 返回 jsonFormatError', () {
      final provider = PwdProvider();
      expect(provider.setPwdByJson("not a json"), ErrorCode.jsonFormatError);
      expect(provider.pwdList, isEmpty);
    });
  });
}
