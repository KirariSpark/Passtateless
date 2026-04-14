import 'dart:io';

import 'package:aes256/aes256.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 读取文本文件内容
///
/// [relativePath]要读取的文件相对于缓存路径的相对路径
Future<(ErrorCode, String res)> readTextFile(String relativePath) async {
  try {
    appLogger.logger.i("Trying to read file $relativePath");
    final baseDir = await getApplicationSupportDirectory();
    final filePath = p.join(baseDir.path, relativePath);
    appLogger.logger.d("File path: $filePath");

    final file = File(filePath);
    if (await file.exists()) {
      var res = await file.readAsString();
      appLogger.logger.i("Successfully read file");
      return (ErrorCode.success, res);
    } else {
      appLogger.logger.e("File not exist");
      return (ErrorCode.fileNotExist, "");
    }
  } catch (e) {
    appLogger.logger.e("Error reading file: ${e.toString()}");
    return (ErrorCode.unknown, "");
  }
}

/// 写入文件内容
///
/// [relativePath]要写入的文件相对于缓存路径的相对路径
/// [content]要写入的内容
Future<ErrorCode> writeTextFile(String relativePath, String content) async {
  try {
    appLogger.logger.i("Trying to write file $relativePath");
    final baseDir = await getApplicationSupportDirectory();
    final filePath = p.join(baseDir.path, relativePath);
    appLogger.logger.d("File path: $filePath");

    final file = File(filePath);
    // 确保目录存在
    final dir = file.parent;
    if (!await dir.exists()) {
      appLogger.logger.i("Dir not exist, trying to create");
      await dir.create(recursive: true);
    }

    await file.writeAsString(content);
    appLogger.logger.i("Successfully written file");
    return (ErrorCode.success);
  } catch (e) {
    appLogger.logger.e("Error writing file: ${e.toString()}");
    return (ErrorCode.unknown);
  }
}

/// 删除文件
///
/// [relativePath]要删除的文件相对于缓存路径的相对路径
Future<ErrorCode> deleteFile(String relativePath) async {
  try {
    appLogger.logger.i("Trying to delete file $relativePath");
    final baseDir = await getApplicationSupportDirectory();
    final filePath = p.join(baseDir.path, relativePath); // 优化：统一使用 p.join
    appLogger.logger.d("File path: $filePath");

    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      appLogger.logger.i("Successfully deleted file");
      return (ErrorCode.success);
    } else {
      appLogger.logger.e("File not exist for deletion");
      return (ErrorCode.fileNotExist);
    }
  } catch (e) {
    appLogger.logger.e("Error deleting file: ${e.toString()}");
    return (ErrorCode.unknown);
  }
}

/// 读取加密文本文件内容
///
/// [relativePath]要读取的文件相对于缓存路径的相对路径
/// [key]用于解密的密钥
Future<(ErrorCode, String res)> readEncryptedTextFile(String relativePath, String key) async {
  try {
    appLogger.logger.i("Trying to read encrypted file $relativePath");
    // 先读取密文
    final (errorCode, content) = await readTextFile(relativePath);
    if (errorCode != ErrorCode.success) {
      return (errorCode, "");
    }
    // 使用AES256解密
    appLogger.logger.d("Decrypting file content...");
    final decrypted = await Aes256.decrypt(encrypted: content, passphrase: key);
    appLogger.logger.i("Successfully read and decrypted file");
    return (ErrorCode.success, decrypted);
  } catch (e) {
    // 解密失败或格式错误
    appLogger.logger.e("Decryption failed or format error: ${e.toString()}");
    return (ErrorCode.decryptionFailed, "");
  }
}

