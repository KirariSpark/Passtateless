enum ErrorCode {
  success(0, "操作 {item} 成功完成", "操作成功完成"),
  unknown(1, "未知错误：{item}", "未知错误"),
  emptyString(2, "输入包含空字符串"),
  jsonFormatError(3, "JSON 格式错误"),
  jsonDecError(4, "无法解析 JSON 文件：{item}", "无法解析 JSON 文件"),
  fileNotExist(5, "文件 {item} 不存在", "请求的文件不存在"),
  decryptionFailed(6, "无法解密文件 {item}", "无法解密文件"),
  unknownCommand(7, "输入包含未知命令"),
  invalidArgs(8, "输入包含无效参数"),
  generateFailed(9, "无法生成满足要求的密码");

  final int code;
  final String _messageTemplate;
  final String? _rawGenericMsg;

  const ErrorCode(this.code, this._messageTemplate, [this._rawGenericMsg]);

  /// 无法格式化时的通用消息
  String get generic => (_rawGenericMsg == null) ? _messageTemplate : _rawGenericMsg;

  /// 格式化
  String format([String msg = ""]) {
    return _messageTemplate.replaceAll('{item}', msg);
  }

  @override
  String toString() {
    return "[$code] $generic";
  }
}
