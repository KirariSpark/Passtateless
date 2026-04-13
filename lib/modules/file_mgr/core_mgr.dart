import 'package:aes256/aes256.dart';
import 'package:path_provider/path_provider.dart';
import 'package:passtateless/modules/core/error_codes.dart';
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
      var res = await file.readAsString();
      return (ErrorCode.success, res);
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
Future<ErrorCode> writeTextFile(String relativePath, String content) async {
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
    return (ErrorCode.success);
  } catch (e) {
    return (ErrorCode.unknown);
  }
}

/// 删除文件
///
/// [relativePath]要删除的文件相对于缓存路径的相对路径
Future<ErrorCode> deleteFile(String relativePath) async {
  try {
    final baseDir = await _getCacheDirectory();
    final filePath = '${baseDir.path}/$relativePath';
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      return (ErrorCode.success);
    } else {
      return (ErrorCode.fileNotExist);
    }
  } catch (e) {
    return (ErrorCode.unknown);
  }
}

/// 读取加密文本文件内容
///
/// [relativePath]要读取的文件相对于缓存路径的相对路径
/// [key]用于解密的密钥
Future<(ErrorCode, String res)> readEncryptedTextFile(String relativePath, String key) async {
  try {
    // 先读取密文
    final (errorCode, content) = await readTextFile(relativePath);
    if (errorCode != ErrorCode.success) {return (errorCode, "");}

    // 使用AES256解密
    final decrypted = await Aes256.decrypt(encrypted: content, passphrase: key);

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
Future<ErrorCode> writeEncryptedTextFile(String relativePath, String content, String key) async {
  try {
    // 使用AES256加密
    final encrypted = await Aes256.encrypt(text: content, passphrase: key);

    // 将加密后的Base64字符串写入文件
    final res = await writeTextFile(relativePath, encrypted);
    return res;
  } catch (e) {
    return (ErrorCode.unknown);
  }
}

/// 删除加密文件
///
/// [relativePath]要删除的文件相对于缓存路径的相对路径
/// [key]用于解密验证的密钥
Future<ErrorCode> deleteEncryptedTextFile(String relativePath, String key) async {
  // 尝试读取并解密文件，验证是否能够成功解密
  final (readErrorCode, _) = await readEncryptedTextFile(relativePath, key);

  if (readErrorCode != ErrorCode.success) {
    // 无法解密或文件不存在，拒绝删除并报错
    return (readErrorCode);
  }

  // 解密成功，执行真正的删除操作
  return await deleteFile(relativePath);
}

/// 创建用于标记时间的空文件
///
/// [relativePath]要创建的文件相对于缓存路径的相对路径
Future<ErrorCode> writeLabelFile(String relativePath) async {
  try {
    final baseDir = await _getCacheDirectory();
    final filePath = '${baseDir.path}/$relativePath';
    final file = File(filePath);

    // 确保目录存在
    final dir = file.parent;
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // 标记时间
    if (!await file.exists()) {
      await file.writeAsString("");
    }

    return ErrorCode.success;
  } catch (e) {
    return ErrorCode.unknown;
  }
}

/// 读取用于标记时间的空文件的修改时间
///
/// [relativePath]要读取的文件相对于缓存路径的相对路径
Future<(ErrorCode, DateTime?)> readLabelFile(String relativePath) async {
  try {
    final baseDir = await _getCacheDirectory();
    final filePath = '${baseDir.path}/$relativePath';
    final file = File(filePath);

    if (await file.exists()) {
      // 读取文件的最后修改时间作为标记时间
      var res = await file.lastModified();
      return (ErrorCode.success, res);
    } else {
      return (ErrorCode.fileNotExist, null);
    }
  } catch (e) {
    return (ErrorCode.unknown, null);
  }
}