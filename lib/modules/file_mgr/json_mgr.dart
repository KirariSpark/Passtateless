import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/file_mgr/core_mgr.dart' as core;

/// 使用 SHA-256 哈希处理密钥，自动生成符合 AES256 要求的 32 字节密钥
String _hashKeyForAES256(String key) {
  // 将输入的任意长度 key 转换为 SHA-256 哈希值（64位十六进制字符串）
  final hexHash = sha256.convert(utf8.encode(key)).toString();
  // 截取前 32 个字符。因为全是 0-9/a-f 的 ASCII 字符，
  // 被底层 Key.fromUtf8 解析后长度恰好为 32 字节，完美符合 AES256 标准
  return hexHash.substring(0, 32);
}

/// 读取JSON文件内容
///
/// [relativePath]要读取的文件相对于缓存路径的相对路径
/// 返回 错误码和结果（解析后的 List 或 Map）
Future<(ErrorCode, dynamic res)> readJsonFile(String relativePath) async {
  final (errorCode, textContent) = await core.readTextFile(relativePath);
  if (errorCode != ErrorCode.success) {
    return (errorCode, null);
  }
  try {
    final decoded = jsonDecode(textContent);
    // JSON只能是 List 或者 Map
    if (decoded is List || decoded is Map) {
      return (ErrorCode.success, decoded);
    } else {
      return (ErrorCode.jsonFormatError, null);
    }
  } catch (e) {
    return (ErrorCode.jsonDecError, null);
  }
}

/// 写入JSON文件内容
///
/// [relativePath]要写入的文件相对于缓存路径的相对路径
/// [content]要写入的内容（List 或 Map）
Future<(ErrorCode, String errors)> writeJsonFile(String relativePath, dynamic content) async {
  try {
    if (content is List || content is Map) {
      // 将 List 或 Map 编码为 JSON 字符串
      final jsonString = jsonEncode(content);
      return await core.writeTextFile(relativePath, jsonString);
    } else {
      return (ErrorCode.jsonFormatError, "");
    }
  } catch (e) {
    return (ErrorCode.unknown, e.toString());
  }
}

/// 读取加密JSON文件内容
///
/// [relativePath]要读取的文件相对于缓存路径的相对路径
/// [key]用于解密的密钥（支持任意长度，内部自动哈希为符合要求的32字节）
/// 返回 错误码和结果（解析后的 List 或 Map）
Future<(ErrorCode, dynamic res)> readEncryptedJsonFile(String relativePath, String key) async {
  final hashedKey = _hashKeyForAES256(key);

  // 封装底层 core 的加密文本读取
  final (errorCode, textContent) = await core.readEncryptedTextFile(relativePath, hashedKey);

  if (errorCode != ErrorCode.success) {
    return (errorCode, null);
  }

  try {
    final decoded = jsonDecode(textContent);
    if (decoded is List || decoded is Map) {
      return (ErrorCode.success, decoded);
    } else {
      return (ErrorCode.jsonFormatError, null);
    }
  } catch (e) {
    return (ErrorCode.jsonDecError, null);
  }
}

/// 写入加密JSON文件内容
///
/// [relativePath]要写入的文件相对于缓存路径的相对路径
/// [content]要写入的内容（List 或 Map）
/// [key]用于加密的密钥（支持任意长度，内部自动哈希为符合要求的32字节）
Future<(ErrorCode, String errors)> writeEncryptedJsonFile(String relativePath, dynamic content, String key) async {
  try {
    if (content is List || content is Map) {
      final jsonString = jsonEncode(content);
      final hashedKey = _hashKeyForAES256(key);

      // 封装底层 core 的加密文本写入
      return await core.writeEncryptedTextFile(relativePath, jsonString, hashedKey);
    } else {
      return (ErrorCode.jsonFormatError, "");
    }
  } catch (e) {
    return (ErrorCode.unknown, e.toString());
  }
}
