import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';


/// 格式化 JSON 字符串
///
/// 输出为一个record，第一个是错误码，第二个是结果
(ErrorCode, String) formatJSON(String jsonString) {
  try {
    appLogger.logger.i("Formatting JSON");
    // 使用缩进格式化
    final parsed = jsonDecode(jsonString);
    const encoder = JsonEncoder.withIndent(' ');
    return (ErrorCode.success, encoder.convert(parsed));
  } catch (e) {
    appLogger.logger.e("Can not format JSON: $e");
    return (ErrorCode.jsonFormatError, jsonString);
  }
}

/// 移除特殊字符，使用正则表达式
String removeSpChar(String input) {
  appLogger.logger.i("Removing special characters using regex");
  return input.replaceAll(RegExp(r'[^\w\s]'), '');
}

/// 移除字母，使用正则表达式
String removeAlpha(String input) {
  appLogger.logger.i("Removing alphabets using regex");
  return input.replaceAll(RegExp(r'[a-zA-Z]'), '');
}

/// 移除数字，使用正则表达式
String removeDigits(String input) {
  appLogger.logger.i("Removing digits using regex");
  return input.replaceAll(RegExp(r'[0-9]'), '');
}

/// 获取输入文本的SHA256
String toSHA256(String text) {
  appLogger.logger.i("Getting sha256 for input text");
  var bytes = utf8.encode(text);
  var digest = sha256.convert(bytes);
  return digest.toString();
}