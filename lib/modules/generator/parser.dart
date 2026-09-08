import 'errors.dart';
import 'lexer.dart';
import 'values.dart';

// ———————— AST 节点 ————————

/// 整个 DSL 程序
class DslProgram {
  /// GroupInput 中声明的输入变量（已校验 master/seedString 存在）
  final List<InputDef> inputs;

  /// Generate 中的语句
  final List<Stmt> statements;

  DslProgram(this.inputs, this.statements);
}

/// 输入变量声明：`类型 变量名: "显示名" = 默认值`
class InputDef {
  final DslType type;
  final String name;
  final String displayName;
  final DslValue? defaultValue;
  final int line;
  final int col;

  InputDef(this.type, this.name, this.displayName, this.defaultValue, this.line, this.col);
}

/// 语句基类
sealed class Stmt {}

/// 局部变量声明：`类型 变量 = 表达式`
class DeclStmt extends Stmt {
  final DslType type;
  final String name;
  final Expr initializer;
  final int line;
  final int col;
  DeclStmt(this.type, this.name, this.initializer, this.line, this.col);
}

/// 赋值语句：`变量 = 表达式`
class AssignStmt extends Stmt {
  final String name;
  final Expr value;
  final int line;
  final int col;
  AssignStmt(this.name, this.value, this.line, this.col);
}

/// 表达式语句：`表达式 ;`
class ExprStmt extends Stmt {
  final Expr expr;
  final int line;
  final int col;
  ExprStmt(this.expr, this.line, this.col);
}

/// 返回语句：`return 表达式`
class ReturnStmt extends Stmt {
  final Expr value;
  final int line;
  final int col;
  ReturnStmt(this.value, this.line, this.col);
}

/// 抛出错误：`raise(表达式)`
class RaiseStmt extends Stmt {
  final Expr message;
  final int line;
  final int col;
  RaiseStmt(this.message, this.line, this.col);
}

/// 占位：`pass`
class PassStmt extends Stmt {
  final int line;
  final int col;
  PassStmt(this.line, this.col);
}

/// 表达式基类
sealed class Expr {}

/// 字面量
class LiteralExpr extends Expr {
  final DslValue value;
  LiteralExpr(this.value);
}

/// 变量引用
class VarExpr extends Expr {
  final String name;
  VarExpr(this.name);
}

/// 一元取非：`! 表达式`
class UnaryExpr extends Expr {
  final Expr operand;
  UnaryExpr(this.operand);
}

/// 二元运算
class BinaryExpr extends Expr {
  final Expr left;
  final TokenType op; // plus/minus/star/slash/eqEq/.../kwAnd/kwOr
  final Expr right;
  BinaryExpr(this.left, this.op, this.right);
}

/// 括号分组
class GroupExpr extends Expr {
  final Expr inner;
  GroupExpr(this.inner);
}

/// 函数调用（仅关键字参数）
class CallExpr extends Expr {
  final String name;
  final List<CallArg> args;
  final int line;
  final int col;
  CallExpr(this.name, this.args, this.line, this.col);
}

/// 单个关键字参数：`名称 : 参数项`
class CallArg {
  final String name;
  final CallArgBody body;
  CallArg(this.name, this.body);
}

/// 参数项本体：表达式 / pass / raise
sealed class CallArgBody {}

class CallArgExpr extends CallArgBody {
  final Expr expr;
  CallArgExpr(this.expr);
}

class CallArgPass extends CallArgBody {}

class CallArgRaise extends CallArgBody {
  final Expr message;
  CallArgRaise(this.message);
}

// ———————— 语法分析器 ————————

/// DSL 语法分析器（递归下降 + 优先级爬升）
class Parser {
  final List<Token> _tokens;
  int _cur = 0;

  Parser(this._tokens);

  Token get _current => _tokens[_cur];

  bool get _isAtEnd => _current.type == TokenType.eof;

  Token _advance() {
    if (!_isAtEnd) _cur++;
    return _tokens[_cur - 1];
  }

  bool _check(TokenType type) => !_isAtEnd && _current.type == type;

  bool _match(TokenType type) {
    if (_check(type)) {
      _advance();
      return true;
    }
    return false;
  }

  Token _expect(TokenType type, String what) {
    if (_check(type)) return _advance();
    throw DslError.syntax('期望 $what，实际为 "${_current.lexeme}"',
        line: _current.line, col: _current.col);
  }

