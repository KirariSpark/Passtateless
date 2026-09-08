import 'builtins.dart';
import 'errors.dart';
import 'lexer.dart';
import 'parser.dart';
import 'values.dart';

// ———————— 结果类型 ————————

class DslResult {
  final bool ok;
  final String? value;
  final DslError? error;

  DslResult.ok(this.value)
      : ok = true,
        error = null;

  DslResult.err(this.error)
      : ok = false,
        value = null;
}

// ———————— 环境 ————————

/// 作用域中的一个变量
class _Var {
  final DslType type;
  DslValue value;
  _Var(this.type, this.value);
}

class _Env {
  final Map<String, _Var> _vars = {};

  void define(String name, DslType type, DslValue value) {
    _vars[name] = _Var(type, value);
  }

  bool has(String name) => _vars.containsKey(name);

  DslValue get(String name) {
    final v = _vars[name];
    if (v == null) {
      throw DslError.runtime('变量 "$name" 未定义');
    }
    return v.value;
  }

  DslType typeOf(String name) {
    final v = _vars[name];
    if (v == null) {
      throw DslError.runtime('变量 "$name" 未定义');
    }
    return v.type;
  }

  void assign(String name, DslValue value) {
    final v = _vars[name];
    if (v == null) {
      throw DslError.runtime('变量 "$name" 未声明，无法赋值');
    }
    if (v.type != value.runtimeTypeTag) {
      throw DslError.type(
          '无法将 ${value.runtimeTypeTag.label} 赋值给 ${v.type.label} 类型的变量 "$name"（赋值不能跨类型）');
    }
    v.value = value;
  }
}

// ———————— 解释器 ————————

class _Interpreter {
  final _Env _env;
  final Map<String, BuiltinFn> _builtins;

  _Interpreter(this._env) : _builtins = builtins;

  /// 执行 Generate 块语句，返回 return 的值；未 return 则返回 null
  Future<DslValue?> run(List<Stmt> statements) async {
    for (final stmt in statements) {
      switch (stmt) {
        case DeclStmt():
          final value = await _eval(stmt.initializer);
          _env.define(stmt.name, stmt.type, value);
          break;
        case AssignStmt():
          final value = await _eval(stmt.value);
          _env.assign(stmt.name, value);
          break;
        case ReturnStmt():
          return await _eval(stmt.value);
        case RaiseStmt():
          final msg = await _eval(stmt.message);
          throw _raise(msg);
        case PassStmt():
          break;
        case ExprStmt():
          await _eval(stmt.expr);
          break;
      }
    }
    return null;
  }

  DslError _raise(DslValue msg) {
    if (msg is DslString) {
      return DslError.raise(msg.value);
    }
    throw DslError.type('raise 的参数必须为字符串');
  }

  Future<DslValue> _eval(Expr expr) async {
    switch (expr) {
      case LiteralExpr():
        return expr.value;
      case GroupExpr():
        return await _eval(expr.inner);
      case VarExpr():
        return _env.get(expr.name);
      case UnaryExpr():
        final operand = await _eval(expr.operand);
        if (operand is! DslBool) {
          throw DslError.type('! 只能作用于 bool 值');
        }
        return DslBool(!operand.value);
      case BinaryExpr():
        return await _evalBinary(expr);
      case CallExpr():
        return await _call(expr);
    }
  }

  Future<DslValue> _evalBinary(BinaryExpr expr) async {
    if (expr.op == TokenType.kwAnd ||
        expr.op == TokenType.kwOr ||
        expr.op == TokenType.eqEq ||
        expr.op == TokenType.bangEq ||
        expr.op == TokenType.greater ||
        expr.op == TokenType.less ||
        expr.op == TokenType.greaterEq ||
        expr.op == TokenType.lessEq) {
      final left = await _eval(expr.left);
      final right = await _eval(expr.right);
      return _evalComparison(expr.op, left, right);
    }

    final left = await _eval(expr.left);
    final right = await _eval(expr.right);
    return _evalArithmetic(expr.op, left, right);
  }

  DslValue _evalComparison(TokenType op, DslValue left, DslValue right) {
    switch (op) {
      case TokenType.kwAnd:
        if (left is! DslBool || right is! DslBool) {
          throw DslError.type('AND 只能作用于 bool 值');
        }
        return DslBool(left.value && right.value);
      case TokenType.kwOr:
        if (left is! DslBool || right is! DslBool) {
          throw DslError.type('OR 只能作用于 bool 值');
        }
        return DslBool(left.value || right.value);
      case TokenType.eqEq:
      case TokenType.bangEq:
        final equal = _sameValue(left, right);
        return DslBool(op == TokenType.eqEq ? equal : !equal);
      case TokenType.greater:
      case TokenType.less:
      case TokenType.greaterEq:
      case TokenType.lessEq:
        if (left is! DslInt || right is! DslInt) {
          throw DslError.type('$op 只能作用于 int 值');
        }
        final a = left.value;
        final b = right.value;
        final bool result;
        switch (op) {
          case TokenType.greater:
            result = a > b;
            break;
          case TokenType.less:
            result = a < b;
            break;
          case TokenType.greaterEq:
            result = a >= b;
            break;
          case TokenType.lessEq:
            result = a <= b;
            break;
          default:
            throw DslError.runtime('不支持的比较运算符');
        }
        return DslBool(result);
      default:
        throw DslError.type('不支持的运算符');
    }
  }

