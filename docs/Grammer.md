## 生成器配置DSL语法

### 关键字

#### 变量定义

生成器仅支持定义字符串、整数和布尔类型的变量。

`str` 定义一个字符串变量\
`int` 定义一个整数变量\
`bool` 定义一个布尔变量

#### 其他

`return`返回值，所有位于它后面的语句都将被忽略，只能返回字符串。\
`raise(<错误信息>)`抛出错误，生成器在碰到它时将会`throw`并停止运行。\
`pass`是一个占位符，不执行任何操作，但可以确保语法正确。

### 符号

#### 算术运算符

##### `+`

`int` + `int` 对两个整数进行加法运算，返回整数\
`str` + `str` 对两个字符串进行拼接运算，返回字符串

##### `-`

`int` - `int` 对两个整数进行减法运算，返回整数\
`str` - `str` 从字符串中移除所有指定字符串，返回字符串

##### `*`

`int` \* `int` 对两个整数进行乘法运算，返回整数\
`str` \* `int` 从字符串中重复指定次数，返回字符串

##### `/`

`int` / `int` 对两个整数进行除法运算，返回整数

#### 比较运算符

`==` 对两个任意类型进行相等比较，返回布尔值
`!=` 对两个任意类型进行不相等比较，返回布尔值
`>` 对两个整数进行大于比较，返回布尔值
`<` 对两个整数进行小于比较，返回布尔值
`>=` 对两个整数进行大于等于比较，返回布尔值
`<=` 对两个整数进行小于等于比较，返回布尔值

#### 逻辑运算符

`AND` 对两个布尔变量进行与操作，返回布尔值
`OR` 对两个布尔变量进行或操作，返回布尔值
`!` 对一个布尔变量进行非操作，返回布尔值

#### 赋值运算符

`=` 对变量进行赋值，赋值不能跨类型。

#### 代码规范

使用`{}`定义代码块\
使用`;`结束语句\
使用`#`定义注释

### 函数

你不能定义函数，只能使用已有的函数。\
函数定义中，若有参数后面跟着`=`，则表示该参数为可选参数，默认值为`=`后面跟着的值。\
参数使用`,`分割，仅支持关键字参数。

#### if

`if`是一个用于条件判断的函数。

```
if(
    bool cond, # 条件表达式，必须返回布尔值
    any onTrue, # 如果为true的值
    any onFalse # 如果为false的值
)
```

#### len

`len`是一个用于获取字符串长度的函数，返回类型为`int`。

```
len(
    str string # 输入的字符串
)
```

#### toBase64

`toBase64`是一个用于将字符串转换为Base64编码的函数，返回类型为`str`。

```
toBase64(
    str string # 输入的字符串
)
```

#### toSHA256

`toSHA256`是一个用于将字符串转换为SHA256编码的函数，返回类型为`str`。

```
toSHA256(
    str string # 输入的字符串
)
```

#### toLower

`toLower`是一个用于将字符串中的大写字母转换为小写字母的函数，返回类型为`str`。

```
toLower(
    str string # 输入的字符串
)
```

#### toUpper

`toUpper`是一个用于将字符串中的小写字母转换为大写字母的函数，返回类型为`str`。

```
toUpper(
    str string # 输入的字符串
)
```

#### toPBKDF2

`toPBKDF2`是一个用于将字符串使用`PBKDF2`进行密钥派生的函数，返回类型为`str`。

```
toPBKDF2(
    str string, # 输入的字符串
    str salt, # 盐
    int iterations = 100000 # 迭代次数
)
```

#### toArgon2id

`toArgon2id`是一个用于将字符串使用`Argon2id`进行密钥派生的函数，返回类型为`str`。

```
toArgon2id(
    str string, # 输入的字符串
    str salt, # 盐
    int parallelism = 1, # 并行度
    int memory = 19000, # 内存，单位为 1kB 块（约 19 MiB），须不小于 8 × parallelism
    int iterations = 2, # 迭代次数
    int hashLength = 32 # 派生字节长度，须不小于 4
)
```

#### reverse

`reverse`是一个用于将字符串反转的函数，返回类型为`str`。

```
reverse(
    str string # 输入的字符串
)
```

#### deduplicate

`deduplicate`是一个用于从字符串中移除重复字符的函数，返回类型为`str`。

```
deduplicate(
    str string # 输入的字符串
)
```

#### rotate

`rotate`是一个用于将字符串旋转的函数，返回类型为`str`。

```
rotate(
    str string, # 输入的字符串
    int rotations = 1, # 旋转次数
    str direction = "left" # 旋转方向
)
```

#### extract

`extract`是一个用于从字符串中提取字符组成新串的函数，返回类型为`str`。

```
extract(
    str string, # 输入的字符串
    int stepSize = 1 # 步长
)
```

#### crop

`crop`是一个用于从字符串中裁剪子字符串的函数，返回类型为`str`。

```
crop(
    str string, # 输入的字符串
    int startIndex = 0, # 起始索引
    int endIndex = len(string) # 结束索引
)
```

#### pad

`pad`是一个用于将字符串填充到指定长度的函数，返回类型为`str`。

```
pad(
    str string, # 输入的字符串
    str paddingChar, # 填充字符
    int length = 0, # 目标长度
    str paddingDirection = "right" # 填充方向
)
```

