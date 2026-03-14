import 'generator_v2.dart' as generator;
import 'dart:convert' as convert;

String warnings = "使用此算法生成一次密码以生成警告";

/// 预处理和后处理
void _processOperations(Map<String, dynamic>? processMap,
    generator.Generator operator, String processType) {
  if (processMap == null) return;

  if (processMap.containsKey("removeSpChar") &&
      processMap.containsKey("removeAlpha") &&
      processMap.containsKey("removeDigits")) {
    warnings += "不应将所有移除操作都加入预处理/后处理中\n";
  }

  processMap.forEach((key, value) {
    switch (key) {
      case "toBase64":
        operator.toBase64();
        break;
      case "toSHA256":
        operator.toSHA256();
        break;
      case "removeSpChar":
        operator.removeSpChar();
        break;
      case "removeAlpha":
        operator.removeAlpha();
        break;
      case "removeDigits":
        operator.removeDigits();
        break;
      default:
        warnings += "不受支持的$processType操作：$key\n";
        break;
    }
  });
}

/// 运行输入的JSON字符串定义的生成操作
///
/// 第一项不为0，则生成出错，第二项返回错误信息，否则返回密码
(int status, String result) parse(String commands, String input) {
  warnings = "";
  Map<String, dynamic> cmd = {};
  try {
    cmd = convert.json.decode(commands);
  } catch (e) {
    return (1, e.toString());
  }
  Map<String, dynamic>? preprocess = cmd["preprocess"];
  Map<String, dynamic>? operations = cmd["operations"];
  Map<String, dynamic>? postprocess = cmd['postprocess'];

  // 检查配置完整性
  if (operations == null) {
    return (1, "生成配置不完整");
  }

  generator.Generator operator = generator.Generator(input);
  operator.password = input;

  // 预处理
  _processOperations(preprocess, operator, "预处理");

  // 检查输入
  int checkResult = operator.checkInput();
  if (checkResult == 1) {
    warnings += "输入为空\n";
  } else if (checkResult == 2) {
    warnings += "输入包含空格\n";
  } else if (checkResult == 3) {
    warnings += "输入包含可能不受支持的字符\n";
  }

  // 生成操作
  operations.forEach((key, value) {
    String operationName = key;
    if (key.contains('_')) {
      operationName = key.split('_')[0];
    }
    // 选择操作
    switch (operationName) {
      case "reverse":
        {
          operator.reverse();
          break;
        }
      case "crop":
        {
          if (value is! Map) {
            warnings += "操作 crop 包含未定义的参数\n";
          } else {
            try {
              if (value.containsKey("length")) {
                int length = value["length"].toInt();
                operator.crop(length: length);
              }
            } catch (e) {
              warnings += "操作 crop 定义的参数有误\n";
            }
          }
          break;
        }
      case "insert":
        {
          if (value is! Map) {
            warnings += "操作 insert 包含未定义的参数\n";
          } else {
            try {
              if (value.containsKey("inserted") &&
                  value.containsKey("location")) {
                String inserted = value["inserted"].toString();
                if (inserted == "#password") {
                  inserted = operator.password;
                }
                int location = value["location"].toInt();
                operator.insert(inserted, location);
              }
            } catch (e) {
              warnings += "操作 insert 定义的参数有误\n";
            }
            break;
          }
        }
      case "extract":
        {
          if (value is! Map) {
            warnings += "操作 extract 包含未定义的参数\n";
          } else {
            try {
              if (value.containsKey("step")) {
                int step = value["step"].toInt();
                int start = 0;
                if (value.containsKey("start")) {
                  start = value["start"].toInt();
                }
                operator.extract(step, start: start);
              }
            } catch (e) {
              warnings += "操作 extract 定义的参数有误\n";
            }
          }
          break;
        }
      case "rotate":
        {
          if (value is! Map) {
            warnings += "操作 rotate 包含未定义的参数\n";
          } else {
            try {
              if (value.containsKey("steps")) {
                int steps = value["steps"].toInt();
                String direction = "left";
                if (value.containsKey("direction")) {
                  direction = value["direction"].toString();
                  if (direction == "#password") {
                    direction = operator.password;
                  }
                }
                operator.rotate(steps, direction: direction);
              }
            } catch (e) {
              warnings += "操作 rotate 定义的参数有误\n";
            }
          }
          break;
        }
      case "repeat":
        {
          if (value is! Map) {
            warnings += "操作 repeat 参数类型错误\n";
          } else {
            try {
              int times = value["times"].toInt();
              operator.repeat(times);
            } catch (e) {
              warnings += "操作 repeat 定义的参数有误\n";
            }
          }
          break;
        }
      case "deduplicate":
        {
          operator.deduplicate();
          break;
        }
      case "pad":
        {
          if (value is! Map) {
            warnings += "操作 pad 包含未定义的参数\n";
          } else {
            try {
              int length = 16;
              String char = "A";
              String position = "end";
              if (value.containsKey("length")) {
                length = value["length"].toInt();
              }
              if (value.containsKey("char")) {
                char = value["char"].toString();
                if (char == "#password") {
                  char = operator.password;
                }
              }
              if (value.containsKey("position")) {
                position = value["position"].toString();
              }
              operator.pad(length: length, char: char, position: position);
            } catch (e) {
              warnings += "操作 pad 定义的参数有误\n";
            }
          }
          break;
        }
      case "reversePartial":
        {
          if (value is! Map) {
            warnings += "操作 reversePartial 包含未定义的参数\n";
          } else {
            try {
              if (value.containsKey("start") && value.containsKey("end")) {
                int start = value["start"].toInt();
                int end = value["end"].toInt();
                operator.reversePartial(start, end);
              }
            } catch (e) {
              warnings += "操作 reversePartial 定义的参数有误\n";
            }
          }
          break;
        }
      case "append":
        {
          try {
            String appended = value["appended"].toString();
            if (appended == "#password") {
              appended = operator.password;
            }
            operator.append(appended);
          } catch (e) {
            warnings += "操作 append 定义的参数有误\n";
          }
          break;
        }
      case "adjustLength":
        {
          if (value is! Map) {
            warnings += "操作 adjustLength 包含未定义的参数\n";
          } else {
            try {
              int length = 16;
              String char = "A";
              String position = "end";
              if (value.containsKey("length")) {
                length = value["length"].toInt();
              }
              if (value.containsKey("char")) {
                char = value["char"].toString();
                if (char == "#password") {
                  char = operator.password;
                }
              }
              if (value.containsKey("position")) {
                position = value["position"].toString();
              }
              operator.adjustLength(
                  length: length, char: char, position: position);
            } catch (e) {
              warnings += "操作 adjustLength 定义的参数有误\n";
            }
          }
          break;
        }
      case "insertRandNum":
        {
          if (value is! Map) {
            warnings += "操作 insertRandNum 参数类型错误\n";
          } else {
            try {
              int amount = 1;
              int seed = 0;
              if (value.containsKey("amount")) {
                amount = value["amount"].toInt();
              }
              if (value.containsKey("seed")) {
                seed = value["seed"].toInt();
              }
              operator.insertRandNum(amount, seed: seed);
            } catch (e) {
              warnings += "操作 insertRandNum 定义的参数有误\n";
            }
          }
          break;
        }
      case "insertRandAlpha":
        {
          if (value is! Map) {
            warnings += "操作 insertRandAlpha 参数类型错误\n";
          } else {
            try {
              int amount = 1;
              int seed = 0;
              if (value.containsKey("amount")) {
                amount = value["amount"].toInt();
              }
              if (value.containsKey("seed")) {
                seed = value["seed"].toInt();
              }
              operator.insertRandAlpha(amount, seed: seed);
            } catch (e) {
              warnings += "操作 insertRandAlpha 定义的参数有误\n";
            }
          }
          break;
        }
      case "insertRandSp":
        {
          if (value is! Map) {
            warnings += "操作 insertRandSp 参数类型错误\n";
          } else {
            try {
              int amount = 1;
              int seed = 0;
              if (value.containsKey("amount")) {
                amount = value["amount"].toInt();
              }
              if (value.containsKey("seed")) {
                seed = value["seed"].toInt();
              }
              operator.insertRandSp(amount, seed: seed);
            } catch (e) {
              warnings += "操作 insertRandSp 定义的参数有误\n";
            }
          }
          break;
        }
      case "removeSpChar":
        {
          operator.removeSpChar();
          break;
        }
      case "removeAlpha":
        {
          operator.removeAlpha();
          break;
        }
      case "removeDigits":
        {
          operator.removeDigits();
          break;
        }
      case "shuffle":
        {
          if (value is! Map) {
            warnings += "操作 shuffle 参数类型错误\n";
          } else {
            try {
              int seed = 0;
              int iterations = 1;
              if (value.containsKey("seed")) {
                seed = value["seed"].toInt();
              }
              if (value.containsKey("iterations")) {
                iterations = value["iterations"].toInt();
              }
              operator.shuffle(seed, iterations);
            } catch (e) {
              warnings += "操作 shuffle 定义的参数有误\n";
            }
          }
          break;
        }
      default:
        {
          warnings += "不受支持的操作：$key\n";
          break;
        }
    }
  });

  // 后处理
  _processOperations(postprocess, operator, "后处理");

  // 执行checkPassword
  String checkPwdResult = operator.checkPassword();
  if (!(checkPwdResult == "")) {
    warnings += "$checkPwdResult\n";
  }

  return (0, operator.password);
}
