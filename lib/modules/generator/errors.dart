/// DSL 错误类型枚举
enum DslErrorKind {
  lexical,
  syntax,
  typeError,
  missingInput,
  userRaise,
  runtime,
}

/// DSL 解释器统一错误类型。
///
/// 词法/语法/类型/输入解析/用户 raise 等错误都能被表示为它，
/// 由 [runDsl] 捕获后放入 [DslResult.error] 返回。
class DslError implements Exception {
  final DslErrorKind kind;
  final String message;

  /// 当 [kind] 为 [DslErrorKind.userRaise] 时，为 raise 中提供的用户消息。
  final String? userMessage;

  final int? line;
  final int? col;

  DslError(this.kind, this.message, {this.userMessage, this.line, this.col});

  /// 是否由用户 raise() 主动抛出
  bool get isUserRaise => kind == DslErrorKind.userRaise;

  /// 便捷构造：词法错误
  factory DslError.lexical(String message, {int? line, int? col}) =>
      DslError(DslErrorKind.lexical, message, line: line, col: col);

  /// 便捷构造：语法错误
  factory DslError.syntax(String message, {int? line, int? col}) =>
      DslError(DslErrorKind.syntax, message, line: line, col: col);

  /// 便捷构造：类型错误
  factory DslError.type(String message, {int? line, int? col}) =>
      DslError(DslErrorKind.typeError, message, line: line, col: col);

  /// 便捷构造：缺失输入
  factory DslError.missingInput(String message, {int? line, int? col}) =>
      DslError(DslErrorKind.missingInput, message, line: line, col: col);

  /// 便捷构造：用户 raise
  factory DslError.raise(String message, {int? line, int? col}) =>
      DslError(DslErrorKind.userRaise, "用户抛出错误：$message",
          userMessage: message, line: line, col: col);

  /// 便捷构造：运行期错误
  factory DslError.runtime(String message, {int? line, int? col}) =>
      DslError(DslErrorKind.runtime, message, line: line, col: col);

  /// 面向展示的完整错误信息
  String get display {
    final loc = (line != null) ? ' (第 $line 行，第 ${col ?? -1} 列)' : '';
    return '$message$loc';
  }

  @override
  String toString() => 'DslError[${kind.name}]: $display';
}