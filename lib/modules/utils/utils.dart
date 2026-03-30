import 'package:passtateless/modules/core/error_codes.dart';
import 'dart:convert';


/// 将生成预设的英文键值映射为中文描述
String getPresetText(String? preset) {
  switch (preset) {
    case 'simple':
      return '简单模式';
    case 'complex':
      return '复杂模式';
    case 'bank':
      return '支付密码';
    case 'custom':
      return '自定义模式';
    default:
      return '未知模式';
  }
}

/// 格式化 JSON 字符串
///
/// 输出为一个record，第一个是错误码，第二个是结果
(ErrorCode, String) formatJSON(String jsonString) {
  try {
    // 使用缩进格式化
    final parsed = jsonDecode(jsonString);
    const encoder = JsonEncoder.withIndent('  ');
    return (ErrorCode.success, encoder.convert(parsed));
  } catch (e) {
    return (ErrorCode.jsonFormatError, jsonString);
  }
}

/// 移除特殊字符，使用正则表达式
String removeSpChar(String input) {
  return input.replaceAll(RegExp(r'[^\w\s]'), '');
}

/// 移除字母，使用正则表达式
String removeAlpha(String input) {
  return input.replaceAll(RegExp(r'[a-zA-Z]'), '');
}

/// 移除数字，使用正则表达式
String removeDigits(String input) {
  return input.replaceAll(RegExp(r'[0-9]'), '');
}