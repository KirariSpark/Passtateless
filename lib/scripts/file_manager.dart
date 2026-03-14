import 'package:encrypt/encrypt.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

/// 获取缓存目录路径
Future<Directory> _getCacheDirectory() async {
  if (Platform.isIOS) {
    // iOS使用Library/Application Support目录
    final directory = await getLibraryDirectory();
    return Directory('${directory.path}/Application Support');
  } else if (Platform.isAndroid) {
    // Android使用应用数据目录
    final directory = await getApplicationSupportDirectory();
    return directory;
  } else {
    // 其他平台使用应用支持目录
    final directory = await getApplicationSupportDirectory();
    return directory;
  }
}

/// 读取文件内容
///
/// [relativePath]要读取的文件相对于缓存路径的相对路径
Future<String?> readFile(String relativePath) async {
  try {
    final baseDir = await _getCacheDirectory();
    final filePath = '${baseDir.path}/$relativePath';
    final file = File(filePath);

    if (await file.exists()) {
      return await file.readAsString();
    }
    return null;
  } catch (e) {
    return null;
  }
}

/// 写入文件内容
///
/// [relativePath]要写入的文件相对于缓存路径的相对路径
/// [content]要写入的内容
Future<void> writeFile(String relativePath, String content) async {
  try {
    final baseDir = await _getCacheDirectory();
    final filePath = '${baseDir.path}/$relativePath';
    final file = File(filePath);

    // 确保目录存在
    final dir = file.parent;
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    await file.writeAsString(content);
  } catch (e) {
    rethrow;
  }
}

/// 删除文件
///
/// [relativePath]要删除的文件相对于缓存路径的相对路径
/// 返回值 0 成功，1 不存在， 2 出错
Future<(int stat, String errors)> deleteFile(String relativePath) async {
  try {
    final baseDir = await _getCacheDirectory();
    final filePath = '${baseDir.path}/$relativePath';
    final file = File(filePath);

    if (await file.exists()) {
      await file.delete();
      return (0, "删除成功");
    } else {
      return (1, "目标文件不存在");
    }
  } catch (e) {
    return (2, e.toString());
  }
}

/// 从缓存文件加载自定义规则，对readFile的简单封装
///
/// 返回第一个状态码（1失败0成功），第二个为加载的规则，第三个为错误信息
Future<(int stat, Map<String, dynamic> rules, String errors)> loadCorrections() async {
  try {
    const relativePath = 'password_generator_cache/cached_corrections.json';
    final content = await readFile(relativePath);
    if (content != null) {
      return (0, json.decode(content) as Map<String, dynamic>, "加载成功");
    }
    return (1, {"": ""}, "缓存不存在或为空");
  } catch (e) {
    return (1, {"": ""}, e.toString());
  }
}

/// 保存自定义规则到缓存文件，对writeFile的简单封装
///
/// [correctionsJson] 矫正规则的JSON字符串
///
/// 返回的第一个值为状态码（成功0失败1），第二个为错误信息
Future<(int, String)> saveCorrections(String correctionsJson) async {
  if (correctionsJson.isEmpty) {
    return (1, "输入为空");
  }

  try {
    const relativePath = 'password_generator_cache/cached_corrections.json';
    await writeFile(relativePath, correctionsJson);
    return (0, "保存成功");
  } catch (e) {
    return (1, e.toString());
  }
}

/// 删除缓存文件，对deleteFile的简单封装
///
/// 返回的第一个值为状态码（成功0失败1），第二个为错误信息
Future<(int, String)> deleteCorrections() async {
  try {
    const relativePath = 'password_generator_cache/cached_corrections.json';
    final delStat = await deleteFile(relativePath);
    if (delStat.$1 == 0) {
      return (0, "删除成功");
    } else {
      return (1, delStat.$2);
    }
  } catch (e) {
    return (1, e.toString());
  }
}

/// 加密保存配置
///
/// [password] 密码，如果为空则明文存储
/// [config] 配置内容的JSON字符串
///
/// 返回的第一个值为状态码（成功0失败1），第二个为错误信息
Future<(int, String)> saveConfigEncrypted(String password, String config) async {
  if (config.isEmpty) {
    return (1, "配置内容为空");
  }

  try {
    const jsonPath = 'password_generator_cache/cached_config.json';
    const binPath = 'password_generator_cache/cached_config.bin';

    if (password.isEmpty) {
      // 明文存储
      await deleteFile(binPath);
      await writeFile(jsonPath, config);
    } else {
      // 加密存储
      await deleteFile(jsonPath);

      // 密钥
      final key = Key.fromUtf8(password.padRight(32, '0').substring(0, 32));
      // IV
      final iv = IV.fromLength(16);
      final encrypter = Encrypter(AES(key));

      // 保存
      final encrypted = encrypter.encrypt(config, iv: iv);
      final contentToSave = iv.base64 + encrypted.base64;
      await writeFile(binPath, contentToSave);
    }
    return (0, "保存成功");
  } catch (e) {
    return (1, e.toString());
  }
}

/// 加载配置
///
/// [password] 解密密码，如果文件是明文则不需要
///
/// 返回第一个状态码（1失败0成功），第二个为加载的原始配置字符串，第三个为错误信息
Future<(int, String, String)> loadConfigEncrypted(String password) async {
  try {
    const jsonPath = 'password_generator_cache/cached_config.json';
    const binPath = 'password_generator_cache/cached_config.bin';

    // 尝试读取明文
    final jsonContent = await readFile(jsonPath);
    if (jsonContent != null) {
      return (0, jsonContent, "加载成功");
    }

    // 尝试读取加密
    final binContent = await readFile(binPath);
    if (binContent != null) {
      if (password.isEmpty) {
        return (1, "", "配置已加密，但未提供密码");
      }

      try {
        // 密钥
        final key = Key.fromUtf8(password.padRight(32, '0').substring(0, 32));
        final encrypter = Encrypter(AES(key));

        // 验证数据长度
        if (binContent.length < 24) {
          return (1, "", "加密文件数据损坏");
        }

        final ivStr = binContent.substring(0, 24);
        final encryptedStr = binContent.substring(24);
        final iv = IV.fromBase64(ivStr);
        final encrypted = Encrypted.fromBase64(encryptedStr);

        // 解密
        final decrypted = encrypter.decrypt(encrypted, iv: iv);
        return (0, decrypted, "解密并加载成功");
      } catch (e) {
        return (1, "", "解密失败，密码错误或文件损坏: ${e.toString()}");
      }
    }

    return (1, "", "配置文件不存在");
  } catch (e) {
    return (1, "", e.toString());
  }
}

/// 删除配置文件
///
/// 尝试删除 cached_config.json 和 cached_config.bin
/// 返回的第一个值为状态码（成功0失败1），第二个为错误信息
Future<(int, String)> deleteConfig() async {
  try {
    const jsonPath = 'password_generator_cache/cached_config.json';
    const binPath = 'password_generator_cache/cached_config.bin';

    final resJson = await deleteFile(jsonPath);
    final resBin = await deleteFile(binPath);

    List<String> errors = [];

    if ((resJson.$1 == 1 || resBin.$1 == 1) && (resJson.$1 == 0 || resBin.$1 == 0)) {
      // 只有一个出错，且错误为未找到，视为成功
      errors.add("删除成功");
    } else {
      // 否则视为出错
      errors.add(resJson.$2);
      errors.add(resBin.$2);
      return (1, errors.join("\n"));
    }

    return (0, errors.join("\n"));
  } catch (e) {
    return (1, e.toString());
  }
}
