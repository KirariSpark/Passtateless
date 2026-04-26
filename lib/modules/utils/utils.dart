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

/// 从 Map 中恢复枚举配置项
T restoreEnumSetting<T>({
  required Map<dynamic, dynamic> jsonMap,
  required String key,
  required List<T> enumValues,
  required T defaultValue,
  required String settingName,
}) {
  if (jsonMap.containsKey(key) && jsonMap[key] is String) {
    appLogger.logger.i("Restoring $settingName settings");
    final String targetName = jsonMap[key] as String;

    for (final value in enumValues) {
      // 通过枚举的 name 属性进行匹配
      if ((value as Enum).name == targetName) {
        return value;
      }
    }

    // 如果遍历完没找到，记录警告并返回默认值
    appLogger.logger.w("Invalid $settingName setting, falling back to default");
  }
  return defaultValue;
}