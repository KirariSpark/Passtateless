import "package:passtateless/modules/core/logger.dart";
import "package:uuid/uuid.dart";

/// 把旧版格式的密码字典展平，文件夹自动并入标签
List<Map<String, dynamic>> flattenPwdMap(
  Map<String, List<Map<String, dynamic>>> oldMap,
) {
  appLogger.logger.i("Converting old password map to newer password list");
  List<String> keys = oldMap.keys.toList();
  List<Map<String, dynamic>> converted = [];
  appLogger.logger.d("All old password map keys: $keys, they will be turned to tags");
  for (final String key in keys) {
    appLogger.logger.d("Converting entries in folder $key");
    if (oldMap[key] != null) {
      for (Map item in oldMap[key]!) {
        Map<String, dynamic> convertedItem = {
          "id": item["id"] as String? ?? const Uuid().v4(),
          "identifier": item["identifier"] as String? ?? "",
          "account": item["account"] as String? ?? "",
          "userName": item["userName"] as String? ?? "",
          "starred": item["starred"] as bool? ?? false,
          "tag": key
        };
        converted.add(convertedItem);
      }
    }
  }
  return converted;
}
