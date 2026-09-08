import 'parser.dart';
import 'lexer.dart';
import 'values.dart';

/// 将 DSL 值（str/int/bool）转回原始 Dart 值；无值返回 null
Object? _toRaw(DslValue? value) {
  if (value is DslString) return value.value;
  if (value is DslInt) return value.value;
  if (value is DslBool) return value.value;
  return null;
}

/// 解析 DSL 源码后得到的一个输入变量描述。
///
/// 仅描述输入（不执行 Generate 块），用于让调用方知道需要收集哪些输入。
class DslInput {
  /// 变量名
  final String name;

  /// 显示名（GroupInput 中声明的 `"显示名"`，用于请求用户输入时代替变量名）
  final String displayName;

  /// 当前取值，初始为源码中的默认值（若无默认值则为 null）。
  /// 解析阶段不要求提供任何取值；UI 可在此填充用户输入后的值。
  dynamic value;

  /// 源码中声明的默认值（原始 Dart 值：String / int / bool；未声明则为 null）
  final dynamic defaultValue;

  DslInput({
    required this.name,
    required this.displayName,
    this.value,
    this.defaultValue,
  });

  @override
  String toString() =>
      'DslInput(name: $name, displayName: $displayName, value: $value, default: $defaultValue)';
}

/// 将 DSL 源码中 `GroupInput` 声明的输入解析成一个 [DslInput] 列表。
///
/// 仅用于"告诉调用方这段 DSL 需要哪些输入"，不执行 Generate 块，
/// **也不要求提供任何输入值**（提供值就是在运行 `runDsl` 时才需要做的事）。
/// 每个输入的 [DslInput.value] 初始为源码中的默认值，供 UI 预填与后续填充。
///
/// [source] 必须是一段含 `GroupInput` 与 `Generate` 的完整 DSL 源码（沿用现有解析器校验）。
/// 解析失败（词法/语法错误）时抛出 [DslError]。
List<DslInput> parseDslInputs(String source) {
  final tokens = Lexer(source).tokenize();
  final program = Parser(tokens).parse();

  return program.inputs.map((InputDef def) {
    final rawDefault = _toRaw(def.defaultValue);
    return DslInput(
      name: def.name,
      displayName: def.displayName,
      value: rawDefault,
      defaultValue: rawDefault,
    );
  }).toList();
}