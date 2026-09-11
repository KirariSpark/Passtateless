const String simple = '''
GroupInput {
    str master: "主密码";
    str seedString: "种子字符串";
    int length: "密码长度" = 12;
    int iter: "迭代次数" = 100000;
}
Generate {
    if(
        cond: iter > 1000000,
        onTrue: raise("迭代次数过多"),
        onFalse: pass
    );
    str password = toBase64(string: seedString);
    password = toPBKDF2(string: password, salt: master, iterations: iter);
    password = crop(string: password, endIndex: length - 6);
    password = insertRandDigit(string: password, amount: 2);
    password = insertRandSp(string: password, amount: 2);
    password = insertRandLower(string: password, amount: 1);
    password = insertRandUpper(string: password, amount: 1);
    return password;
}
''';

const String complex = '''
GroupInput {
    str master: "主密码";
    str seedString: "种子字符串";
    int length: "密码长度" = 16;
    int mem: "内存消耗 (KB)" = 19000;
}
Generate {
    if(
        cond: mem > 128000,
        onTrue: raise("内存消耗过高"),
        onFalse: pass
    );
    str password = toBase64(string: seedString);
    password = toSHA256(string: seedString);
    password = toArgon2id(string: password, salt: master, memory: mem);
    password = reverse(string: password);
    password = crop(string: password, startIndex: 1);
    password = extract(string: password, stepSize: 2);
    password = if(
        cond: len(string: password) > length - 6,
        onTrue: crop(string: password, endIndex: length - 6),
        onFalse: pad(string: password, paddingChar: "X", length: length - 6, paddingDirection: "right")
    );
    password = insertRandDigit(string: password, amount: 2);
    password = insertRandSp(string: password, amount: 2);
    password = insertRandLower(string: password, amount: 1);
    password = insertRandUpper(string: password, amount: 1);
    return password;
}
''';

const String bank = '''
GroupInput {
    str master: "主密码";
    str seedString: "种子字符串";
    int mem: "内存消耗 (KB)" = 19000;
}
Generate {
    if(
        cond: mem > 128000,
        onTrue: raise("内存消耗过高"),
        onFalse: pass
    );
    str password = toBase64(string: seedString);
    password = toSHA256(string: seedString);
    password = toArgon2id(string: password, salt: master, memory: mem);
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