  DslProgram parse() {
    // GroupInput 块
    _expect(TokenType.kwGroupInput, 'GroupInput');
    _expect(TokenType.leftBrace, '{');
    final inputs = <InputDef>[];
    while (!_check(TokenType.rightBrace) && !_isAtEnd) {
      inputs.add(_parseInputDef());
    }
    _expect(TokenType.rightBrace, '}');
    _validateInputs(inputs);

    // Generate 块
    _expect(TokenType.kwGenerate, 'Generate');
    _expect(TokenType.leftBrace, '{');
    final stmts = <Stmt>[];
    while (!_check(TokenType.rightBrace) && !_isAtEnd) {
      stmts.add(_parseStatement());
    }
    _expect(TokenType.rightBrace, '}');

    if (!_isAtEnd) {
      throw DslError.syntax('出现在程序末尾之后的多余内容："${_current.lexeme}"',
          line: _current.line, col: _current.col);
    }

    final returnCount = stmts.whereType<ReturnStmt>().length;
    if (returnCount != 1) {
      throw DslError.syntax('Generate 中必须有且只有一个 return 语句，当前有 $returnCount 个');
    }

    return DslProgram(inputs, stmts);
  }

  void _validateInputs(List<InputDef> inputs) {
    var masterCount = 0;
    var seedCount = 0;
    final seen = <String>{};
    for (final def in inputs) {
      if (!seen.add(def.name)) {
        throw DslError.syntax('输入变量 "${def.name}" 重复声明', line: def.line, col: def.col);
      }
      if (def.name == 'master') masterCount++;
      if (def.name == 'seedString') seedCount++;
    }
    if (masterCount != 1) {
      throw DslError.syntax('GroupInput 必须声明且只能声明一个 master 变量');
    }
    if (seedCount != 1) {
      throw DslError.syntax('GroupInput 必须声明且只能声明一个 seedString 变量');
    }
  }

  InputDef _parseInputDef() {
    final typeTok = _current;
    final type = _parseTypeKeyword();
    _advance();
    final nameTok = _expect(TokenType.identifier, '输入变量名');
    _expect(TokenType.colon, ':');
    final displayTok = _expect(TokenType.string, '输入变量显示名');
    DslValue? defaultValue;
    if (_match(TokenType.assign)) {
      defaultValue = _parseInputDefault();
    }
    _expect(TokenType.semicolon, ';');
    return InputDef(type, nameTok.lexeme, displayTok.literal as String, defaultValue,
        typeTok.line, typeTok.col);
  }

  DslValue _parseInputDefault() {
    if (_check(TokenType.number)) {
      final tok = _advance();
      return DslInt(tok.literal as int);
    }
    if (_check(TokenType.string)) {
      final tok = _advance();
      return DslString(tok.literal as String);
    }
    if (_check(TokenType.kwTrue)) {
      _advance();
      return DslBool(true);
    }
    if (_check(TokenType.kwFalse)) {
      _advance();
      return DslBool(false);
    }
    throw DslError.syntax('默认值只允许 str/int/bool 字面量',
        line: _current.line, col: _current.col);
  }

  DslType _parseTypeKeyword() {
    switch (_current.type) {
      case TokenType.kwStr:
        return DslType.str;
      case TokenType.kwInt:
        return DslType.int;
      case TokenType.kwBool:
        return DslType.bool;
      default:
        throw DslError.syntax('期望变量类型 str/int/bool，实际为 "${_current.lexeme}"',
            line: _current.line, col: _current.col);
    }
  }

  Stmt _parseStatement() {
    final tok = _current;
    final type = _parseTypeKeywordOrNull();
    if (type != null) {
      _advance();
      final nameTok = _expect(TokenType.identifier, '变量名');
      _expect(TokenType.assign, '=');
      final init = _parseExpression();
      _expect(TokenType.semicolon, ';');
      return DeclStmt(type, nameTok.lexeme, init, tok.line, tok.col);
    }

    switch (_current.type) {
      case TokenType.kwReturn:
        _advance();
        final value = _parseExpression();
        _expect(TokenType.semicolon, ';');
        return ReturnStmt(value, tok.line, tok.col);
      case TokenType.kwRaise:
        _advance();
        _expect(TokenType.leftParen, '(');
        final msg = _parseExpression();
        _expect(TokenType.rightParen, ')');
        _expect(TokenType.semicolon, ';');
        return RaiseStmt(msg, tok.line, tok.col);
      case TokenType.kwPass:
        _advance();
        _expect(TokenType.semicolon, ';');
        return PassStmt(tok.line, tok.col);
      default:
        // 赋值语句（ident = ...）或表达式语句
        if (_check(TokenType.identifier) && _tokens[_cur + 1].type == TokenType.assign) {
          _advance(); // 越过 name
          final nameTok = _tokens[_cur - 1];
          _expect(TokenType.assign, '=');
          final value = _parseExpression();
          _expect(TokenType.semicolon, ';');
          return AssignStmt(nameTok.lexeme, value, tok.line, tok.col);
        }
        final expr = _parseExpression();
        _expect(TokenType.semicolon, ';');
        return ExprStmt(expr, tok.line, tok.col);
    }
  }

