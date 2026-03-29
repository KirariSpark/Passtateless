### 单个密码条目字典结构

```json
{
  "identifier": "用于标识这一密码条目的名称，显示给用户看",
  "userName": "用户名，也可以是其他用于标识唯一的账号的信息",
  "account": "当前密码对应的账号",
  "preset": "生成使用的预设，可能是simple、complex、bank或custom",
  "custom": "[自定义模式下的生成配置]",
  "removeSp": true,
  "removeDigits": true,
  "removeAlpha": true,
  "starred": false
}
```

后三个`remove`分别为是否移除特殊字符、数字和字母的标记。
`starred`标记该配置是否被收藏。

### 生成配置条目结构

```json
[
  {
    "name": "第一个操作的名称",
    "args": ["第一个操作的参数"]
  },
  {
    "name": "第二个操作的名称",
    "args": ["第二个操作的参数"]
  },
  {
    "name": "第三个操作的名称"
  }
]
```

若没有参数，可以不传`args`