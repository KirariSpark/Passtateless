import 'dart:convert';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart'; // 引入日志模块
import 'package:passtateless/modules/file_mgr/core_mgr.dart' as core_mgr;

/// 读取JSON文件内容
///
/// [relativePath]要读取的文件相对于缓存路径的相对路径
/// 返回 错误码和结果（解析后的 List 或 Map）
Future<(ErrorCode, dynamic res)> readJsonFile(String relativePath) async {
  appLogger.logger.i("Trying to read JSON file $relativePath");

  final (errorCode, textContent) = await core_mgr.readTextFile(relativePath);
  if (errorCode != ErrorCode.success) {
    // 底层 core_mgr 已打印具体 I/O 错误，这里补充上下文说明
    appLogger.logger.w("Failed to read base text file for JSON parsing");
    return (errorCode, null);
  }

  try {
    final decoded = jsonDecode(textContent);
    // JSON只能是 List 或者 Map
    if (decoded is List || decoded is Map) {
      appLogger.logger.i("Successfully read and parsed JSON file");
      return (ErrorCode.success, decoded);
    } else {
      appLogger.logger.e("JSON format error: Root element is not a List or Map");
      return (ErrorCode.jsonFormatError, null);
    }
  } catch (e) {
    appLogger.logger.e("JSON decode error: ${e.toString()}");
    return (ErrorCode.jsonDecError, null);
  }
}

/// 写入JSON文件内容
///
/// [relativePath]要写入的文件相对于缓存路径的相对路径
/// [content]要写入的内容（List 或 Map）
Future<ErrorCode> writeJsonFile(String relativePath, dynamic content) async {
  appLogger.logger.i("Trying to write JSON file $relativePath");

  try {
    if (content is List || content is Map) {
      // 将 List 或 Map 编码为 JSON 字符串
      appLogger.logger.d("Encoding content to JSON string...");
      final jsonString = jsonEncode(content);
      final res = await core_mgr.writeTextFile(relativePath, jsonString);
      if (res == ErrorCode.success) {
        appLogger.logger.i("Successfully written JSON file");
      }
      return res;
    } else {
      appLogger.logger.e("JSON format error: Content to write is not a List or Map");
      return (ErrorCode.jsonFormatError);
    }
  } catch (e) {
    appLogger.logger.e("Error encoding/writing JSON: ${e.toString()}");
    return (ErrorCode.unknown);
  }
}

/// 读取加密JSON文件内容
///
/// [relativePath]要读取的文件相对于缓存路径的相对路径
/// [key]用于解密的密钥（支持任意长度，内部自动哈希为符合要求的32字节）
/// 返回 错误码和结果（解析后的 List 或 Map）
Future<(ErrorCode, dynamic res)> readEncryptedJsonFile(String relativePath, String key) async {
  appLogger.logger.i("Trying to read encrypted JSON file $relativePath");

  // 封装底层 core 的加密文本读取
  final (errorCode, textContent) = await core_mgr.readEncryptedTextFile(relativePath, key);
  if (errorCode != ErrorCode.success) {
    appLogger.logger.w("Failed to read/decrypt base text file for JSON parsing");
    return (errorCode, null);
  }

  try {
    final decoded = jsonDecode(textContent);
    if (decoded is List || decoded is Map) {
      appLogger.logger.i("Successfully read and parsed encrypted JSON file");
      return (ErrorCode.success, decoded);
    } else {
      appLogger.logger.e("JSON format error: Root element is not a List or Map");
      return (ErrorCode.jsonFormatError, null);
    }
  } catch (e) {
    appLogger.logger.e("JSON decode error: ${e.toString()}");
    return (ErrorCode.jsonDecError, null);
  }
}

/// 写入加密JSON文件内容
///
/// [relativePath]要写入的文件相对于缓存路径的相对路径
/// [content]要写入的内容（List 或 Map）
/// [key]用于加密的密钥（支持任意长度，内部自动哈希为符合要求的32字节）
Future<ErrorCode> writeEncryptedJsonFile(String relativePath, dynamic content, String key) async {
  appLogger.logger.i("Trying to write encrypted JSON file $relativePath");

  try {
    if (content is List || content is Map) {
      appLogger.logger.d("Encoding content to JSON string...");
      final jsonString = jsonEncode(content);
      // 封装底层 core 的加密文本写入
      final res = await core_mgr.writeEncryptedTextFile(relativePath, jsonString, key);
      if (res == ErrorCode.success) {
        appLogger.logger.i("Successfully written encrypted JSON file");
      }
      return res;
    } else {
      appLogger.logger.e("JSON format error: Content to write is not a List or Map");
      return (ErrorCode.jsonFormatError);
    }
  } catch (e) {
    appLogger.logger.e("Error encoding/writing encrypted JSON: ${e.toString()}");
    return (ErrorCode.unknown);
  }
}
