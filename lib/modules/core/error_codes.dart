enum ErrorCode {
  success(0, "操作 {item} 成功完成", "操作成功完成"),
  unknown(1, "未知错误：{item}", "未知错误"),
  emptyString(2, "输入包含空字符串", ""),
  jsonFormatError(3, "JSON 格式错误", ""),
  cannotReadFile(4, "无法读取文件：{item}", "无法读取文件"),
  cannotWriteFile(5, "无法写入文件：{item}", "无法写入文件"),
  emptyList(6, "输入列表为空", ""),
  fileNotExist(7, "文件 {item} 不存在", "请求的文件不存在"),
  jsonDecError(8, "无法解析 JSON 文件：{item}", "无法解析 JSON 文件"),
  userInterrupt(11, "{item} 已被用户终止", "操作已被用户终止"),
  cannotMakeDir(18, "无法创建文件夹：{item}", "无法创建需要的文件夹"),
  notPermitted(19, "权限不足以完成对 {item} 的操作", "没有足够的权限完成所需操作"),
  invalidArgument(22, "无效的参数：{item}", "检测到无效参数");

  final int code;
  final String _messageTemplate;
  final String? _rawGenericMsg;

  const ErrorCode(this.code, this._messageTemplate, [this._rawGenericMsg]);

  /// 无法格式化时的通用消息
  String get generic {
    return (_rawGenericMsg == null || _rawGenericMsg.isEmpty)
        ? _messageTemplate
        : _rawGenericMsg;
  }

  /// 格式化
  String format([String msg = ""]) {
    return _messageTemplate.replaceAll('{item}', msg);
  }

  @override
  String toString() {
    return "[$code] $generic";
  }
}
