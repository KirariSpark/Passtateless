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
///
/// 返回 错误码和结果
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
/// 返回值 0 成功，1 不存在， 2 出错
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