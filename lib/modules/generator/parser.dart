import 'package:passtateless/modules/generator/core.dart';
import 'package:passtateless/modules/core/error_codes.dart';

/// 解析参数中的变量引用
/// 如果参数以 # 开头，则解析为对应的变量值
dynamic _resolveArgVariable(dynamic arg, Generator generator) {
  if (arg is String && arg.startsWith('#')) {
    String variableName = arg.substring(1);
    switch (variableName) {
      case 'password':
        return generator.password;
      default:
        throw ArgumentError('Unknown variable: $arg');
    }
  }
  return arg;
}

/// 运行输入的列表定义的生成操作
(ErrorCode, String) parse(List<Map<String, dynamic>> commands, String input) {
  Generator generator = Generator(input);
  for (var item in commands) {
    String name = item['name'] as String;
    // 如果没有 args 字段，默认赋为空列表
    List<dynamic> rawArgs = (item['args'] as List<dynamic>?) ?? [];
    // 预处理参数：解析变量
    List<dynamic> args = rawArgs.map((arg) => _resolveArgVariable(arg, generator)).toList();

    try {
      switch (name) {
        case 'toBase64':
          generator.toBase64();
          break;
        case 'toSHA256':
          generator.toSHA256();
          break;
        case 'toPBKDF2':
          generator.toPBKDF2(
            args[0] as String,
            args.length > 1 ? args[1] as int : 100,
          );
          break;
        case 'removeSpChar':
          generator.removeSpChar();
          break;
        case 'removeAlpha':
          generator.removeAlpha();
          break;
        case 'removeDigits':
          generator.removeDigits();
          break;
        case 'reverse':
          generator.reverse();
          break;
        case 'crop':
          generator.crop(args.isNotEmpty ? args[0] as int : 16);
          break;
        case 'insert':
          generator.insert(
            args[0] as String,
            args.length > 1 ? args[1] as int : 0,
          );
          break;
        case 'extract':
          generator.extract(
            args.isNotEmpty ? args[0] as int : 1,
            args.length > 1 ? args[1] as int : 0,
          );
          break;
        case 'rotate':
          generator.rotate(
            args[0] as int,
            args.length > 1 ? args[1] as String : "left",
          );
          break;
        case 'repeat':
          generator.repeat(args.isNotEmpty ? args[0] as int : 1);
          break;
        case 'deduplicate':
          generator.deduplicate();
          break;
        case 'pad':
          generator.pad(
            args.isNotEmpty ? args[0] as int : 16,
            args.length > 1 ? args[1] as String : "A",
            args.length > 2 ? args[2] as String : "end",
          );
          break;
        case 'reversePartial':
          generator.reversePartial(args[0] as int, args[1] as int);
          break;
        case 'append':
          generator.append(args[0] as String);
          break;
        case 'setLength':
          generator.setLength(
            args.isNotEmpty ? args[0] as int : 16,
            args.length > 1 ? args[1] as String : "A",
            args.length > 2 ? args[2] as String : "end",
          );
          break;
        case 'insertRandDigit':
          generator.insertRandDigit(
            args.isNotEmpty ? args[0] as int : 1,
            args.length > 1 ? args[1] as int : 0,
          );
          break;
        case 'insertRandAlpha':
          generator.insertRandAlpha(
            args.isNotEmpty ? args[0] as int : 1,
            args.length > 1 ? args[1] as int : 0,
          );
          break;
        case 'insertRandSp':
          generator.insertRandSp(
            args.isNotEmpty ? args[0] as int : 1,
            args.length > 1 ? args[1] as int : 0,
          );
          break;
        case 'shuffle':
          generator.shuffle(
            args.isNotEmpty ? args[0] as int : 10,
            args.length > 1 ? args[1] as int : 0,
          );
          break;
        default:
          return (ErrorCode.unknownCommand, generator.password);
      }
    } catch (e) {
      // 捕获参数类型转换失败、索引越界、变量解析错误或 Generator 内部主动抛出的异常
      return (ErrorCode.invalidArgs, generator.password);
    }
  }
  return (ErrorCode.success, generator.password);
}