  DslType? _parseTypeKeywordOrNull() =>
      DslType.fromKeyword(_current.lexeme) != null ? _parseTypeKeyword() : null;

  // ———————— 表达式（优先级爬升）———————

  Expr _parseExpression() => _parseOr();

  Expr _parseOr() {
    var left = _parseAnd();
    while (_match(TokenType.kwOr)) {
      final op = _tokens[_cur - 1].type;
      final right = _parseAnd();
      left = BinaryExpr(left, op, right);
    }
    return left;
  }

  Expr _parseAnd() {
    var left = _parseEquality();
    while (_match(TokenType.kwAnd)) {
      final op = _tokens[_cur - 1].type;
      final right = _parseEquality();
      left = BinaryExpr(left, op, right);
    }
    return left;
  }

  Expr _parseEquality() {
    var left = _parseRelational();
    while (_check(TokenType.eqEq) || _check(TokenType.bangEq)) {
      final op = _advance().type;
      final right = _parseRelational();
      left = BinaryExpr(left, op, right);
    }
    return left;
  }

  Expr _parseRelational() {
    var left = _parseAdditive();
    while (_check(TokenType.greater) ||
        _check(TokenType.less) ||
        _check(TokenType.greaterEq) ||
        _check(TokenType.lessEq)) {
      final op = _advance().type;
      final right = _parseAdditive();
      left = BinaryExpr(left, op, right);
    }
    return left;
  }

  Expr _parseAdditive() {
    var left = _parseMultiplicative();
    while (_check(TokenType.plus) || _check(TokenType.minus)) {
      final op = _advance().type;
      final right = _parseMultiplicative();
      left = BinaryExpr(left, op, right);
    }
    return left;
  }

  Expr _parseMultiplicative() {
    var left = _parseUnary();
    while (_check(TokenType.star) || _check(TokenType.slash)) {
      final op = _advance().type;
      final right = _parseUnary();
      left = BinaryExpr(left, op, right);
    }
    return left;
  }

  Expr _parseUnary() {
    if (_match(TokenType.bang)) {
      final operand = _parseUnary();
      return UnaryExpr(operand);
    }
    return _parsePrimary();
  }

  Expr _parsePrimary() {
    if (_match(TokenType.number)) {
      return LiteralExpr(DslInt(_tokens[_cur - 1].literal as int));
    }
    if (_match(TokenType.string)) {
      return LiteralExpr(DslString(_tokens[_cur - 1].literal as String));
    }
    if (_match(TokenType.kwTrue)) {
      return LiteralExpr(DslBool(true));
    }
    if (_match(TokenType.kwFalse)) {
      return LiteralExpr(DslBool(false));
    }
    if (_match(TokenType.identifier)) {
      final tok = _tokens[_cur - 1];
      if (_check(TokenType.leftParen)) {
        return _parseCall(tok);
      }
      return VarExpr(tok.lexeme);
    }
    if (_match(TokenType.leftParen)) {
      final inner = _parseExpression();
      _expect(TokenType.rightParen, ')');
      return GroupExpr(inner);
    }
    throw DslError.syntax('期望表达式，实际为 "${_current.lexeme}"',
        line: _current.line, col: _current.col);
  }

  CallExpr _parseCall(Token nameTok) {
    _expect(TokenType.leftParen, '(');
    final args = <CallArg>[];
    while (!_check(TokenType.rightParen)) {
      final paramTok = _expect(TokenType.identifier, '关键字参数名');
      _expect(TokenType.colon, ':');
      final body = _parseCallArgBody();
      args.add(CallArg(paramTok.lexeme, body));
      if (!_match(TokenType.comma)) break;
      if (_check(TokenType.rightParen)) break;
    }
    _expect(TokenType.rightParen, ')');
    return CallExpr(nameTok.lexeme, args, nameTok.line, nameTok.col);
  }

  CallArgBody _parseCallArgBody() {
    if (_check(TokenType.kwPass)) {
      _advance();
      return CallArgPass();
    }
    if (_check(TokenType.kwRaise)) {
      _advance();
      _expect(TokenType.leftParen, '(');
      final msg = _parseExpression();
      _expect(TokenType.rightParen, ')');
      return CallArgRaise(msg);
    }
    return CallArgExpr(_parseExpression());
  }
}