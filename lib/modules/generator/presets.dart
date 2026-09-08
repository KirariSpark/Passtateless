/// DSL 内置预设（与 lib/modules/generator/builtin.dart 中的 JSON 预设功能等效）。
///
/// 约定：`seedString` 由调用方传入，其值即 JSON 方案 `composeSeed` 的拼接结果
/// `"$identifier: $userName @ $account"`。`master` 为 GroupInput 的必填变量，
/// 本预设不参与运算，但仍需声明。
///
/// 等效性说明：与 JSON 预设的命令顺序、参数逐条对应；
/// 其中 `toSHA256` 复刻 core.dart 中“对初始种子串哈希”的行为（而非当前密码），
/// 因此 complex/bank 中保留 `seedString` 并直接传给 `toSHA256`。
const String simple = '''
GroupInput {
    str master: "主密码";
    str seedString: "种子字符串";
}
Generate {
    str password = toBase64(string: seedString);
    password = insertRandDigit(string: password, amount: 3);
    password = insertRandSp(string: password, amount: 2);
    password = insertRandAlpha(string: password, amount: 2);
    password = crop(string: password, endIndex: 12);
    return password;
}
''';

const String complex = '''
GroupInput {
    str master: "主密码";
    str seedString: "种子字符串";
}
Generate {
    str password = toBase64(string: seedString);
    password = toSHA256(string: seedString);
    password = toPBKDF2(string: password, salt: password, iterations: 100000);
    password = reverse(string: password);
    password = crop(string: password, startIndex: 1);
    password = extract(string: password, stepSize: 2);
    password = insertRandDigit(string: password, amount: 10, seed: 42);
    password = insertRandSp(string: password, amount: 10, seed: 42);
    password = insertRandAlpha(string: password, amount: 10, seed: 42);
    password = if(
        cond: len(string: password) > 16,
        onTrue: crop(string: password, endIndex: 16),
        onFalse: pad(string: password, paddingChar: "X", length: 16, paddingDirection: "right")
    );
    return password;
}
''';

const String bank = '''
GroupInput {
    str master: "主密码";
    str seedString: "种子字符串";
}
Generate {
    str password = toBase64(string: seedString);
    password = toSHA256(string: seedString);
    password = toPBKDF2(string: password, salt: password, iterations: 100000);
    password = rotate(string: password, rotations: 5, direction: "right");
    password = extract(string: password, stepSize: 3);
    password = toSHA256(string: seedString);
    password = removeAlpha(string: password);
    password = removeSpChar(string: password);
    password = if(
        cond: len(string: password) > 6,
        onTrue: crop(string: password, endIndex: 6),
        onFalse: pad(string: password, paddingChar: "0", length: 6, paddingDirection: "right")
    );
    return password;
}
''';
