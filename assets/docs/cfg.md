## 程序结构

生成算法由一段「生成脚本」描述。它不是 JSON，而是一种为密码生成而设计的专用脚本语言（DSL）。脚本必须按顺序包含两个代码块：

- `GroupInput { … }`：声明生成时需要的外部输入变量。
- `Generate { … }`：声明计算步骤，最终必须用 `return` 返回一个字符串（即最终密码）。

脚本以 `;` 作为每条语句的结束符，使用 `#` 作为行注释（`#` 之后到行尾的内容均被忽略）。

## GroupInput：输入变量

```text
类型 变量名: "显示名" = 默认值;
```

- **类型**：`str`（字符串）、`int`（整数）、`bool`（布尔）。
- **变量名**：脚本内引用该变量所用的标识符。
- **"显示名"**：向用户请求输入时显示的名称。
- **`= 默认值`**（可选）：未提供输入时使用的兜底值；只允许 `str`/`int`/`bool` 字面量。

**约束：每个 `GroupInput` 都必须声明且只能声明一个 `master` 和一个 `seedString` 变量。** 二者由程序自动提供、不会向用户请求；其余变量由用户在生成时填写，缺少时回落到声明中的默认值。

## Generate：计算过程

`Generate` 中可混用以下语句：

- **声明局部变量**：`str password = 表达式;`
- **赋值**：`password = 表达式;`（不能跨类型赋值）
- **函数调用（作表达式语句）**：`crop(string: password);`
- **条件**：`if(cond: …, onTrue: …, onFalse: …);`
- **主动报错**：`raise("错误信息");`
- **占位**：`pass;`
- **返回**：`return 表达式;`

`Generate` 中必须有且只有一个 `return` 语句，且 `return` 只能返回字符串。

## 表达式

支持字面量（字符串 `"…"`、整数、布尔 `true`/`false`）、变量引用、括号分组，以及下列运算符：

- **一元取非**：`! 布尔`
- **算术**：`+` `-` `*` `/`
  - `int`：加减乘除（`/` 为整除，除以零会报错）。
  - `str`：`str + str` 拼接、`str - str` 剔除子串、`str * int` 重复。
- **比较**：`==` `!=` `>` `<` `>=` `<=`（数值比较，`==`/`!=` 可用于任意同类型）
- **逻辑**：`AND` `OR`（仅用于布尔）
- **函数调用**：`函数名(关键字参数, …)`

## 函数调用

所有内建函数都使用**关键字参数**（`函数名(参数名: 表达式)`）。除必要参数外，均可省略以使用默认值。

### if（条件分支）

`if(cond: 条件, onTrue: …, onFalse: …)` 是唯一的条件函数：

- `cond`：一个布尔表达式。
- `onTrue` / `onFalse`：分别表示条件为真 / 为假时执行的分支，可以是普通表达式、`pass`（不产生结果）或 `raise("…")`（抛出错误）。两者都省略时默认视为 `pass`。

## 内建函数列表

**注意**：所有函数第一个参数的约定如下——`string` 表示传入的源字符串。除下表注明外，源字符串参数为必要参数。

### 长度与编码

| 函数 | 说明 | 参数（默认值） |
|:----|:----|:----------|
| `len` | 返回字符串长度 | `string` |
| `toBase64` | Base64 编码 | `string` |
| `toSHA256` | SHA256 哈希 | `string` |
| `toPBKDF2` | PBKDF2 密钥派生（HMAC-SHA256） | `string`, `salt`（必填）, `iterations`（`100000`） |
| `toArgon2id` | Argon2id 密钥派生 | `string`, `salt`（必填）, `parallelism`（`1`）, `memory`（`19000`）, `iterations`（`2`）, `hashLength`（`32`） |

### 字符过滤与清理

| 函数 | 说明 | 参数（默认值） |
|:----|:----|:----------|
| `removeSpChar` | 移除所有特殊字符 | `string` |
| `removeAlpha` | 移除所有字母 | `string` |
| `removeDigit` | 移除所有数字 | `string` |
| `deduplicate` | 去除重复字符，仅保留首次出现的字符 | `string` |

