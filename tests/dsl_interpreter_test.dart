import 'package:flutter_test/flutter_test.dart';
import 'package:passtateless/modules/generator/errors.dart';
import 'package:passtateless/modules/generator/inputs.dart';
import 'package:passtateless/modules/generator/interpreter.dart';

/// 组装一个 DSL 源码，默认带上 master/seedString 两个必填输入
Future<DslResult> runp(
  String body, {
  String extraInputs = '',
  Map<String, dynamic> inputs = const {},
}) async {
  final source = '''
GroupInput {
    str master: "主密码";
    str seedString: "种子字符串";
    $extraInputs
}
Generate {
    $body
}
''';
  final all = <String, dynamic>{'master': 'm', 'seedString': 's'};
  all.addAll(inputs);
  return runDsl(source, all);
}

void main() {
  group('词法 / 语法错误', () {
    test('未闭合字符串', () async {
      final r = await runp('return "abc;');
      expect(r.ok, isFalse);
      expect(r.error!.kind, DslErrorKind.lexical);
    });

    test('非法字符', () async {
      final r = await runp('return "a"; @');
      expect(r.ok, isFalse);
      expect(r.error!.kind, DslErrorKind.lexical);
    });

    test('缺少 master 输入', () async {
      final src = '''
GroupInput {
    str seedString: "种子字符串";
}
Generate { return "x"; }
''';
      final r = await runDsl(src, {'master': 'm'});
      expect(r.ok, isFalse);
      expect(r.error!.kind, DslErrorKind.syntax);
    });

    test('缺少 return -> runtime 错误', () async {
      final r = await runp('pass;');
      expect(r.ok, isFalse);
      expect(r.error!.kind, DslErrorKind.runtime);
    });

    test('多余 return：首个 return 生效', () async {
      final r = await runp('return "a"; return "b";');
      expect(r.ok, isTrue);
      expect(r.value, 'a');
    });

    test('语句缺少分号', () async {
      final r = await runp('str x = "a"');
      expect(r.ok, isFalse);
      expect(r.error!.kind, DslErrorKind.syntax);
    });
  });

  group('GroupInput 解析', () {
    test('str 变量使用默认值', () async {
      final r = await runp('return master + suffix;', extraInputs: 'str suffix: "S" = "!";');
      expect(r.ok, isTrue);
      expect(r.value, 'm!');
    });

    test('int 变量默认值可参与比较', () async {
      final r = await runp(
        'return if(cond: count > 3, onTrue: "big", onFalse: "small");',
        extraInputs: 'int count: "C" = 5;',
      );
      expect(r.ok, isTrue);
      expect(r.value, 'big');
    });

    test('提供值覆盖默认值', () async {
      final r = await runp(
        'return master + suffix;',
        extraInputs: 'str suffix: "S" = "!";',
        inputs: {'suffix': '@'},
      );
      expect(r.value, 'm@');
    });

    test('缺少默认值且未提供 -> missingInput', () async {
      final r = await runp('return "x";', extraInputs: 'int count: "数量";');
      expect(r.ok, isFalse);
      expect(r.error!.kind, DslErrorKind.missingInput);
    });

    test('提供值与声明类型不符 -> typeError', () async {
      final r = await runp(
        'return "x";',
        extraInputs: 'int count: "数量" = 0;',
        inputs: {'count': 'not-int'},
      );
      expect(r.ok, isFalse);
      expect(r.error!.kind, DslErrorKind.typeError);
    });
  });

  group('算术', () {
    test('str + str 拼接', () async {
      expect((await runp('return "ab" + "cd";')).value, 'abcd');
    });

    test('int + int', () async {
      final r = await runp('return if(cond: 1 + 2 == 3, onTrue: "ok", onFalse: "no");');
      expect(r.value, 'ok');
    });

    test('int - int', () async {
      final r = await runp('return if(cond: 9 - 3 == 6, onTrue: "ok", onFalse: "no");');
      expect(r.value, 'ok');
    });

    test('str - str 移除所有子串', () async {
      expect((await runp('return "aXbXc" - "X";')).value, 'abc');
    });

    test('str * int 重复', () async {
      expect((await runp('return "ab" * 3;')).value, 'ababab');
    });

    test('int * int', () async {
      final r = await runp('return if(cond: 6 * 7 == 42, onTrue: "ok", onFalse: "no");');
      expect(r.value, 'ok');
    });

    test('int / int 整数除法', () async {
      final r = await runp('return if(cond: 7 / 2 == 3, onTrue: "ok", onFalse: "no");');
      expect(r.value, 'ok');
    });

    test('除以零 -> runtime', () async {
      final r = await runp('return if(cond: 0 >= 1, onTrue: "x", onFalse: (1 / 0 == 1));');
      expect(r.ok, isFalse);
      expect(r.error!.kind, DslErrorKind.runtime);
    });

    test('int + str -> typeError', () async {
      final r = await runp('str a = (1 + "a"); return a;');
      expect(r.ok, isFalse);
      expect(r.error!.kind, DslErrorKind.typeError);
    });
  });

  group('比较与逻辑', () {
    test('大于/小于/大于等于/小于等于', () async {
      expect((await runp('return if(cond: 3 > 2, onTrue: "1", onFalse: "0");')).value, '1');
      expect((await runp('return if(cond: 3 < 2, onTrue: "1", onFalse: "0");')).value, '0');
      expect((await runp('return if(cond: 2 >= 2, onTrue: "1", onFalse: "0");')).value, '1');
      expect((await runp('return if(cond: 2 <= 1, onTrue: "1", onFalse: "0");')).value, '0');
    });

    test('相等 / 不等', () async {
      expect((await runp('return if(cond: "a" == "a", onTrue: "T", onFalse: "F");')).value, 'T');
      expect((await runp('return if(cond: "a" != "b", onTrue: "T", onFalse: "F");')).value, 'T');
    });

    test('不同类型相等视为不等', () async {
      expect((await runp('return if(cond: "a" == 1, onTrue: "T", onFalse: "F");')).value, 'F');
    });

    test('AND / OR / !', () async {
      expect((await runp('return if(cond: true AND true, onTrue: "1", onFalse: "0");')).value, '1');
      expect((await runp('return if(cond: false OR true, onTrue: "1", onFalse: "0");')).value, '1');
      expect((await runp('return if(cond: !false, onTrue: "1", onFalse: "0");')).value, '1');
    });
  });

  group('赋值', () {
    test('声明后重赋', () async {
      expect((await runp('str a = "x"; a = "y"; return a;')).value, 'y');
    });

    test('跨类型赋值 -> typeError', () async {
      final r = await runp('str a = "x"; bool b = true; a = b; return a;');
      expect(r.ok, isFalse);
      expect(r.error!.kind, DslErrorKind.typeError);
    });

    test('给未声明变量赋值 -> runtime', () async {
      final r = await runp('x = "y"; return "z";');
      expect(r.ok, isFalse);
      expect(r.error!.kind, DslErrorKind.runtime);
    });
  });

  group('if 懒求值', () {
    test('命中 onTrue，onFalse 的 raise 不执行', () async {
      final r = await runp('return if(cond: true, onTrue: "ok", onFalse: raise("boom"));');
      expect(r.ok, isTrue);
      expect(r.value, 'ok');
    });

    test('命中 onFalse，onTrue 的 raise 不执行', () async {
      final r = await runp('return if(cond: false, onTrue: raise("boom"), onFalse: "ok");');
      expect(r.ok, isTrue);
      expect(r.value, 'ok');
    });

    test('if 分支直接 return 终止 Generate（onTrue 命中）', () async {
      final r = await runp('if(cond: true, onTrue: return "yes", onFalse: return "no");');
      expect(r.ok, isTrue);
      expect(r.value, 'yes');
    });

    test('if 分支直接 return 终止 Generate（onFalse 命中）', () async {
      final r = await runp('if(cond: false, onTrue: return "yes", onFalse: return "no");');
      expect(r.ok, isTrue);
      expect(r.value, 'no');
    });

    test('if 分支 return 与 raise 懒求值', () async {
      final r = await runp('if(cond: true, onTrue: return "ok", onFalse: raise("boom"));');
      expect(r.ok, isTrue);
      expect(r.value, 'ok');
    });

    test('return if(...) 内嵌分支 return', () async {
      final r = await runp('return if(cond: true, onTrue: return "a", onFalse: return "b");');
      expect(r.ok, isTrue);
      expect(r.value, 'a');
    });

    test('if 分支 return 后语句不执行', () async {
      final r = await runp('if(cond: true, onTrue: return "a", onFalse: pass); raise("boom");');
      expect(r.ok, isTrue);
      expect(r.value, 'a');
    });

    test('普通函数参数传 return -> typeError', () async {
      final r = await runp('return toBase64(string: return "x");');
      expect(r.ok, isFalse);
      expect(r.error!.kind, DslErrorKind.typeError);
    });
  });

  group('return 截断', () {
    test('return 之后的语句被忽略（如 raise）', () async {
      final r = await runp('return "ok"; raise("boom");');
      expect(r.ok, isTrue);
      expect(r.value, 'ok');
    });
  });

  group('raise', () {
    test('raise 抛出用户错误并携带消息', () async {
      final r = await runp(
        'if(cond: true, onTrue: raise("迭代次数过大"), onFalse: pass);\nreturn "x";',
      );
      expect(r.ok, isFalse, reason: 'detail: ${r.error?.toString()}');
      expect(r.error!.isUserRaise, isTrue, reason: 'detail: ${r.error?.toString()}');
      expect(r.error!.message, contains('迭代次数过大'));
    });
  });

  group('内建函数', () {
    test('len', () async {
      final r = await runp('return if(cond: len(string: "abcde") == 5, onTrue: "5", onFalse: "x");');
      expect(r.value, '5', reason: 'detail: ${r.error?.toString()}');
    });

    test('toBase64', () async {
      expect((await runp('return toBase64(string: "abc");')).value, 'YWJj');
    });

    test('toSHA256', () async {
      expect(
          (await runp('return toSHA256(string: "abc");')).value,
          'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad');
    });

    test('reverse', () async {
      expect((await runp('return reverse(string: "abc");')).value, 'cba');
    });

    test('deduplicate', () async {
      expect((await runp('return deduplicate(string: "aabbc");')).value, 'abc');
    });

    test('rotate', () async {
      expect(
          (await runp('return rotate(string: "abcd", rotations: 1, direction: "left");')).value,
          'bcda');
      expect(
          (await runp('return rotate(string: "abcd", rotations: 1, direction: "right");')).value,
          'dabc');
    });

    test('extract', () async {
      expect((await runp('return extract(string: "abcde", stepSize: 2);')).value, 'ace');
    });

    test('crop', () async {
      expect((await runp('return crop(string: "hello world", startIndex: 0, endIndex: 5);')).value,
          'hello');
      expect((await runp('return crop(string: "hello", startIndex: 1, endIndex: 3);')).value, 'el');
    });

    test('pad', () async {
      expect(
          (await runp(
                  'return pad(string: "abc", paddingChar: "x", length: 5, paddingDirection: "right");'))
              .value,
          'abcxx');
      expect(
          (await runp(
                  'return pad(string: "abc", paddingChar: "x", length: 5, paddingDirection: "left");'))
              .value,
          'xxabc');
    });

    test('insert', () async {
      expect((await runp('return insert(string: "abcd", index: 2, subString: "XY");')).value,
          'abXYcd');
    });

    test('append', () async {
      expect((await runp('return append(string: "ab", subString: "cd");')).value, 'abcd');
    });

    test('removeSpChar / removeAlpha / removeDigit', () async {
      expect((await runp('return removeSpChar(string: "a!b@c");')).value, 'abc');
      expect((await runp('return removeAlpha(string: "a1b2");')).value, '12');
      expect((await runp('return removeDigit(string: "a1b2");')).value, 'ab');
    });

    test('insertRandDigit 确定性且只插入数字', () async {
      final a = await runp('return insertRandDigit(string: "abc", amount: 3, seed: 42);');
      final b = await runp('return insertRandDigit(string: "abc", amount: 3, seed: 42);');
      expect(a.ok, isTrue, reason: 'detail: ${a.error?.toString()}');
      expect(a.value, b.value);
      expect(a.value!.length, 6); // 3 个数字插入后长度 6
      expect(a.value!.replaceAll(RegExp(r'[^0-9]'), '').length, 3); // 恰好 3 个数字
    });

    test('insertRandSp 只插入特殊字符', () async {
      final a = await runp('return insertRandSp(string: "abc", amount: 2, seed: 42);');
      final b = await runp('return insertRandSp(string: "abc", amount: 2, seed: 42);');
      expect(a.ok, isTrue, reason: 'detail: ${a.error?.toString()}');
      expect(a.value, b.value);
      const special = ['!', '@', '#', '=', '%', '^', '&', '*'];
      final inserted = a.value!
          .split('')
          .where((c) => special.contains(c))
          .toList();
      expect(inserted.length, 2);
    });

    test('insertRandLower 只插入小写字母', () async {
      final a = await runp('return insertRandLower(string: "abc", amount: 2, seed: 42);');
      final b = await runp('return insertRandLower(string: "abc", amount: 2, seed: 42);');
      expect(a.ok, isTrue, reason: 'detail: ${a.error?.toString()}');
      expect(a.value, b.value);
      expect(a.value!.length, 5); // 2 个字母插入后长度 5
      expect(a.value!.replaceAll(RegExp(r'[^a-z]'), '').length, 5); // 全部为小写字母
    });

    test('insertRandUpper 只插入大写字母', () async {
      final a = await runp('return insertRandUpper(string: "ABC", amount: 2, seed: 42);');
      final b = await runp('return insertRandUpper(string: "ABC", amount: 2, seed: 42);');
      expect(a.ok, isTrue, reason: 'detail: ${a.error?.toString()}');
      expect(a.value, b.value);
      expect(a.value!.length, 5); // 2 个字母插入后长度 5
      expect(a.value!.replaceAll(RegExp(r'[^A-Z]'), '').length, 5); // 全部为大写字母
    });

    test('insertRand* amount=0 返回原串', () async {
      expect((await runp('return insertRandDigit(string: "abc", amount: 0);')).value, 'abc');
      expect((await runp('return insertRandSp(string: "abc", amount: 0);')).value, 'abc');
      expect((await runp('return insertRandLower(string: "abc", amount: 0);')).value, 'abc');
      expect((await runp('return insertRandUpper(string: "abc", amount: 0);')).value, 'abc');
    });

    test('insertRand* 空串时生成单个对应字符', () async {
      final d = await runp('return insertRandDigit(string: "", amount: 1);');
      expect(d.value, matches(RegExp(r'[0-9]')));
      final s = await runp('return insertRandSp(string: "", amount: 1);');
      expect(s.value, matches(RegExp(r'[!@#=%^&*]')));
      final lo = await runp('return insertRandLower(string: "", amount: 1);');
      expect(lo.value, matches(RegExp(r'[a-z]')));
      final up = await runp('return insertRandUpper(string: "", amount: 1);');
      expect(up.value, matches(RegExp(r'[A-Z]')));
    });

    test('insertRand* 不同 seed 输出不同', () async {
      final a = await runp('return insertRandDigit(string: "abc", amount: 3, seed: 1);');
      final b = await runp('return insertRandDigit(string: "abc", amount: 3, seed: 2);');
      expect(a.value, isNot(b.value));
    });
  });

  group('toPBKDF2 / shuffle 确定性', () {
    test('toPBKDF2 结果确定且非空', () async {
      final a = await runp('return toPBKDF2(string: "pw", salt: "salt", iterations: 1);');
      final b = await runp('return toPBKDF2(string: "pw", salt: "salt", iterations: 1);');
      expect(a.ok, isTrue);
      expect(a.value, isNotEmpty);
      expect(a.value, b.value);
    });

    test('shuffle 相同种子结果确定', () async {
      final a = await runp('return shuffle(string: "abcdefgh", seed: 42);');
      final b = await runp('return shuffle(string: "abcdefgh", seed: 42);');
      expect(a.ok, isTrue);
      expect(a.value, b.value);
    });
  });

  group('Grammer.md 示例', () {
    test('完整示例可运行并返回非空字符串', () async {
      final src = '''
GroupInput {
    str master: "主密码";
    str seedString: "种子字符串";
    int seed: "种子" = 0;
    int iterations: "迭代次数" = 100000;
}
Generate {
    str password = "";

    if(
        cond: iterations > 1000000,
        onTrue: raise("迭代次数不能超过1000000"),
        onFalse: pass
    );

    password = master + seedString;
    password = toBase64(string: password);
    return password;
}
''';
      final r = await runDsl(src, {
        'master': 'm',
        'seedString': 's',
        'seed': 0,
        'iterations': 5,
      });
      expect(r.ok, isTrue);
      expect(r.value, isNotEmpty);
    });
  });

  group('parseDslInputs 解析输入列表', () {
    const source = '''
GroupInput {
    str master: "主密码";
    str seedString: "种子字符串";
    int seed: "种子" = 7;
    bool flag: "标志" = false;
}
Generate { return "x"; }
''';

    test('返回所有输入的 name / displayName', () {
      final inputs = parseDslInputs(source);
      expect(inputs.map((i) => i.name), ['master', 'seedString', 'seed', 'flag']);
      expect(inputs.map((i) => i.displayName), ['主密码', '种子字符串', '种子', '标志']);
    });

    test('value 初始为源码默认值，default 为原始默认值', () {
      final inputs = parseDslInputs(source);
      final seed = inputs.singleWhere((i) => i.name == 'seed');
      expect(seed.defaultValue, 7);
      expect(seed.value, 7); // 未提供任何取值，value 初始为默认值
    });

    test('value 可在解析后由 UI 填充（供后续收集用户输入）', () {
      final inputs = parseDslInputs(source);
      final seed = inputs.singleWhere((i) => i.name == 'seed');
      seed.value = 42; // UI 写入用户输入后的值
      expect(seed.value, 42);
    });

    test('无默认值的输入 value 为 null', () {
      final inputs = parseDslInputs(source);
      final master = inputs.singleWhere((i) => i.name == 'master');
      expect(master.defaultValue, isNull);
      expect(master.value, isNull);
    });

    test('源码语法错误时抛出 DslError', () {
      expect(() => parseDslInputs('Generate { return "x"; }'), throwsA(isA<DslError>()));
    });
  });
}