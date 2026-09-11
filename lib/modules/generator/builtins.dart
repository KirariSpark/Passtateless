import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart' as cryptography;
import 'package:passtateless/modules/core/random.dart';

import 'errors.dart';
import 'values.dart';

/// 内建函数签名：参数名 -> 声明类型
/// （参数声明顺序即文档中的展示顺序，用于默认值补全）
class ParamSpec {
  final DslType type;
  final bool required;

  /// 常量默认值（无则为 null）
  final DslValue? constDefault;

  ParamSpec(this.type, this.required, [this.constDefault]);
}

/// 内建函数元信息 + 实现
abstract class BuiltinFn {
  String get name;

  /// 参数名 -> 声明类型，顺序即声明顺序
  Map<String, ParamSpec> get params;

  /// 由解析后的参数（仅含用户提供的）求出结果
  ///
  /// 实现内部负责补全默认值（含 crop 的 endIndex=len(string) 这类计算默认值）。
  Future<DslValue> execute(Map<String, DslValue> provided) async =>
      _sync(provided);

  /// 同步版本（同步内建重写）
  DslValue _sync(Map<String, DslValue> provided) =>
      throw DslError.runtime('$name 未实现');

  /// 取得参数并提供常量默认值检查
  static DslValue? named(DslValue? v, DslType type, String param) {
    if (v == null) return null;
    _ensureType(v, type, param);
    return v;
  }

  static void _ensureType(DslValue v, DslType type, String param) {
    if (v.runtimeTypeTag != type) {
      throw DslError.type('参数 "$param" 需要 ${type.label} 类型，实际为 ${v.runtimeTypeTag.label}');
    }
  }
}

/// 与 core.dart 中 Generator.specialChars 保持一致的特殊字符表
const List<String> _specialChars = ["!", "@", "#", "=", "%", "^", "&", "*"];

/// 计算某字符串的 sha256 前 7 位 ASCII 码之和，作为 shuffle 的基础种子
int _sha256AsciiSum(String s) {
  final digest = sha256.convert(utf8.encode(s)).toString();
  final prefix = digest.substring(0, 7);
  int sum = 0;
  for (final c in prefix.codeUnits) {
    sum += c;
  }
  return sum;
}

class _LenFn extends BuiltinFn {
  @override
  String get name => 'len';
  @override
  Map<String, ParamSpec> get params => {'string': ParamSpec(DslType.str, true)};
  @override
  DslValue _sync(Map<String, DslValue> provided) {
    final s = (provided['string']! as DslString).value;
    return DslInt(s.length);
  }
}

class _ToBase64Fn extends BuiltinFn {
  @override
  String get name => 'toBase64';
  @override
  Map<String, ParamSpec> get params => {'string': ParamSpec(DslType.str, true)};
  @override
  DslValue _sync(Map<String, DslValue> provided) {
    final s = (provided['string']! as DslString).value;
    return DslString(base64.encode(utf8.encode(s)));
  }
}

class _ToSha256Fn extends BuiltinFn {
  @override
  String get name => 'toSHA256';
  @override
  Map<String, ParamSpec> get params => {'string': ParamSpec(DslType.str, true)};
  @override
  DslValue _sync(Map<String, DslValue> provided) {
    final s = (provided['string']! as DslString).value;
    return DslString(sha256.convert(utf8.encode(s)).toString());
  }
}

class _ToLowerFn extends BuiltinFn {
  @override
  String get name => 'toLower';
  @override
  Map<String, ParamSpec> get params => {'string': ParamSpec(DslType.str, true)};
  @override
  DslValue _sync(Map<String, DslValue> provided) {
    final s = (provided['string']! as DslString).value;
    return DslString(s.toLowerCase());
  }
}

class _ToUpperFn extends BuiltinFn {
  @override
  String get name => 'toUpper';
  @override
  Map<String, ParamSpec> get params => {'string': ParamSpec(DslType.str, true)};
  @override
  DslValue _sync(Map<String, DslValue> provided) {
    final s = (provided['string']! as DslString).value;
    return DslString(s.toUpperCase());
  }
}

class _ToPbkdf2Fn extends BuiltinFn {
  @override
  String get name => 'toPBKDF2';
  @override
  Map<String, ParamSpec> get params => {
        'string': ParamSpec(DslType.str, true),
        'salt': ParamSpec(DslType.str, true),
        'iterations': ParamSpec(DslType.int, false, DslInt(100000)),
      };

