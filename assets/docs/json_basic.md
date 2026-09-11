## 什么是生成脚本

Passtateless 的密码生成算法由一段「生成脚本」描述。它是一种为密码生成而设计的专用脚本语言（DSL）。脚本把输入（如主密码、种子）一步一步计算成最终的密码字符串。

脚本严格由两个代码块组成：

- `GroupInput { … }`：声明生成时需要的外部输入（如主密码、种子、长度）。
- `Generate { … }`：声明计算步骤，最后用 `return` 输出结果。

## 基本结构

一个最简脚本：

```text
GroupInput {
    str master: "主密码";
    str seedString: "种子字符串";
    int length: "密码长度" = 12;
}
Generate {
    str password = toBase64(string: seedString);
    password = crop(string: password, endIndex: length);
    return password;
}
```

- 每条声明或语句以 `;` 结尾。
- `#` 之后到行尾都是注释。
- 输入声明格式为 `类型 变量名: "显示名" = 默认值;`。
- `master` 与 `seedString` 是固定必须声明的外部输入，其余输入（如上面的 `length`）由你在生成时设置。

## 语法要点

- **类型**：变量类型只有三种——`str`（字符串）、`int`（整数）、`bool`（布尔）。
- **表达式**：数字、字符串、布尔，以及 `+ - * /`、`== != > < >= <=`、`AND OR`、`!` 等运算符；字符串支持 `+` 拼接、`-` 剔除子串、`* `重复。
- **函数调用**：全部使用关键字参数，格式为 `函数名(参数名: 值)`，如 `crop(string: password, endIndex: 12)`。
- **局部变量**：用 `str password = …;` 声明，再用 `password = …;` 持续改写，在步骤之间传递中间结果。
- **条件**：`if(cond: 布尔表达式, onTrue: …, onFalse: …)`，分支可为普通表达式、`pass` 或 `raise("…")`。
- **报错与占位**：`raise("错误信息")` 主动中止并报错；`pass` 表示什么都不做。

## 下一步

了解可用的全部函数、参数与默认值，请阅读 **配置生成器** 一文。