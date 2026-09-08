import 'errors.dart';

/// token 类型（关键字、类型、字面量、运算符、标点）
enum TokenType {
  // 关键字 / 类型 / 字面量
  kwGroupInput,
  kwGenerate,
  kwReturn,
  kwRaise,
  kwPass,
  kwAnd,
  kwOr,
  kwStr,
  kwInt,
  kwBool,
  kwTrue,
  kwFalse,

  // 字面量与标识符
  identifier,
  number,
  string,

  // 运算符
  plus, // +
  minus, // -
  star, // *
  slash, // /
  assign, // =
  eqEq, // ==
  bangEq, // !=
  greater, // >
  less, // <
  greaterEq, // >=
  lessEq, // <=
  bang, // !

  // 标点
  leftParen, // (
  rightParen, // )
  leftBrace, // {
  rightBrace, // }
  comma, // ,
  colon, // :
  semicolon, // ;

  eof,
}

class Token {
  final TokenType type;
  final String lexeme;

  /// 字面量值：number→int，string→解码后的字符串，其余为 null
  final Object? literal;
  final int line;
  final int col;

  const Token(this.type, this.lexeme, this.literal, this.line, this.col);

  @override
  String toString() => '$type($lexeme)';
}

/// 保留字映射
const Map<String, TokenType> _keywords = {
  'GroupInput': TokenType.kwGroupInput,
  'Generate': TokenType.kwGenerate,
  'return': TokenType.kwReturn,
  'raise': TokenType.kwRaise,
  'pass': TokenType.kwPass,
  'AND': TokenType.kwAnd,
  'OR': TokenType.kwOr,
  'str': TokenType.kwStr,
  'int': TokenType.kwInt,
  'bool': TokenType.kwBool,
  'true': TokenType.kwTrue,
  'false': TokenType.kwFalse,
};

/// DSL 词法分析器
class Lexer {
  final String _src;
  int _start = 0;
  int _pos = 0;
  int _line = 1;
  int _col = 1;
  final List<Token> _tokens = [];

  Lexer(this._src);

  List<Token> tokenize() {
    while (!_isAtEnd) {
      _start = _pos;
      _scanToken();
    }
    _tokens.add(Token(TokenType.eof, '', null, _line, _col));
    return _tokens;
  }

  bool get _isAtEnd => _pos >= _src.length;

  void _advance() {
    if (_isAtEnd) return;
    if (_src.codeUnitAt(_pos) == '\n'.codeUnitAt(0)) {
      _line++;
      _col = 1;
    } else {
      _col++;
    }
    _pos++;
  }

  String _peek() => _isAtEnd ? '\u0000' : _src[_pos];

  bool _match(String expected) {
    if (_isAtEnd || _src[_pos] != expected) return false;
    _advance();
    return true;
  }

  void _addToken(TokenType type, [Object? literal]) {
    final text = _src.substring(_start, _pos);
    _tokens.add(Token(type, text, literal, _line, _col));
  }

  void _scanToken() {
    final c = _peek();
    _advance();
    switch (c) {
      case ' ':
      case '\t':
      case '\r':
      case '\n':
        // 空白
        break;
      case '#':
        // 注释：到行尾
        while (!_isAtEnd && _peek() != '\n') {
          _advance();
        }
        break;
      case '+':
        _addToken(TokenType.plus);
        break;
      case '-':
        _addToken(TokenType.minus);
        break;
      case '*':
        _addToken(TokenType.star);
        break;
      case '/':
        _addToken(TokenType.slash);
        break;
      case '!':
        _addToken(_match('=') ? TokenType.bangEq : TokenType.bang);
        break;
      case '=':
        _addToken(_match('=') ? TokenType.eqEq : TokenType.assign);
        break;
      case '<':
        _addToken(_match('=') ? TokenType.lessEq : TokenType.less);
        break;
      case '>':
        _addToken(_match('=') ? TokenType.greaterEq : TokenType.greater);
        break;
      case '(':
        _addToken(TokenType.leftParen);
        break;
      case ')':
        _addToken(TokenType.rightParen);
        break;
      case '{':
        _addToken(TokenType.leftBrace);
        break;
      case '}':
        _addToken(TokenType.rightBrace);
        break;
      case ',':
        _addToken(TokenType.comma);
        break;
      case ':':
        _addToken(TokenType.colon);
        break;
      case ';':
        _addToken(TokenType.semicolon);
        break;
      case '"':
        _string();
        break;
      default:
        if (_isDigit(c)) {
          _number();
        } else if (_isAlpha(c)) {
          _identifier();
        } else {
          throw DslError.lexical('非法字符 "$c"', line: _line, col: _col);
        }
    }
  }

  void _identifier() {
    while (_isAlphaNumeric(_peek())) {
      _advance();
    }
    final text = _src.substring(_start, _pos);
    final type = _keywords[text];
    _addToken(type ?? TokenType.identifier);
  }

  void _number() {
    while (_isDigit(_peek())) {
      _advance();
    }
    final text = _src.substring(_start, _pos);
    _addToken(TokenType.number, int.parse(text));
  }

  void _string() {
    final buf = StringBuffer();
    while (!_isAtEnd && _peek() != '"') {
      final c = _peek();
      if (c == '\\') {
        _advance();
        final esc = _peek();
        _advance();
        switch (esc) {
          case 'n':
            buf.write('\n');
            break;
          case 't':
            buf.write('\t');
            break;
          case '"':
            buf.write('"');
            break;
          case '\\':
            buf.write('\\');
            break;
          default:
            throw DslError.lexical('字符串中非法转义 "\\$esc"', line: _line, col: _col);
        }
      } else {
        buf.write(c);
        _advance();
      }
    }
    if (_isAtEnd) {
      throw DslError.lexical('字符串未闭合', line: _line, col: _col);
    }
    // 吃掉结尾的 "
    _advance();
    _addToken(TokenType.string, buf.toString());
  }

  bool _isDigit(String c) => c.length == 1 && c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;

  bool _isAlpha(String c) {
    final u = c.length == 1 ? c.codeUnitAt(0) : 0;
    return (u >= 65 && u <= 90) || (u >= 97 && u <= 122) || u == 95;
  }

  bool _isAlphaNumeric(String c) => _isAlpha(c) || _isDigit(c);
}