  @override
  Future<DslValue> execute(Map<String, DslValue> provided) async {
    final string = (provided['string'] as DslString).value;
    final salt = (provided['salt'] as DslString).value;
    int iterations = 100000;
    final it = provided['iterations'];
    if (it != null) {
      BuiltinFn._ensureType(it, DslType.int, 'iterations');
      iterations = (it as DslInt).value;
    }
    if (iterations < 1) {
      throw DslError.runtime('toPBKDF2 的 iterations 必须为正数');
    }

    final pbkdf2 = cryptography.Pbkdf2(
      macAlgorithm: cryptography.Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    );
    final key = await pbkdf2.deriveKeyFromPassword(
      password: string,
      nonce: utf8.encode(salt),
    );
    final bytes = await key.extractBytes();
    final mapped = bytes.map((b) => (b % 93) + 33).toList();
    return DslString(ascii.decode(mapped, allowInvalid: true));
  }
}

class _ToArgon2idFn extends BuiltinFn {
  @override
  String get name => 'toArgon2id';
  @override
  Map<String, ParamSpec> get params => {
        'string': ParamSpec(DslType.str, true),
        'salt': ParamSpec(DslType.str, true),
        'parallelism': ParamSpec(DslType.int, false, DslInt(1)),
        'memory': ParamSpec(DslType.int, false, DslInt(19000)),
        'iterations': ParamSpec(DslType.int, false, DslInt(2)),
        'hashLength': ParamSpec(DslType.int, false, DslInt(32)),
      };

  @override
  Future<DslValue> execute(Map<String, DslValue> provided) async {
    final string = (provided['string'] as DslString).value;
    final salt = (provided['salt'] as DslString).value;

    int parallelism = 1;
    final p = provided['parallelism'];
    if (p != null) {
      BuiltinFn._ensureType(p, DslType.int, 'parallelism');
      parallelism = (p as DslInt).value;
    }
    int memory = 19000;
    final m = provided['memory'];
    if (m != null) {
      BuiltinFn._ensureType(m, DslType.int, 'memory');
      memory = (m as DslInt).value;
    }
    int iterations = 2;
    final it = provided['iterations'];
    if (it != null) {
      BuiltinFn._ensureType(it, DslType.int, 'iterations');
      iterations = (it as DslInt).value;
    }
    int hashLength = 32;
    final h = provided['hashLength'];
    if (h != null) {
      BuiltinFn._ensureType(h, DslType.int, 'hashLength');
      hashLength = (h as DslInt).value;
    }

    if (parallelism < 1) {
      throw DslError.runtime('toArgon2id 的 parallelism 必须为正数');
    }
    if (memory < 8 * parallelism) {
      throw DslError.runtime('toArgon2id 的 memory 必须不小于 8 × parallelism');
    }
    if (iterations < 1) {
      throw DslError.runtime('toArgon2id 的 iterations 必须为正数');
    }
    if (hashLength < 4) {
      throw DslError.runtime('toArgon2id 的 hashLength 必须不小于 4');
    }

    final argon2id = cryptography.Argon2id(
      parallelism: parallelism,
      memory: memory,
      iterations: iterations,
      hashLength: hashLength,
    );
    final key = await argon2id.deriveKeyFromPassword(
      password: string,
      nonce: utf8.encode(salt),
    );
    final bytes = await key.extractBytes();
    final mapped = bytes.map((b) => (b % 93) + 33).toList();
    return DslString(ascii.decode(mapped, allowInvalid: true));
  }
}

class _ReverseFn extends BuiltinFn {
  @override
  String get name => 'reverse';
  @override
  Map<String, ParamSpec> get params => {'string': ParamSpec(DslType.str, true)};
  @override
  DslValue _sync(Map<String, DslValue> provided) {
    final s = (provided['string']! as DslString).value;
    return DslString(String.fromCharCodes(s.runes.toList().reversed));
  }
}

class _DeduplicateFn extends BuiltinFn {
  @override
  String get name => 'deduplicate';
  @override
  Map<String, ParamSpec> get params => {'string': ParamSpec(DslType.str, true)};
  @override
  DslValue _sync(Map<String, DslValue> provided) {
    final s = (provided['string']! as DslString).value;
    final seen = <String>{};
    final result = <String>[];
    for (final ch in s.split('')) {
      if (seen.add(ch)) result.add(ch);
    }
    return DslString(result.join());
  }
}