### 字符串变换

| 函数 | 说明 | 参数（默认值） |
|:----|:----|:----------|
| `reverse` | 完全反转字符串 | `string` |
| `rotate` | 旋转字符（左移或右移） | `string`, `rotations`（`1`）, `direction`（`"left"`/`"right"`） |
| `extract` | 从索引 0 开始按步长抽取字符 | `string`, `stepSize`（`1`） |
| `crop` | 按索引区间截取子串 | `string`, `startIndex`（`0`）, `endIndex`（`len(string)`） |
| `pad` | 填充字符至目标长度 | `string`, `paddingChar`（必填）, `length`（`0`）, `paddingDirection`（`"right"`） |
| `insert` | 在指定索引处插入子串 | `string`, `index`（`0`）, `subString`（必填） |
| `append` | 在末尾追加子串 | `string`, `subString`（必填） |

其中 `crop` 的 `endIndex` 默认取当前字符串长度，因此省略时等价于「截取前 `startIndex` 个字符」。`pad` 在源码长度已达或超过 `length`，或 `length <= 0` 时保持不变。

### 随机插入与打乱

*随机性以当前字符串的 SHA256 前 7 位 ASCII 码之和作为基础种子（空串时基种子为 0），并叠加 `seed`。在输入保持不变的前提下，相同脚本总是产生相同结果。*

| 函数 | 说明 | 参数（默认值） |
|:----|:----|:----------|
| `insertRandDigit` | 随机插入数字 (0-9) | `string`, `amount`（`1`）, `seed`（`0`） |
| `insertRandAlpha` | 随机插入字母 (A-Z / a-z) | `string`, `amount`（`1`）, `seed`（`0`） |
| `insertRandSp` | 随机插入特殊字符 | `string`, `amount`（`1`）, `seed`（`0`） |
| `shuffle` | 随机打乱字符顺序 | `string`, `seed`（`0`） |

## 变量传递

与旧版以 `#password` 显式引用当前密码不同，新脚本使用**局部变量**在步骤之间传递中间结果。你可以声明任意名称的 `str`/`int`/`bool` 变量，并在后续步骤中持续对其赋值：

```text
str password = toBase64(string: seedString);
password = toPBKDF2(string: password, salt: master, iterations: 100000);
password = crop(string: password, endIndex: 16);
return password;
```

## 错误处理

解析或运行出错时，脚本中止并返回 `DslError`，错误类型如下：

- **`lexical`**：非法字符、字符串未闭合、非法转义等。
- **`syntax`**：语法不合法、输入变量重复声明、缺少 `return`、未声明 `master`/`seedString` 等。
- **`typeError`**：类型不匹配、缺少必要参数、向函数传了不存在的参数、跨类型赋值等。
- **`missingInput`**：输入变量没有默认值，且生成时又未提供取值。
- **`userRaise`**：由 `raise()` 主动抛出，`raise` 参数为本次的错误信息字符串。
- **`runtime`**：运行期错误（如除以零、未知函数、非法方向/步长取值）。

## 示例

假设原始输入包含中文或特殊 Unicode 字符，希望生成只包含字母和数字的标准化密码：先 Base64 编码转成纯 ASCII，再做 PBKDF2 派生、移除特殊字符并截取固定长度。

```text
GroupInput {
    str master: "主密码";
    str seedString: "种子字符串";
    int length: "密码长度" = 16;
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
    password = insertRandAlpha(string: password, amount: 2);
    return password;
}
```

**执行流程解析：**

1. **`toBase64`**：将可能包含 Unicode 的原始输入转换为标准 Base64 字符串，使后续处理只接触 ASCII 字符。
2. **`toPBKDF2`**：用 主密码 作为 salt，对上一步结果做密钥派生（迭代次数 `iter`）。
3. **`crop`**：截取前 `length - 6` 个字符。
4. **`insertRand*`**：再随机补入 2 位数字、2 位特殊字符、2 位字母，得到最终密码。

更完整的脚本与组合方式可参考应用内置的预设。