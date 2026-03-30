import 'package:flutter/material.dart';
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