class _RotateFn extends BuiltinFn {
  @override
  String get name => 'rotate';
  @override
  Map<String, ParamSpec> get params => {
        'string': ParamSpec(DslType.str, true),
        'rotations': ParamSpec(DslType.int, false, DslInt(1)),
        'direction': ParamSpec(DslType.str, false, DslString('left')),
      };
  @override
  DslValue _sync(Map<String, DslValue> provided) {
    final s = (provided['string']! as DslString).value;
    int rotations = 1;
    final r = provided['rotations'];
    if (r != null) {
      BuiltinFn._ensureType(r, DslType.int, 'rotations');
      rotations = (r as DslInt).value;
    }
    String direction = 'left';
    final d = provided['direction'];
    if (d != null) {
      BuiltinFn._ensureType(d, DslType.str, 'direction');
      direction = (d as DslString).value;
    }
    if (s.isEmpty) return DslString('');
    if (direction != 'left' && direction != 'right') {
      throw DslError.runtime('rotate 的方向只能是 "left" 或 "right"，实际为 "$direction"');
    }
    final eff = rotations % s.length;
    if (eff == 0) return DslString(s);
    final result = direction == 'left'
        ? s.substring(eff) + s.substring(0, eff)
        : s.substring(s.length - eff) + s.substring(0, s.length - eff);
    return DslString(result);
  }
}

class _ExtractFn extends BuiltinFn {
  @override
  String get name => 'extract';
  @override
  Map<String, ParamSpec> get params => {
        'string': ParamSpec(DslType.str, true),
        'stepSize': ParamSpec(DslType.int, false, DslInt(1)),
      };
  @override
  DslValue _sync(Map<String, DslValue> provided) {
    final s = (provided['string']! as DslString).value;
    int step = 1;
    final st = provided['stepSize'];
    if (st != null) {
      BuiltinFn._ensureType(st, DslType.int, 'stepSize');
      step = (st as DslInt).value;
    }
    if (step <= 0) throw DslError.runtime('extract 的 stepSize 必须大于 0');
    final result = <String>[];
    for (int i = 0; i < s.length; i += step) {
      result.add(s[i]);
    }
    return DslString(result.join());
  }
}

class _CropFn extends BuiltinFn {
  @override
  String get name => 'crop';
  @override
  Map<String, ParamSpec> get params => {
        'string': ParamSpec(DslType.str, true),
        'startIndex': ParamSpec(DslType.int, false, DslInt(0)),
        'endIndex': ParamSpec(DslType.int, false), // 计算默认值：len(string)
      };
  @override
  DslValue _sync(Map<String, DslValue> provided) {
    final s = (provided['string']! as DslString).value;
    int start = 0;
    final st = provided['startIndex'];
    if (st != null) {
      BuiltinFn._ensureType(st, DslType.int, 'startIndex');
      start = (st as DslInt).value;
    }
    int end = s.length;
    final e = provided['endIndex'];
    if (e != null) {
      BuiltinFn._ensureType(e, DslType.int, 'endIndex');
      end = (e as DslInt).value;
    }
    if (start > end) return DslString('');
    final s0 = start < 0 ? 0 : start;
    final e0 = end < 0 ? 0 : (end > s.length ? s.length : end);
    if (s0 > e0) return DslString('');
    return DslString(s.substring(s0, e0));
  }
}

class _PadFn extends BuiltinFn {
  @override
  String get name => 'pad';
  @override
  Map<String, ParamSpec> get params => {
        'string': ParamSpec(DslType.str, true),
        'paddingChar': ParamSpec(DslType.str, true),
        'length': ParamSpec(DslType.int, false, DslInt(0)),
        'paddingDirection': ParamSpec(DslType.str, false, DslString('right')),
      };
  @override
  DslValue _sync(Map<String, DslValue> provided) {
    final s = (provided['string']! as DslString).value;
    final char = (provided['paddingChar']! as DslString).value;
    int length = 0;
    final l = provided['length'];
    if (l != null) {
      BuiltinFn._ensureType(l, DslType.int, 'length');
      length = (l as DslInt).value;
    }
    String direction = 'right';
    final d = provided['paddingDirection'];
    if (d != null) {
      BuiltinFn._ensureType(d, DslType.str, 'paddingDirection');
      direction = (d as DslString).value;
    }
    if (length <= 0 || s.length >= length) return DslString(s);
    if (direction == 'right') {
      return DslString(s.padRight(length, char));
    } else if (direction == 'left') {
      return DslString(s.padLeft(length, char));
    }
    throw DslError.runtime('pad 的 paddingDirection 只能是 "left" 或 "right"，实际为 "$direction"');
  }
}

