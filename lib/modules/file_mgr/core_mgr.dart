import 'package:path_provider/path_provider.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:encrypt/encrypt.dart';
import 'dart:io';

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

/// 读取文本文件内容
///
/// [relativePath]要读取的文件相对于缓存路径的相对路径
Future<(ErrorCode, String res)> readTextFile(String relativePath) async {
  try {
    final baseDir = await _getCacheDirectory();
    final filePath = '${baseDir.path}/$relativePath';
    final file = File(filePath);
    if (await file.exists()) {
      return (ErrorCode.success, await file.readAsString());
    } else {
      return (ErrorCode.fileNotExist, "");
    }
  } catch (e) {
    return (ErrorCode.unknown, "");
  }
}

/// 写入文件内容
///
/// [relativePath]要写入的文件相对于缓存路径的相对路径
/// [content]要写入的内容
Future<(ErrorCode, String errors)> writeTextFile(String relativePath, String content) async {
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
    return (ErrorCode.success, "");
  } catch (e) {
    return (ErrorCode.unknown, e.toString());
  }
}

/// 删除文件
///
/// [relativePath]要删除的文件相对于缓存路径的相对路径
Future<(ErrorCode, String errors)> deleteFile(String relativePath) async {
  try {
    final baseDir = await _getCacheDirectory();
    final filePath = '${baseDir.path}/$relativePath';
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      return (ErrorCode.success, "删除成功");
    } else {
      return (ErrorCode.fileNotExist, "目标文件不存在");
    }
  } catch (e) {
    return (ErrorCode.unknown, e.toString());
  }
}

/// 读取加密文本文件内容
///
/// [relativePath]要读取的文件相对于缓存路径的相对路径
/// [key]用于解密的密钥（需为32位字符以符合AES256标准）
Future<(ErrorCode, String res)> readEncryptedTextFile(String relativePath, String key) async {
  try {
    // 先读取密文
    final (errorCode, content) = await readTextFile(relativePath);
    if (errorCode != ErrorCode.success) {
      return (errorCode, "");
    }

    // 使用AES256解密
    final encrypter = Encrypter(AES(Key.fromUtf8(key), mode: AESMode.cbc));
    final iv = IV.fromLength(16);
    final decrypted = encrypter.decrypt(Encrypted.fromBase64(content), iv: iv);

    return (ErrorCode.success, decrypted);
  } catch (e) {
    // 解密失败或格式错误
    return (ErrorCode.decryptionFailed, "");
  }
}

/// 写入加密文件内容
///
/// [relativePath]要写入的文件相对于缓存路径的相对路径
/// [content]要写入的明文内容
/// [key]用于加密的密钥（需为32位字符以符合AES256标准）
Future<(ErrorCode, String errors)> writeEncryptedTextFile(String relativePath, String content, String key) async {
  try {
    // 使用AES256加密
    final encrypter = Encrypter(AES(Key.fromUtf8(key), mode: AESMode.cbc));
    final iv = IV.fromLength(16);
    final encrypted = encrypter.encrypt(content, iv: iv);

    // 将加密后的Base64字符串写入文件
    return await writeTextFile(relativePath, encrypted.base64);
  } catch (e) {
    return (ErrorCode.unknown, e.toString());
  }
}

/// 删除加密文件
///
/// [relativePath]要删除的文件相对于缓存路径的相对路径
/// [key]用于解密验证的密钥（需为32位字符以符合AES256标准）
Future<(ErrorCode, String errors)> deleteEncryptedTextFile(String relativePath, String key) async {
  // 尝试读取并解密文件，验证是否能够成功解密
  final (readErrorCode, _) = await readEncryptedTextFile(relativePath, key);

  if (readErrorCode != ErrorCode.success) {
    // 无法解密或文件不存在，拒绝删除并报错
    return (readErrorCode, "解密验证失败，拒绝删除文件");
  }

  // 解密成功，执行真正的删除操作
  return await deleteFile(relativePath);
}
