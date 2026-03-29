import 'dart:convert';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/file_mgr/core_mgr.dart' as core;

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