class _InsertFn extends BuiltinFn {
  @override
  String get name => 'insert';
  @override
  Map<String, ParamSpec> get params => {
        'string': ParamSpec(DslType.str, true),
        'index': ParamSpec(DslType.int, false, DslInt(0)),
        'subString': ParamSpec(DslType.str, true),
      };
  @override
  DslValue _sync(Map<String, DslValue> provided) {
    final s = (provided['string']! as DslString).value;
    final sub = (provided['subString']! as DslString).value;
    int index = 0;
    final i = provided['index'];
    if (i != null) {
      BuiltinFn._ensureType(i, DslType.int, 'index');
      index = (i as DslInt).value;
    }
    if (sub.isEmpty) return DslString(s);
    final idx = index < 0 ? 0 : (index > s.length ? s.length : index);
    return DslString(s.substring(0, idx) + sub + s.substring(idx));
  }
}

class _AppendFn extends BuiltinFn {
  @override
  String get name => 'append';
  @override
  Map<String, ParamSpec> get params => {
        'string': ParamSpec(DslType.str, true),
        'subString': ParamSpec(DslType.str, true),
      };
  @override
  DslValue _sync(Map<String, DslValue> provided) {
    final s = (provided['string']! as DslString).value;
    final sub = (provided['subString']! as DslString).value;
    return DslString(s + sub);
  }
}

class _RemoveSpCharFn extends BuiltinFn {
  @override
  String get name => 'removeSpChar';
  @override
  Map<String, ParamSpec> get params => {'string': ParamSpec(DslType.str, true)};
  @override
  DslValue _sync(Map<String, DslValue> provided) {
    final s = (provided['string']! as DslString).value;
    return DslString(s.replaceAll(RegExp(r'[^\w\s]'), ''));
  }
}

class _RemoveAlphaFn extends BuiltinFn {
  @override
  String get name => 'removeAlpha';
  @override
  Map<String, ParamSpec> get params => {'string': ParamSpec(DslType.str, true)};
  @override
  DslValue _sync(Map<String, DslValue> provided) {
    final s = (provided['string']! as DslString).value;
    return DslString(s.replaceAll(RegExp(r'[a-zA-Z]'), ''));
  }
}

class _RemoveDigitFn extends BuiltinFn {
  @override
  String get name => 'removeDigit';
  @override
  Map<String, ParamSpec> get params => {'string': ParamSpec(DslType.str, true)};
  @override
  DslValue _sync(Map<String, DslValue> provided) {
    final s = (provided['string']! as DslString).value;
    return DslString(s.replaceAll(RegExp(r'[0-9]'), ''));
  }
}

class _HasDigitFn extends BuiltinFn {
  @override
  String get name => 'hasDigit';
  @override
  Map<String, ParamSpec> get params => {'string': ParamSpec(DslType.str, true)};
  @override
  DslValue _sync(Map<String, DslValue> provided) {
    final s = (provided['string']! as DslString).value;
    return DslBool(RegExp(r'[0-9]').hasMatch(s));
  }
}

class _HasSpFn extends BuiltinFn {
  @override
  String get name => 'hasSp';
  @override
  Map<String, ParamSpec> get params => {'string': ParamSpec(DslType.str, true)};
  @override
  DslValue _sync(Map<String, DslValue> provided) {
    final s = (provided['string']! as DslString).value;
    return DslBool(s.split('').any(_specialChars.contains));
  }
}

class _HasLowerFn extends BuiltinFn {
  @override
  String get name => 'hasLower';
  @override
  Map<String, ParamSpec> get params => {'string': ParamSpec(DslType.str, true)};
  @override
  DslValue _sync(Map<String, DslValue> provided) {
    final s = (provided['string']! as DslString).value;
    return DslBool(RegExp(r'[a-z]').hasMatch(s));
  }
}

class _HasUpperFn extends BuiltinFn {
  @override
  String get name => 'hasUpper';
  @override
  Map<String, ParamSpec> get params => {'string': ParamSpec(DslType.str, true)};
  @override
  DslValue _sync(Map<String, DslValue> provided) {
    final s = (provided['string']! as DslString).value;
    return DslBool(RegExp(r'[A-Z]').hasMatch(s));
  }
}