/// 写入加密文件内容
///
/// [relativePath]要写入的文件相对于缓存路径的相对路径
/// [content]要写入的明文内容
Future<ErrorCode> writeEncryptedTextFile(String relativePath, String content, String key) async {
  try {
    appLogger.logger.i("Trying to write encrypted file $relativePath");
    // 使用AES256加密
    appLogger.logger.d("Encrypting file content...");
    final encrypted = await Aes256.encrypt(text: content, passphrase: key);
    // 将加密后的Base64字符串写入文件
    final res = await writeTextFile(relativePath, encrypted);
    if (res == ErrorCode.success) {
      appLogger.logger.i("Successfully encrypted and written file");
    }
    return res;
  } catch (e) {
    appLogger.logger.e("Encryption or write failed: ${e.toString()}");
    return (ErrorCode.unknown);
  }
}

/// 删除加密文件
///
/// [relativePath]要删除的文件相对于缓存路径的相对路径
/// [key]用于解密验证的密钥
Future<ErrorCode> deleteEncryptedTextFile(String relativePath, String key) async {
  appLogger.logger.i("Trying to delete encrypted file $relativePath");
  // 尝试读取并解密文件，验证是否能够成功解密
  final (readErrorCode, _) = await readEncryptedTextFile(relativePath, key);
  if (readErrorCode != ErrorCode.success) {
    // 无法解密或文件不存在，拒绝删除并报错
    appLogger.logger.e("Verification failed before deleting encrypted file");
    return (readErrorCode);
  }
  // 解密成功，执行真正的删除操作
  final res = await deleteFile(relativePath);
  if (res == ErrorCode.success) {
    appLogger.logger.i("Successfully verified and deleted encrypted file");
  }
  return res;
}

/// 创建用于标记时间的空文件
///
/// [relativePath]要创建的文件相对于缓存路径的相对路径
Future<ErrorCode> writeLabelFile(String relativePath) async {
  try {
    appLogger.logger.i("Trying to write label file $relativePath");
    final baseDir = await getApplicationSupportDirectory();
    final filePath = p.join(baseDir.path, relativePath);
    appLogger.logger.d("File path: $filePath");

    final file = File(filePath);
    // 确保目录存在
    final dir = file.parent;
    if (!await dir.exists()) {
      appLogger.logger.i("Dir not exist, trying to create");
      await dir.create(recursive: true);
    }
    // 标记时间
    if (!await file.exists()) {
      await file.writeAsString("");
      appLogger.logger.i("Successfully created label file");
    } else {
      appLogger.logger.d("Label file already exists, skipping creation");
    }
    return ErrorCode.success;
  } catch (e) {
    appLogger.logger.e("Failed to write label file: ${e.toString()}");
    return ErrorCode.unknown;
  }
}

/// 读取用于标记时间的空文件的修改时间
///
/// [relativePath]要读取的文件相对于缓存路径的相对路径
/// [autoCreate] 在标记文件不存在时，自动创建对应文件
Future<(ErrorCode, DateTime?)> readLabelFile(String relativePath, {bool autoCreate = false}) async {
  try {
    appLogger.logger.i("Trying to read label file $relativePath (autoCreate: $autoCreate)");
    final baseDir = await getApplicationSupportDirectory();
    final filePath = p.join(baseDir.path, relativePath);

    final file = File(filePath);
    if (await file.exists()) {
      // 读取文件的最后修改时间作为标记时间
      final res = await file.lastModified();
      appLogger.logger.i("Successfully read label file, last modified: $res");
      return (ErrorCode.success, res);
    } else {
      // 文件不存在时，检查是否允许自动创建
      if (autoCreate) {
        appLogger.logger.d("Label file not exist, auto creating...");
        final stat = await writeLabelFile(relativePath);
        appLogger.logger.i("Auto created label file, returning current time");
        return (stat, DateTime.now());
      } else {
        appLogger.logger.e("Label file not exist and autoCreate is false");
        return (ErrorCode.fileNotExist, null);
      }
    }
  } catch (e) {
    appLogger.logger.e("Failed to read label file: ${e.toString()}");
    return (ErrorCode.unknown, null);
  }
}
