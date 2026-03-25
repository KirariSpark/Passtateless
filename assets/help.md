## 生成配置
生成器采用JSON格式的配置文件，支持预处理、操作序列和后处理三个部分。
### 配置模板
```json
{
  "preprocess": {
    "操作": "参数"
  },
  "operations": {
    "操作1": "",
    "操作2": {
      "参数1的键": "参数1的值"
    }
  },
  "postprocess": {}
}
```
## 变量系统
你可以使用 `#` 前缀来引用系统变量：

| 变量名         | 描述         |
|-------------|------------|
| `#password` | 当前密码的当前状态值 |

## 重复的操作
JSON 不支持包含相同的键，例如，你不能同时进行两次同一名字的操作。此时，你需要为重复的操作名加上序号，例如`crop_1`。  
序号不会影响解析，只是为了符合 JSON 的语法。

## 预处理 (Preprocess)
在主要操作之前执行的转换操作：

| 操作名            | 参数 | 描述             |
|----------------|----|----------------|
| `toBase64`     | 无  | 将输入转换为Base64编码 |
| `toSHA256`     | 无  | 计算输入的SHA256哈希值 |
| `removeSpChar` | 无  | 移除所有特殊字符       |
| `removeAlpha`  | 无  | 移除所有字母字符       |
| `removeDigits` | 无  | 移除所有数字字符       |

## 主要操作 (Operations)
### 基本操作
| 操作名           | 参数            | 描述         |
|---------------|---------------|------------|
| `reverse`     | 无             | 反转整个字符串    |
| `deduplicate` | 无             | 去除重复的字符    |
| `repeat`      | `times`: 重复次数 | 将字符串重复指定次数 |
### 截取操作
| 操作名       | 参数                                       | 描述          |
|-----------|------------------------------------------|-------------|
| `crop`    | `length`: 目标长度                           | 截取字符串到指定长度  |
| `extract` | `step`: 步长, `start`: 起始位置                | 按步长抽取字符     |
| `rotate`  | `steps`: 步数, `direction`: 方向(left/right) | 旋转字符串（凯撒密码） |
### 插入操作
| 操作名               | 参数                               | 描述            |
|-------------------|----------------------------------|---------------|
| `insert`          | `inserted`: 插入内容, `location`: 位置 | 在指定位置插入字符串    |
| `append`          | `appended`: 追加内容                 | 在末尾追加字符串      |
| `insertRandNum`   | `amount`: 数量, `seed`: 种子         | 随机插入指定数量的数字字符 |
| `insertRandAlpha` | `amount`: 数量, `seed`: 种子         | 随机插入指定数量的字母字符 |
| `insertRandSp`    | `amount`: 数量, `seed`: 种子         | 随机插入指定数量的特殊字符 |
| `shuffle`         | `iterations`: 次数, `seed`: 种子     | 随机打乱密码        |

注：随机插入操作的种子是一个偏移量，实际生成中会根据当前密码生成种子并加上偏移量。
### 调整操作
| 操作名              | 参数                                                      | 描述        |
|------------------|---------------------------------------------------------|-----------|
| `pad`            | `length`: 目标长度, `char`: 填充字符, `position`: 位置(end/start) | 填充到指定长度   |
| `adjustLength`   | `length`: 目标长度, `char`: 填充字符, `position`: 位置(end/start) | 自动调整到指定长度 |
| `reversePartial` | `start`: 开始位置, `end`: 结束位置                              | 反转部分字符    |
### 过滤操作
| 操作名            | 参数 | 描述         |
|----------------|----|------------|
| `removeSpChar` | 无  | 移除所有特殊字符   |
| `removeAlpha`  | 无  | 移除所有字母字符   |
| `removeDigits` | 无  | 移除所有数字字符   |
## 后处理 (Postprocess)
在主要操作之后执行的转换操作，支持的操作与预处理相同：
- `toBase64`
- `toSHA256`
- `removeSpChar`
- `removeAlpha`
- `removeDigits`
## 随机数生成器
为保证结果的可复现性，系统使用自定义的Xorshift32算法生成随机数：
- 相同的输入、配置和seed参数将**始终产生相同的结果**
- seed参数为可选，默认为0
- 字符通过ASCII码生成，确保跨平台一致性
## 配置示例
### 示例1：为不支持特殊字符的平台生成
```json
{
  "preprocess": {
    "toBase64": ""
  },
  "operations": {
    "crop": {"length": 12},
    "insertRandNum": {"amount": 2, "seed": 123},
    "insertRandSp": {"amount": 1, "seed": 456},
    "rotate": {"steps": 3, "direction": "right"}
  },
  "postprocess": {
    "removeSpChar": ""
  }
}
```
### 示例2：简单格式调整
```json
{
  "operations": {
    "reverse": "",
    "adjustLength": {"length": 16, "char": "*", "position": "end"},
    "deduplicate": ""
  }
}
```
### 示例3：仅保留特殊字符和数字
```json
{
  "operations": {
    "removeAlpha": ""
  }
}
```
## 建议
1. **预处理清理**：过一遍`toBase64`和`removeSpChar`，可以让输入只包含字母和数字，同时你可以输入任意 Unicode 字符
2. **随机性增强**：在多个位置使用随机插入，设置不同的seed值
3. **别忘了SHA256**：SHA256的结果只有小写字母和数字，要注意