class _ShuffleFn extends BuiltinFn {
  @override
  String get name => 'shuffle';
  @override
  Map<String, ParamSpec> get params => {
        'string': ParamSpec(DslType.str, true),
        'seed': ParamSpec(DslType.int, false, DslInt(0)),
      };
  @override
  DslValue _sync(Map<String, DslValue> provided) {
    final s = (provided['string']! as DslString).value;
    int seed = 0;
    final sd = provided['seed'];
    if (sd != null) {
      BuiltinFn._ensureType(sd, DslType.int, 'seed');
      seed = (sd as DslInt).value;
    }
    if (s.length <= 1) return DslString(s);
    final chars = s.split('');
    final random = Xorshift32(_sha256AsciiSum(s) + seed);
    for (int i = chars.length - 1; i > 0; i--) {
      final j = random.nextIntRange(0, i + 1);
      final tmp = chars[i];
      chars[i] = chars[j];
      chars[j] = tmp;
    }
    return DslString(chars.join());
  }
}

class _InsertRandDigitFn extends BuiltinFn {
  @override
  String get name => 'insertRandDigit';
  @override
  Map<String, ParamSpec> get params => {
        'string': ParamSpec(DslType.str, true),
        'amount': ParamSpec(DslType.int, false, DslInt(1)),
        'seed': ParamSpec(DslType.int, false, DslInt(0)),
      };
  @override
  DslValue _sync(Map<String, DslValue> provided) {
    final s = (provided['string']! as DslString).value;
    int amount = 1;
    final a = provided['amount'];
    if (a != null) {
      BuiltinFn._ensureType(a, DslType.int, 'amount');
      amount = (a as DslInt).value;
    }
    int seed = 0;
    final sd = provided['seed'];
    if (sd != null) {
      BuiltinFn._ensureType(sd, DslType.int, 'seed');
      seed = (sd as DslInt).value;
    }
    if (amount <= 0) return DslString(s);
    final baseSeed = s.isEmpty ? 0 : _sha256AsciiSum(s);
    final random = Xorshift32(baseSeed + seed);
    var result = s;
    for (int i = 0; i < amount; i++) {
      if (result.isEmpty) {
        // 与 core.dart 一致：空串时先取随机字符
        result = String.fromCharCode(48 + (random.nextInt() % 10)); // 0-9
      } else {
        // 与 core.dart 一致：先取插入位置，再取随机字符
        final insertIndex = random.nextIntRange(0, result.length + 1);
        final ch = String.fromCharCode(48 + (random.nextInt() % 10)); // 0-9
        result = result.substring(0, insertIndex) + ch + result.substring(insertIndex);
      }
    }
    return DslString(result);
  }
}

class _InsertRandSpFn extends BuiltinFn {
  @override
  String get name => 'insertRandSp';
  @override
  Map<String, ParamSpec> get params => {
        'string': ParamSpec(DslType.str, true),
        'amount': ParamSpec(DslType.int, false, DslInt(1)),
        'seed': ParamSpec(DslType.int, false, DslInt(0)),
      };
  @override
  DslValue _sync(Map<String, DslValue> provided) {
    final s = (provided['string']! as DslString).value;
    int amount = 1;
    final a = provided['amount'];
    if (a != null) {
      BuiltinFn._ensureType(a, DslType.int, 'amount');
      amount = (a as DslInt).value;
    }
    int seed = 0;
    final sd = provided['seed'];
    if (sd != null) {
      BuiltinFn._ensureType(sd, DslType.int, 'seed');
      seed = (sd as DslInt).value;
    }
    if (amount <= 0) return DslString(s);
    final baseSeed = s.isEmpty ? 0 : _sha256AsciiSum(s);
    final random = Xorshift32(baseSeed + seed);
    var result = s;
    for (int i = 0; i < amount; i++) {
      if (result.isEmpty) {
        // 与 core.dart 一致：空串时先取随机字符
        result = _specialChars[random.nextInt() % _specialChars.length];
      } else {
        // 与 core.dart 一致：先取插入位置，再取随机字符
        final insertIndex = random.nextIntRange(0, result.length + 1);
        final ch = _specialChars[random.nextInt() % _specialChars.length];
        result = result.substring(0, insertIndex) + ch + result.substring(insertIndex);
      }
    }
    return DslString(result);
  }
}

