import 'dart:convert';

import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/generator/parser.dart' as parser;

/// 判断是否为内置预设
bool isBuiltinPreset(Presets preset) {
  return <Presets>[
    Presets.simple,
    Presets.complex,
    Presets.bank,
  ].contains(preset);
}

/// 组合生成密码的种子输入
String composeSeed({
  required String identifier,
  required String userName,
  required String account,
}) {
  return "$identifier: $userName @ $account";
}

/// 按预设生成密码。
///
/// 自定义预设时会解析 [configText] 中的 JSON 配置；
/// 若 JSON 解析失败或解析结果无效，则返回 jsonFormatError，
/// 同时在返回值中携带异常信息以供上层展示。
Future<(ErrorCode, String)> generatePassword({
  required Presets preset,
  required String configText,
  required String identifier,
  required String userName,
  required String account,
  bool removeDigits = false,
  bool removeAlpha = false,
  bool removeSp = false,
}) async {
  final input = composeSeed(
    identifier: identifier,
    userName: userName,
    account: account,
  );

  if (isBuiltinPreset(preset)) {
    appLogger.logger.i("Generating using builtin presets");
    return await parser.parseBuiltins(
      preset,
      input,
      removeAlpha: removeAlpha,
      removeDigits: removeDigits,
      removeSp: removeSp,
    );
  }

  try {
    appLogger.logger.i("Generating using custom config");
    return await parser.parse(
      jsonDecode(configText),
      input,
      removeAlpha: removeAlpha,
      removeDigits: removeDigits,
      removeSp: removeSp,
    );
  } catch (e) {
    appLogger.logger.e("Can not generate password: $e");
    return (ErrorCode.jsonFormatError, e.toString());
  }
}
