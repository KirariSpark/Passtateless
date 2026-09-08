import 'errors.dart';

/// DSL 中支持的变量类型
enum DslType {
  str,
  int,
  bool;

  /// 由关键字 token 文本得到类型，非法则返回 null
  static DslType? fromKeyword(String keyword) {
    switch (keyword) {
      case 'str':
        return DslType.str;
      case 'int':
        return DslType.int;
      case 'bool':
        return DslType.bool;
      default:
        return null;
    }
  }

  /// 展示名
  String get label => switch (this) {
        DslType.str => 'str',
        DslType.int => 'int',
        DslType.bool => 'bool',
      };
}

/// 抽象值类型：str/int/bool 以及表示“无值”的 Void
sealed class DslValue {
  /// 运行时类型对应的声明类型
  DslType get runtimeTypeTag;
}

class DslString extends DslValue {
  final String value;
  DslString(this.value);
  @override
  DslType get runtimeTypeTag => DslType.str;
  @override
  bool operator ==(Object other) => other is DslString && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => value;
}

class DslInt extends DslValue {
  final int value;
  DslInt(this.value);
  @override
  DslType get runtimeTypeTag => DslType.int;
  @override
  bool operator ==(Object other) => other is DslInt && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => '$value';
}

class DslBool extends DslValue {
  final bool value;
  DslBool(this.value);
  @override
  DslType get runtimeTypeTag => DslType.bool;
  @override
  bool operator ==(Object other) => other is DslBool && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => '$value';
}

/// pass 求值得到的“无值”
class DslVoid extends DslValue {
  DslVoid();
  @override
  DslType get runtimeTypeTag => throw DslError.type('void 值没有类型');
  @override
  String toString() => 'void';
}

/// 便捷构造辅助
DslValue dslValue(Object? raw) => switch (raw) {
      String s => DslString(s),
      int i => DslInt(i),
      bool b => DslBool(b),
      _ => throw DslError.type('无法转换为 DSL 值：$raw'),
    };

/// 将传入 Map 中的原始输入值转换为 DslValue
///
/// [type] 声明的目标类型；[name] 用于报错时的展示。
DslValue coerceInput(dynamic raw, DslType type, String name) {
  switch (type) {
    case DslType.str:
      if (raw is String) return DslString(raw);
      throw DslError.type('输入变量 "$name" 需要 str 类型，实际为 ${raw.runtimeType}');
    case DslType.int:
      if (raw is int) return DslInt(raw);
      throw DslError.type('输入变量 "$name" 需要 int 类型，实际为 ${raw.runtimeType}');
    case DslType.bool:
      if (raw is bool) return DslBool(raw);
      throw DslError.type('输入变量 "$name" 需要 bool 类型，实际为 ${raw.runtimeType}');
  }
}