class _InsertRandLowerFn extends BuiltinFn {
  @override
  String get name => 'insertRandLower';
  @override
  Map<String, ParamSpec> get params => {
        'string': ParamSpec(DslType.str, true),
        'amount': ParamSpec(DslType.int, false, DslInt(1)),
        'seed': ParamSpec(DslType.int, false, DslInt(0)),
      };
  @override
  DslValue _sync(Map<String, DslValue> provided) {
    final s = (provided['string']! as DslString).value;
    int amount = 1;
    final a = provided['amount'];
    if (a != null) {
      BuiltinFn._ensureType(a, DslType.int, 'amount');
      amount = (a as DslInt).value;
    }
    int seed = 0;
    final sd = provided['seed'];
    if (sd != null) {
      BuiltinFn._ensureType(sd, DslType.int, 'seed');
      seed = (sd as DslInt).value;
    }
    if (amount <= 0) return DslString(s);
    final baseSeed = s.isEmpty ? 0 : _sha256AsciiSum(s);
    final random = Xorshift32(baseSeed + seed);
    var result = s;
    for (int i = 0; i < amount; i++) {
      if (result.isEmpty) {
        // 与 core.dart 一致：空串时先取随机字符
        result = _randLowerChar(random);
      } else {
        // 与 core.dart 一致：先取插入位置，再取随机字符
        final insertIndex = random.nextIntRange(0, result.length + 1);
        final ch = _randLowerChar(random);
        result = result.substring(0, insertIndex) + ch + result.substring(insertIndex);
      }
    }
    return DslString(result);
  }
}

class _InsertRandUpperFn extends BuiltinFn {
  @override
  String get name => 'insertRandUpper';
  @override
  Map<String, ParamSpec> get params => {
        'string': ParamSpec(DslType.str, true),
        'amount': ParamSpec(DslType.int, false, DslInt(1)),
        'seed': ParamSpec(DslType.int, false, DslInt(0)),
      };
  @override
  DslValue _sync(Map<String, DslValue> provided) {
    final s = (provided['string']! as DslString).value;
    int amount = 1;
    final a = provided['amount'];
    if (a != null) {
      BuiltinFn._ensureType(a, DslType.int, 'amount');
      amount = (a as DslInt).value;
    }
    int seed = 0;
    final sd = provided['seed'];
    if (sd != null) {
      BuiltinFn._ensureType(sd, DslType.int, 'seed');
      seed = (sd as DslInt).value;
    }
    if (amount <= 0) return DslString(s);
    final baseSeed = s.isEmpty ? 0 : _sha256AsciiSum(s);
    final random = Xorshift32(baseSeed + seed);
    var result = s;
    for (int i = 0; i < amount; i++) {
      if (result.isEmpty) {
        // 与 core.dart 一致：空串时先取随机字符
        result = _randUpperChar(random);
      } else {
        // 与 core.dart 一致：先取插入位置，再取随机字符
        final insertIndex = random.nextIntRange(0, result.length + 1);
        final ch = _randUpperChar(random);
        result = result.substring(0, insertIndex) + ch + result.substring(insertIndex);
      }
    }
    return DslString(result);
  }
}

/// 生成一个随机小写字母（a-z），RNG 消耗顺序与 core.dart 一致
String _randLowerChar(Xorshift32 random) {
  return String.fromCharCode(97 + (random.nextInt() % 26)); // a-z
}

/// 生成一个随机大写字母（A-Z），RNG 消耗顺序与 core.dart 一致
String _randUpperChar(Xorshift32 random) {
  return String.fromCharCode(65 + (random.nextInt() % 26)); // A-Z
}

/// 全部内建函数的查找表（if 不在此处，是解释器特设语法）
final Map<String, BuiltinFn> builtins = Map.fromEntries([
  _LenFn(),
  _ToBase64Fn(),
  _ToSha256Fn(),
  _ToLowerFn(),
  _ToUpperFn(),
  _ToPbkdf2Fn(),
  _ToArgon2idFn(),
  _ReverseFn(),
  _DeduplicateFn(),
  _RotateFn(),
  _ExtractFn(),
  _CropFn(),
  _PadFn(),
  _InsertFn(),
  _AppendFn(),
  _RemoveSpCharFn(),
  _RemoveAlphaFn(),
  _RemoveDigitFn(),
  _HasDigitFn(),
  _HasSpFn(),
  _HasLowerFn(),
  _HasUpperFn(),
  _ShuffleFn(),
  _InsertRandDigitFn(),
  _InsertRandSpFn(),
  _InsertRandLowerFn(),
  _InsertRandUpperFn(),
].map((f) => MapEntry(f.name, f)));