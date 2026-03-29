import 'package:passtateless/modules/generator/core.dart';
import 'package:passtateless/modules/core/error_codes.dart';

/// 运行输入的列表定义的生成操作
(ErrorCode, String) parse(List<Map<String, dynamic>> commands, String input) {
  Generator generator = Generator(input);

  for (var item in commands) {

  }

  return (ErrorCode.success, generator.password);
}
