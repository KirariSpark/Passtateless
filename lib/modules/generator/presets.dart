const String simple = '''
GroupInput {
    str master: "主密码";
    str seedString: "种子字符串";
    int length: "密码长度" = 12;
}
Generate {
    str password = toBase64(string: seedString);
    password = crop(string: password, endIndex: length - 6);
    password = insertRandDigit(string: password, amount: 2);
    password = insertRandSp(string: password, amount: 2);
    password = insertRandAlpha(string: password, amount: 2);
    return password;
}
''';

const String complex = '''
GroupInput {
    str master: "主密码";
    str seedString: "种子字符串";
    int length: "密码长度" = 16;
}
Generate {
    str password = toBase64(string: seedString);
    password = toSHA256(string: seedString);
    password = toPBKDF2(string: password, salt: master, iterations: 100000);
    password = reverse(string: password);
    password = crop(string: password, startIndex: 1);
    password = extract(string: password, stepSize: 2);
    password = if(
        cond: len(string: password) > 16 - 6,
        onTrue: crop(string: password, endIndex: 16 - 6),
        onFalse: pad(string: password, paddingChar: "X", length: 16 - 6, paddingDirection: "right")
    );
    password = insertRandDigit(string: password, amount: 2);
    password = insertRandSp(string: password, amount: 2);
    password = insertRandAlpha(string: password, amount: 2);
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
