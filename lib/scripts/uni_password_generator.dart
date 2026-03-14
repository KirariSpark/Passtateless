import 'package:flutter/services.dart';
import 'package:passtateless/scripts/v2_parser.dart' as parser;
import 'package:passtateless/scripts/utils.dart' as utils;

/// 统一密码生成器函数
///
/// 如果第一项为0，说明生成成功，第二项返回密码；否则生成失败，返回错误信息
///
/// [input] 用户输入的原始字符串
/// [customRules] 用户自定义的矫正规则映射表
/// [useCorrection] 是否启用输入矫正
/// [removeSpChar] 是否移除特殊字符
/// [removeAlpha] 是否移除字母
/// [removeDigits] 是否移除数字
/// [useV2] 是否使用 V2 算法
/// [v2ConfigJson] V2 算法的 JSON 配置字符串
/// [v2Master] V2 算法的主密码
(int status, String result) uniPasswordGen({
  required String input,
  required Map<String, dynamic> customRules,
  required bool useCorrection,
  required bool removeSpChar,
  required bool removeAlpha,
  required bool removeDigits,
  required String v2ConfigJson,
  required String v2Master
}) {
  // 输入预处理和矫正
  String processedInput = input;

  if (useCorrection) {
    final inputLower = input.toLowerCase();

    // 输入矫正
    // 内置映射
    if (utils.builtinMappings.containsKey(inputLower)) {
      processedInput = utils.builtinMappings[inputLower]!;
    }
    // 自定义规则
    else if (customRules.containsKey(inputLower)) {
      processedInput = customRules[inputLower];
    }
    // 都没有匹配到
    else {
      processedInput = input;
    }
  }

  // 输入不能为空
  if (processedInput.isEmpty) {
    return (1, '输入不能为空');
  }

  String result;
  int genStatus = 0;

  // 生成
  // V2
  final (status, v2Result) = parser.parse(v2ConfigJson, processedInput + v2Master);
  if (status != 0) {
    result = v2Result;
    genStatus = 1;
  } else {
    result = v2Result;
    genStatus = 0;
  }

  // 通用后处理
  if (genStatus == 0) {
    if (removeSpChar) {
      result = utils.removeSpChar(result);
    }
    if (removeAlpha) {
      result = utils.removeAlpha(result);
    }
    if (removeDigits) {
      result = utils.removeDigits(result);
    }
    // 复制到剪贴板
    Clipboard.setData(ClipboardData(text: result));
  }
  return (genStatus, result);
}

String getParserWarnings() {
  return parser.warnings;
}