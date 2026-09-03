import "package:passtateless/modules/core/logger.dart";
import "package:passtateless/modules/core/pwd_item.dart";
import "package:uuid/uuid.dart";

final _uuid = const Uuid();

/// 把旧版格式的密码字典展平，文件夹自动并入标签，没有UUID的自动补充
///
/// 转换规则：
/// - 输出为新版单层结构：每个条目都是独立字典，其中标签存放在 "tags" 数组中；
/// - 文件夹名会被并入条目的 "tags"（自动去重）；
/// - 空文件夹名（"" 等空白字符串，即旧版中未归类的记录）不会产生标签；
/// - 若旧条目里已经带有 "tags" 或 "tag" 字段，也会一并并入并去重；
/// - 缺少 "id" 的条目会自动补充 UUID v4。
List<Map<String, dynamic>> flattenPwdMap(
  Map<String, List<Map<String, dynamic>>> oldMap,
) {
  appLogger.logger.i("Converting old password map to newer password list");
  final List<String> keys = oldMap.keys.toList();
  final List<Map<String, dynamic>> converted = [];
  appLogger.logger.d(
    "All old password map keys: $keys, they will be turned to tags",
  );
  for (final String key in keys) {
    final items = oldMap[key] ?? const <Map<String, dynamic>>[];
    if (items.isEmpty) continue;
    appLogger.logger.d("Converting entries in folder $key");
    // 空白文件夹名表示"未归类"，不产生标签
    final String? folderTag = key.trim().isEmpty ? null : key;
    for (final item in items) {
      final tags = _collectTags(item, folderTag);
      final Map<String, dynamic> convertedItem = {
        "id": item["id"] as String? ?? _uuid.v4(),
        "identifier": item["identifier"] as String? ?? "",
        "userName": item["userName"] as String? ?? "",
        "account": item["account"] as String? ?? "",
        "starred": item["starred"] as bool? ?? false,
        "tags": tags,
      };
      converted.add(convertedItem);
    }
  }
  return converted;
}

/// 执行和`flattenPwdMap`相同的操作，然后将列表的内容从字典换成`PwdItem`
List<PwdItem> flattenAndGetItemList(
  Map<String, List<Map<String, dynamic>>> oldMap,
) {
  final mapList = flattenPwdMap(oldMap);
  return [for (final item in mapList) PwdItem.fromMap(item)];
}

/// 收集旧条目自身的标签并合并文件夹名，返回去重后的非空标签列表
List<String> _collectTags(Map<String, dynamic> item, String? folderTag) {
  final List<String> collected = [];
  final dynamic existingTags = item["tags"];
  if (existingTags is List) {
    for (final dynamic tag in existingTags) {
      if (tag is String && tag.trim().isNotEmpty) {
        collected.add(tag);
      }
    }
  }
  final dynamic existingTag = item["tag"];
  if (existingTag is String && existingTag.trim().isNotEmpty) {
    collected.add(existingTag);
  }
  if (folderTag != null) {
    collected.add(folderTag);
  }
  final List<String> uniqueTags = [];
  for (final String tag in collected) {
    if (!uniqueTags.contains(tag)) {
      uniqueTags.add(tag);
    }
  }
  return uniqueTags;
}
