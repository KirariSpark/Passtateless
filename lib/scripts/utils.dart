import 'package:flutter/material.dart';
import 'dart:convert';


/// 解析JSON - 可选是否显示SnackBar
Map<String, String> parseJSON(String jsonString, {BuildContext? context, bool showSnackBar = true}) {
  // 处理空字符串的情况
  if (jsonString.trim().isEmpty) {
    if (context != null && showSnackBar) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("JSON字符串不能为空"),
        showCloseIcon: true,
      ));
    }
    return {};
  }

  try {
    Map<String, dynamic> resolvedMap = json.decode(jsonString);

    // 检查所有值是否都是字符串
    bool allValuesString = resolvedMap.values.every((value) => value is String);

    if (!allValuesString) {
      if (context != null && showSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("所有值必须为字符串"),
          showCloseIcon: true,
        ));
      }
      return {};
    }

    // 转换为 Map<String, String>
    Map<String, String> resolvedStringMap =
        resolvedMap.map((key, value) => MapEntry(key, value as String));

    // 解析成功
    if (context != null && showSnackBar) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("解析成功"),
        showCloseIcon: true,
      ));
    }

    return resolvedStringMap;
  } on FormatException catch (e) {
    // JSON格式错误
    if (context != null && showSnackBar) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("JSON格式错误: ${e.message}"),
        showCloseIcon: true,
      ));
    }
    return {};
  } catch (e) {
    // 其他错误
    if (context != null && showSnackBar) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("解析失败: $e"),
        showCloseIcon: true,
      ));
    }
    return {};
  }
}

/// 格式化 JSON 字符串
///
/// 输出为一个record，分别为(格式化结果，格式化状态(成功0 失败1)，错误信息(成功时为空))
(String json, int status, String error) formatJSON(String jsonString) {
  try {
    // 使用缩进格式化
    final parsed = jsonDecode(jsonString);
    const encoder = JsonEncoder.withIndent('  ');
    return (encoder.convert(parsed), 0, "");
  } catch (e) {
    return (jsonString, 1, e.toString());
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