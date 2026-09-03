import 'package:uuid/uuid.dart';

/// 单个密码记录的类
class PwdItem {
  /// 这个记录的UUID，私有，只能通过 [id] getter 读取，
  /// 或通过 [isMe] 方法与传入的 id 进行比较
  final String _id;

  String identifier;
  String account;
  String userName;
  bool starred;
  List<String> tags;

  /// 获取这个记录的UUID
  String get id => _id;

  /// 判断传入的 [otherId] 是否就是这个记录的 id
  bool isMe(String otherId) => _id == otherId;

  /// 记录一个密码
  ///
  /// 技术上来说，id以外的字符串参数随便填什么都行，注释只用于解释其设计用途
  ///
  /// [id] 即UUID，用于标识这个记录</br>
  /// [identifier] 一个可读的名称，相当于文件名的功能</br>
  /// [account] 这个密码所记录的账号所在的平台，例如：google.com</br>
  /// [userName] 这个密码所记录的账号的名称</br>
  /// [starred] 这个密码是否被添加了星标</br>
  /// [tags] 这个密码被加上的标签，标签都是字符串
  PwdItem({
    required String id,
    this.identifier = "",
    this.account = "",
    this.userName = "",
    this.starred = false,
    this.tags = const [],
  }) : _id = id;

  /// 将这个记录变成一个字典，方便序列化
  Map<String, dynamic> toMap() {
    return {
      "id": _id,
      "identifier": identifier,
      "userName": userName,
      "account": account,
      "starred": starred,
      "tags": tags
    };
  }

  /// 从字典恢复一个记录，字典格式要求可参考文档 ./docs/Data Structure.md
  ///
  /// 不要求字典中有 "id" 键，若缺失则自动生成一个 UUID V4。
  factory PwdItem.fromMap(Map<String, dynamic> map) {
    return PwdItem(
      id: map["id"] as String? ?? const Uuid().v4(),
      identifier: map["identifier"] as String? ?? "",
      account: map["account"] as String? ?? "",
      userName: map["userName"] as String? ?? "",
      starred: map["starred"] as bool? ?? false,
      tags: (map["tags"] as List?)?.whereType<String>().toList() ?? const [],
    );
  }
}