  /// 任意同类型值相等判断；不同类型视为不相等
  bool _sameValue(DslValue a, DslValue b) {
    return a.runtimeTypeTag == b.runtimeTypeTag && a == b;
  }

  DslValue _evalArithmetic(TokenType op, DslValue left, DslValue right) {
    switch (op) {
      case TokenType.plus:
        if (left is DslInt && right is DslInt) return DslInt(left.value + right.value);
        if (left is DslString && right is DslString) {
          return DslString(left.value + right.value);
        }
        throw DslError.type('+ 只支持 int + int 或 str + str');
      case TokenType.minus:
        if (left is DslInt && right is DslInt) return DslInt(left.value - right.value);
        if (left is DslString && right is DslString) {
          return DslString(left.value.replaceAll(right.value, ''));
        }
        throw DslError.type('- 只支持 int - int 或 str - str');
      case TokenType.star:
        if (left is DslInt && right is DslInt) return DslInt(left.value * right.value);
        if (left is DslString && right is DslInt) {
          final n = right.value < 0 ? 0 : right.value;
          return DslString(left.value * n);
        }
        throw DslError.type('* 只支持 int * int 或 str * int');
      case TokenType.slash:
        if (left is DslInt && right is DslInt) {
          if (right.value == 0) throw DslError.runtime('除以零错误');
          return DslInt(left.value ~/ right.value);
        }
        throw DslError.type('/ 只支持 int / int');
      default:
        throw DslError.type('不支持的算术运算符');
    }
  }

  Future<DslValue> _call(CallExpr expr) async {
    if (expr.name == 'if') {
      return await _callIf(expr);
    }

    final fn = _builtins[expr.name];
    if (fn == null) {
      throw DslError.runtime('未知函数 "${expr.name}"');
    }

    final provided = <String, DslValue>{};
    for (final arg in expr.args) {
      final DslValue value;
      switch (arg.body) {
        case CallArgExpr(:final expr):
          value = await _eval(expr);
        case CallArgPass() || CallArgRaise():
          throw DslError.type('pass/raise 只能作为 if 的分支使用');
      }
      if (provided.containsKey(arg.name)) {
        throw DslError.type('函数 "${expr.name}" 参数 "${arg.name}" 重复');
      }
      if (!fn.params.containsKey(arg.name)) {
        throw DslError.type('函数 "${expr.name}" 没有参数 "${arg.name}"');
      }
      provided[arg.name] = value;
    }

    for (final entry in fn.params.entries) {
      if (entry.value.required && !provided.containsKey(entry.key)) {
        throw DslError.type('函数 "${expr.name}" 缺少必要参数 "${entry.key}"');
      }
    }

    return await fn.execute(provided);
  }

  Future<DslValue> _callIf(CallExpr expr) async {
    final condArg = _argByName(expr, 'cond');
    if (condArg == null) throw DslError.type('if 缺少参数 "cond"');
    final condBody = condArg.body;
    if (condBody is! CallArgExpr) {
      throw DslError.type('if 的 cond 参数必须为一个布尔表达式');
    }
    final cond = await _eval(condBody.expr);
    if (cond is! DslBool) throw DslError.type('if 的 cond 必须返回 bool');

    final branchName = cond.value ? 'onTrue' : 'onFalse';
    final branch = _argByName(expr, branchName);
    if (branch == null) throw DslError.type('if 缺少参数 "$branchName"');

    switch (branch.body) {
      case CallArgExpr(:final expr):
        return await _eval(expr);
      case CallArgPass():
        return DslVoid();
      case CallArgRaise(:final message):
        final msg = await _eval(message);
        throw _raise(msg);
    }
  }

  CallArg? _argByName(CallExpr expr, String name) {
    for (final arg in expr.args) {
      if (arg.name == name) return arg;
    }
    return null;
  }
}

// ———————— 公开入口 ————————

/// 执行一段 DSL 源码，返回最终密码（字符串）或错误。
///
/// [inputValues] 为 GroupInput 中所有输入变量的一次性取值 map；
/// 其中 `master` 与 `seedString` 由程序提供（不会向用户请求），
/// 其余变量缺省时使用声明中的默认值，两者皆无则报 missingInput 错误。
Future<DslResult> runDsl(String source, Map<String, dynamic> inputValues) async {
  try {
    final tokens = Lexer(source).tokenize();
    final program = Parser(tokens).parse();

    final env = _Env();
    for (final def in program.inputs) {
      final raw = inputValues[def.name];
      DslValue value;
      if (raw != null) {
        value = coerceInput(raw, def.type, def.name);
      } else if (def.defaultValue != null) {
        value = def.defaultValue!;
      } else {
        // master/seedString，或缺少默认值但用户未提供的变量
        throw DslError.missingInput('输入变量 "$def.name" 缺少值且未声明默认值',
            line: def.line, col: def.col);
      }
      env.define(def.name, def.type, value);
    }

    final interpreter = _Interpreter(env);
    final result = await interpreter.run(program.statements);
    if (result is DslString) {
      return DslResult.ok(result.value);
    }
    if (result == null) {
      return DslResult.err(DslError.runtime('Generate 未执行到 return，未产生输出'));
    }
    return DslResult.err(
        DslError.type('return 只能返回字符串，实际返回类型为 ${result.runtimeTypeTag.label}'));
  } on DslError catch (e) {
    return DslResult.err(e);
  }
}