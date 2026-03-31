import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'dart:convert';


/// 格式化 JSON 字符串
///
/// 输出为一个record，第一个是错误码，第二个是结果
(ErrorCode, String) formatJSON(String jsonString) {
  try {
    // 使用缩进格式化
    final parsed = jsonDecode(jsonString);
    const encoder = JsonEncoder.withIndent(' ');
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

/// 检查密码是否包含：数字、大写字母、小写字母、特殊字符，使用ASCII码匹配
///
/// 都包含返回真，否则返回假
bool checkPwd(String pwd) {
  bool hasDigit = false;
  bool hasUpper = false;
  bool hasLower = false;
  bool hasSpecial = false;

  for (int i = 0; i < pwd.length; i++) {
    int code = pwd.codeUnitAt(i);
    // 数字: 0-9 (ASCII 48-57)
    if (code >= 48 && code <= 57) {
      hasDigit = true;
    }
    // 大写字母: A-Z (ASCII 65-90)
    else if (code >= 65 && code <= 90) {
      hasUpper = true;
    }
    // 小写字母: a-z (ASCII 97-122)
    else if (code >= 97 && code <= 122) {
      hasLower = true;
    }
    // 特殊字符: 排除空格和控制字符的可打印符号 (ASCII 33-47, 58-64, 91-96, 123-126)
    else if (
      (code >= 33 && code <= 47) || (code >= 58 && code <= 64) || (code >= 91 && code <= 96) ||
      (code >= 123 && code <= 126)
    ) {
      hasSpecial = true;
    }

    // 如果全部满足，提前结束循环
    if (hasDigit && hasUpper && hasLower && hasSpecial) {
      return true;
    }
  }
  return hasDigit && hasUpper && hasLower && hasSpecial;
}
