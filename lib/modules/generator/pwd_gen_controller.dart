import 'package:flutter/widgets.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/modules/utils/utils.dart' as utils;
import 'errors.dart';
import 'inputs.dart';
import 'interpreter.dart';
import 'presets.dart' as dsl_presets;
import 'values.dart';

/// 密码生成逻辑控制器：持有预设、自定义 DSL 配置、额外输入等生成所需状态，
/// 并提供刷新、校验、执行生成等纯逻辑能力（不含任何 UI，也不做复制/snackbar）。
///
/// 生命周期由页面 `State` 管理：在 `initState` 中创建，在 `dispose` 中调用 [dispose]。
class PwdGenController {
  /// 语法正确的最小 DSL，作为自定义编辑器的初始内容
  static const String defaultDslSource = '''
GroupInput {
    str master: "主密码";
    str seedString: "种子字符串";
}
Generate {
    return toBase64(string: seedString);
}
''';

  final AppProvider _appProvider;
  final PwdProvider _pwdProvider;

  /// 当前预设
  Presets preset;

  /// 自定义预设的 DSL 源码（仅 [Presets.custom] 时使用）
  String customConfig;

  /// 额外输入（已排除 master/seedString）的声明列表
  List<DslInput> extraInputs = [];

  /// 额外 str/int 输入对应的文本控制器
  final Map<String, TextEditingController> extraControllers = {};

  /// 额外 bool 输入对应的开关状态
  final Map<String, bool> extraSwitchValues = {};

  /// 面板内的输入校验错误文案
  String? inlineInputError;

  /// 是否正在生成（供页面禁用按钮）
  bool isGenerating = false;

  PwdGenController({
    required AppProvider appProvider,
    required PwdProvider pwdProvider,
  })  : _appProvider = appProvider,
        _pwdProvider = pwdProvider,
        preset = Presets.simple,
        customConfig = defaultDslSource {
    refreshExtraInputs();
  }

  /// 根据当前预设得到要执行的 DSL 源码
  String get dslSource => switch (preset) {
        Presets.simple => dsl_presets.simple,
        Presets.complex => dsl_presets.complex,
        Presets.bank => dsl_presets.bank,
        Presets.custom => customConfig,
      };

  void setPreset(Presets value) {
    preset = value;
    refreshExtraInputs();
  }

  void setConfigText(String text) {
    customConfig = text;
    refreshExtraInputs();
  }

  /// 根据当前预设解析 DSL 声明，重建额外输入控件（str/int 用 Controller，bool 用开关）
  void refreshExtraInputs() {
    final String dsl = dslSource;

    List<DslInput> extra;
    try {
      final declared = parseDslInputs(dsl);
      extra = declared
          .where((i) => i.name != 'master' && i.name != 'seedString')
          .toList();
    } on DslError catch (e) {
      appLogger.logger.e("Failed to parse DSL inputs for panel: $e");
      extra = [];
    }

    for (final c in extraControllers.values) {
      c.dispose();
    }
    extraControllers.clear();
    extraSwitchValues.clear();

    for (final i in extra) {
      switch (i.type) {
        case DslType.str:
          extraControllers[i.name] =
              TextEditingController(text: (i.defaultValue as String?) ?? '');
        case DslType.int:
          extraControllers[i.name] =
              TextEditingController(text: i.defaultValue?.toString() ?? '');
        case DslType.bool:
          extraSwitchValues[i.name] = i.defaultValue as bool? ?? false;
      }
    }
    extraInputs = extra;
  }

  /// 从内联控件收集额外输入值；校验失败时返回 null 并设置 [inlineInputError]
  Map<String, dynamic>? collectExtraInputs() {
    final values = <String, dynamic>{};
    for (final i in extraInputs) {
      switch (i.type) {
        case DslType.str:
          final t = extraControllers[i.name]!.text.trim();
          if (t.isEmpty && i.defaultValue == null) {
            inlineInputError = "请填写“${i.displayName}”";
            return null;
          }
          values[i.name] = t;
        case DslType.int:
          final t = extraControllers[i.name]!.text.trim();
          if (t.isEmpty) {
            if (i.defaultValue != null) {
              values[i.name] = i.defaultValue;
            } else {
              inlineInputError = "请填写“${i.displayName}”";
              return null;
            }
          } else {
            final v = int.tryParse(t);
            if (v == null) {
              inlineInputError = "“${i.displayName}”必须是整数";
              return null;
            }
            values[i.name] = v;
          }
        case DslType.bool:
          values[i.name] = extraSwitchValues[i.name]!;
      }
    }
    inlineInputError = null;
    return values;
  }

  /// 执行 DSL 生成，返回结果密码（[ErrorCode.success]）或错误描述。
  ///
  /// - DSL 配置/生成出错：返回 `(ErrorCode.generateFailed, "配置或生成出错\n<详情>")`
  /// - 额外输入校验未通过：返回 `(ErrorCode.unknown, "")`
  /// - 成功：返回 `(ErrorCode.success, <密码>)` 并应用“移除数字/字母/特殊字符”后处理
  Future<(ErrorCode, String)> generate({required String seedString}) async {
    appLogger.logger.i("Generating password");

    // 1) 选 DSL 源码（预设用内置 DSL，自定义用编辑器文本）
    final String dsl = dslSource;

    // 2) 解析 DSL 声明并校验（配置出错时返回错误）
    try {
      parseDslInputs(dsl);
    } on DslError catch (e) {
      appLogger.logger.e("DSL config error: $e");
      return (ErrorCode.generateFailed, "配置或生成出错\n${e.display}");
    }

    // 3) 收集额外输入
    final requested = collectExtraInputs();
    if (requested == null) {
      appLogger.logger.i("Extra input validation failed, aborting generation");
      return (ErrorCode.unknown, "");
    }

    // 4) 组装输入：seedString 对应旧 composeSeed 的拼接结果；
    //    master 传入主密码哈希（明文不可恢复），供 DSL 脚本选用
    final inputValues = <String, dynamic>{
      'master': _appProvider.masterPwd,
      'seedString': seedString,
      ...requested,
    };

    // 5) 交给 DSL 解释器
    final result = await runDsl(dsl, inputValues);
    if (!result.ok) {
      final err = result.error!;
      appLogger.logger.e("DSL generation error: $err");
      return (ErrorCode.generateFailed, "配置或生成出错\n${err.display}");
    }

    // 6) 成功：保留旧的“移除数字/字母/特殊字符”后处理
    var pwd = result.value!;
    if (_pwdProvider.removeDigits) pwd = utils.removeDigits(pwd);
    if (_pwdProvider.removeAlpha) pwd = utils.removeAlpha(pwd);
    if (_pwdProvider.removeSp) pwd = utils.removeSpChar(pwd);

    return (ErrorCode.success, pwd);
  }

  void dispose() {
    for (final c in extraControllers.values) {
      c.dispose();
    }
    extraControllers.clear();
    extraSwitchValues.clear();
  }
}