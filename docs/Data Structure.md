### 单个密码条目字典结构

```json
{
  "identifier": "用于标识这一密码条目的名称，显示给用户看",
  "userName": "用户名，也可以是其他用于标识唯一的账号的信息",
  "platform": "当前密码用于的平台",
  "preset": "生成使用的预设，可能是simple、complex、bank或custom",
  "removeSp": true,
  "removeDigits": true,
  "removeAlpha": true,
  "starred": false
}
```

后三个`remove`分别为是否移除特殊字符、数字和字母的标记。  
`custom`预设不会存储生成配置。  
`starred`标记该配置是否被收藏。