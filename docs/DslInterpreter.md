# DSL 解释器调用指南

本文件介绍如何以编程方式调用 DSL 解释器来执行一段 DSL 配置，以及如何处理其返回结果。

DSL 语法详情见 [Grammer.md](./Grammer.md)。解释器代码位于：

- 公共入口：[`lib/modules/generator/dsl/interpreter.dart`](../lib/modules/generator/dsl/interpreter.dart)
- 错误类型：[`lib/modules/generator/dsl/errors.dart`](../lib/modules/generator/dsl/errors.dart)
- 词法/语法/内建函数/值类型：`lib/modules/generator/dsl/` 下其余文件

---

## 1. 引入

```dart
import 'package:passtateless/modules/generator/dsl/interpreter.dart';
import 'package:passtateless/modules/generator/dsl/errors.dart';
```

解释器自包含，不依赖 `appLogger` / UI，可在纯 Dart / 测试环境中直接使用。

---

## 2. 公共入口

解释器只有一个公开函数：

```dart
Future<DslResult> runDsl(
  String source,                  // 完整的 DSL 源码（含 GroupInput 与 Generate 两个块）
  Map<String, dynamic> inputValues, // GroupInput 所有输入变量的一次性取值
) 
```

`DslResult` 是解析 + 执行 + 求值全部合并在内的总入口：内部依次完成
词法分析 → 语法分析 → 解析输入变量 → 执行 Generate 块，最后返回最终密码或错误。

> 输入变量值由调用方一次性传入（`inputValues`），解释器不做任何交互请求。
> UX 层的"向用户收集输入"由调用方负责。

---

## 3. 你提供的 DSL 源码结构

示例（等价于 Grammer.md 中的例子）：

```dart
final source = '''
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
```

---

## 4. 传入输入变量（inputValues）

对 `GroupInput` 中声明的每个变量，解释器的解析规则如下：

| 变量 | 必须提供？ | 行为 |
| --- | --- | --- |
| `master`、`seedString` | 必须 | 由程序提供（不会向用户请求）；缺失则报 `missingInput` 错误 |
| 其余变量 | 可选 | 若 `inputValues` 提供 → 用之；否则若有声明默认值 → 用默认；两者皆无 → 报 `missingInput` 错误 |

给出的值会按声明的类型校验：`str` ↔ 字符串、`int` ↔ 整数、`bool` ↔ 布尔。
类型不符会抛出 `typeError`。

调用示例：

```dart
final inputValues = <String, dynamic>{
  'master': '我的主密码',     // 必需
  'seedString': '我的种子',   // 必需
  'seed': 0,                 // 可选，覆盖默认值
  'iterations': 5,           // 可选，覆盖默认值
};
```

> 注意：`iterations` 若缺省，且源码里声明了 `= 100000`，则取 100000
> （PBKDF2 迭代次数很高会拖慢生成，测试时请传入较小值）。

---

## 5. 处理结果

`runDsl` 是异步的（`toPBKDF2` 需要 `await`），返回 `DslResult`：

```dart
final DslResult result = await runDsl(source, inputValues);

if (result.ok) {
  // 成功：value 即为最终密码（字符串）
  final String password = result.value!;
  print('生成成功: $password');
} else {
  // 失败：error 包含详细信息
  final DslError err = result.error!;
  print('生成失败: ${err.display}');   // 含行号/列号
}
```

### DslResult 字段

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `ok` | `bool` | `true` 表示成功 |
| `value` | `String?` | 成功时的最终密码（字符串）；失败时为 `null` |
| `error` | `DslError?` | 失败时的错误对象；成功时为 `null` |

约定：`ok == true` 时 `value != null` 且 `error == null`；
`ok == false` 时 `error != null` 且 `value == null`。

---

## 6. 错误对象（DslError）

```dart
class DslError implements Exception {
  final DslErrorKind kind;    // 错误类别
  final String message;       // 错误说明（含类别前缀，如 "用户抛出错误：xxx"）
  final String? userMessage;  // kind == userRaise 时为 raise(...) 提供的原文
  final int? line;            // 出错位置（可能为空）
  final int? col;             // 出错位置（可能为空）
  bool get isUserRaise;       // 是否为用户 raise() 主动抛出
  String get display;         // 拼接行/列后的可展示文本
}
```

### DslErrorKind 取值

| 类别 | 触发场景 |
| --- | --- |
| `lexical` | 非法字符、未闭合字符串、非法转义 |
| `syntax` | 缺少 master / 缺少或多余 `return` / 缺失分号 / 关键字参数非法等 |
| `typeError` | 赋值跨类型、运算符类型不符、参数类型不符、if 的 cond 非布尔、pass/raise 误用等 |
| `missingInput` | 某输入变量缺少值且未声明默认值 |
| `userRaise` | DSL 执行到 `raise("...")` 主动抛出的错误 |
| `runtime` | 除零、未定义变量、除以零、未知函数等 |

常见处理分支示例：

```dart
if (!result.ok) {
  final err = result.error!;
  switch (err.kind) {
    case DslErrorKind.missingInput:
      // 有必填输入变量未提供，可据此提示调用方补充
      break;
    case DslErrorKind.userRaise:
      // 展示用户侧的校验消息
      showToUser(err.userMessage ?? err.message);
      break;
    default:
      // 一般语法/类型/运行期错误，展示 err.display
      showToUser(err.display);
  }
}
```

---

## 7. 一个完整示例

```dart
import 'package:passtateless/modules/generator/dsl/interpreter.dart';
import 'package:passtateless/modules/generator/dsl/errors.dart';

Future<String?> generateWithDsl({
  required String source,
  required String master,
  required String seedString,
  Map<String, dynamic> extraInputs = const {},
}) async {
  final inputs = <String, dynamic>{
    'master': master,
    'seedString': seedString,
    ...extraInputs,
  };
  final result = await runDsl(source, inputs);
  if (result.ok) return result.value;
  // 失败时把用户错误与一般错误区分开（由调用方决定如何处理/展示）
  final err = result.error!;
  return null;
}
```

---

## 8. 测试

解释器的单元测试见 [`tests/dsl_interpreter_test.dart`](../tests/dsl_interpreter_test.dart)，
覆盖词法/语法错误、输入解析、运算符、赋值、if 懒求值、return 截断、raise、
全部内建函数与 Grammer.md 示例。运行：

```bash
flutter test tests/dsl_interpreter_test.dart
```

新增功能或修改语法时，建议同步补充该文件的用例。

---

## 9. 注意事项

- **`return` 只能返回字符串**，其它类型会报 `typeError`。
- **必须有且只能有一个 `return`**，否则语法报错；`return` 之后的语句会被忽略。
- **函数调用仅支持关键字参数**（如 `toBase64(string: ...)`），不接受位置参数。
- `master`、`seedString` 由程序在 `inputValues` 中提供，解释器不会把它们视为"待用户输入"。
- `raise()` 通过 `result.error.kind == DslErrorKind.userRaise` 以及
  `isUserRaise` / `userMessage` 识别，方便与内部错误区分。