#### insert

`insert`是一个用于在字符串中插入子字符串的函数，返回类型为`str`。

```
insert(
    str string, # 输入的字符串
    int index = 0, # 插入索引
    str subString # 插入的子字符串
)
```

#### shuffle

`shuffle`是一个用于将字符串中的字符随机打乱的函数，返回类型为`str`。

```
shuffle(
    str string, # 输入的字符串
    int seed = 0, # 随机种子
)
```

#### append

`append`是一个用于在字符串末尾添加子字符串的函数，返回类型为`str`。

```
append(
    str string, # 输入的字符串
    str subString # 添加的子字符串
)
```

#### removeSpChar

`removeSpChar`是一个用于从字符串中移除特殊字符的函数，返回类型为`str`。

```
removeSpChar(
    str string # 输入的字符串
)
```

#### removeAlpha

`removeAlpha`是一个用于从字符串中移除字母的函数，返回类型为`str`。

```
removeAlpha(
    str string # 输入的字符串
)
```

#### removeDigit

`removeDigit`是一个用于从字符串中移除数字的函数，返回类型为`str`。

```
removeDigit(
    str string # 输入的字符串
)
```

#### hasDigit

`hasDigit`是一个用于判断字符串中是否包含数字的函数，返回类型为`bool`。

```
hasDigit(
    str string # 输入的字符串
)
```

#### hasSp

`hasSp`是一个用于判断字符串中是否包含特殊字符的函数，返回类型为`bool`。\
特殊字符指`["!", "@", "#", "=", "%", "^", "&", "*"]`。

```
hasSp(
    str string # 输入的字符串
)
```

#### hasLower

`hasLower`是一个用于判断字符串中是否包含小写字母的函数，返回类型为`bool`。

```
hasLower(
    str string # 输入的字符串
)
```

#### hasUpper

`hasUpper`是一个用于判断字符串中是否包含大写字母的函数，返回类型为`bool`。

```
hasUpper(
    str string # 输入的字符串
)
```

#### insertRandDigit

`insertRandDigit`是一个用于在字符串中随机位置插入数字的函数，返回类型为`str`。\
随机性由`string`的sha256前7位ASCII码之和与`seed`共同决定，相同输入与种子产生相同结果。

```
insertRandDigit(
    str string, # 输入的字符串
    int amount = 1, # 插入数量
    int seed = 0 # 随机种子
)
```

#### insertRandSp

`insertRandSp`是一个用于在字符串中随机位置插入特殊字符的函数，返回类型为`str`。\
特殊字符取自`["!", "@", "#", "=", "%", "^", "&", "*"]`。

```
insertRandSp(
    str string, # 输入的字符串
    int amount = 1, # 插入数量
    int seed = 0 # 随机种子
)
```

#### insertRandLower

`insertRandLower`是一个用于在字符串中随机位置插入小写字母（a-z）的函数，返回类型为`str`。

```
insertRandLower(
    str string, # 输入的字符串
    int amount = 1, # 插入数量
    int seed = 0 # 随机种子
)
```

#### insertRandUpper

`insertRandUpper`是一个用于在字符串中随机位置插入大写字母（A-Z）的函数，返回类型为`str`。

```
insertRandUpper(
    str string, # 输入的字符串
    int amount = 1, # 插入数量
    int seed = 0 # 随机种子
)
```

### DSL结构

一个完整的配置DSL要求包含输入、处理和输出三部分，分别由三个代码块定义。

#### 输入

使用`GroupInput`定义输入变量，在此处定义的变量将在生成器运行前向用户请求输入，并在全过程中可用、不变（其他位置定义的变量可变）。\
需要显式声明变量类型，具体语法为`<类型> <变量名>: <显示名称> = <默认值>`，显示名称将在向用户请求输入时代替变量名，若变量未定义默认值，则用户必须输入该变量。\
`GroupInput`里有两个必须存在的变量，它们必须被声明，但不会要求用户输入，因为程序会自动处理它们。\
定义在此处的变量是全局变量，可以在处理代码块中使用。

```
GroupInput {
    str master: "主密码"; # 这个变量必须存在
    str seedString: "种子字符串"; # 这个变量必须存在
    int seed: "种子" = 0;
    int iterations: "迭代次数" = 100000;
}
```

#### 处理和输出

使用`Generate`定义处理和输出代码块，在此处可以使用输入变量进行处理，也可以使用其他函数进行处理。\
处理代码块中可以使用赋值运算符`=`对变量进行赋值，也可以使用其他函数进行处理。\
处理代码块中必须有且只能有一个`return`语句，用于返回最终的密码。\
定义在此处的变量是局部变量，只能在该代码块中使用。

```
Generate {
    str password = "";

    if(
        cond: iterations > 1000000,
        onTrue: raise("迭代次数不能超过1000000"),
        onFalse: pass
    );

    password = master + seedString;
    password = toBase64(string: password);
    # 在这里自由组装生成逻辑
    return password; # 输出的值被视为密码
    password = toPBKDF2(
        string: password, 
        iterations: iterations,
        salt: seedString
    ); # 这个语句不会执行，因为它在return之后
}
```

