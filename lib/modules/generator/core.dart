import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart' as cryptography;
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/core/random.dart';
import 'package:passtateless/modules/utils/utils.dart' as utils;

class Generator {
  String original;
  String password = "";
  bool spCharMissing = false;
  static const List<String> specialChars = ["!", "@", "#", "=", "%", "^", "&", "*"];

  Generator(this.original);

  // ————————辅助方法————————
  /// 通过ASCII码生成字符（32-126为可打印字符）
  String _generateCharFromAscii(int asciiCode) {
    // 确保ASCII码在32-126范围内（可打印字符）
    if (asciiCode < 32) asciiCode = 32;
    if (asciiCode > 126) asciiCode = 126;
    appLogger.logger.d("Generated char ${String.fromCharCode(asciiCode)} from ascii $asciiCode");
    return String.fromCharCode(asciiCode);
  }

  /// 计算当前密码的SHA256前7位字符的各自的ASCII码之和
  int _calculateSha256AsciiSum() {
    appLogger.logger.d("Calculating ascii sum for sha256 of current password (usually for seed)");

    if (password.isEmpty) return 0;

    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    String hashStr = digest.toString();

    // 截取前7位字符（SHA256结果肯定长于7位）
    String prefix = hashStr.substring(0, 7);

    int sum = 0;
    for (int i = 0; i < prefix.length; i++) {
      sum += prefix.codeUnitAt(i);
    }

    appLogger.logger.d("Sum: $sum");
    return sum;
  }

  // ————————公共方法————————
  /// 将字符串转为base64字符串
  void toBase64() {
    appLogger.logger.i("Converting $original to b64");
    password = base64.encode(utf8.encode(original));
    appLogger.logger.i("b64: $password");
  }

  /// SHA256
  void toSHA256() {
    appLogger.logger.i("Converting $original to sha256");
    var bytes = utf8.encode(original);
    var digest = sha256.convert(bytes);
    password = digest.toString();
    appLogger.logger.i("sha256: $password");
  }

  /// PBKDF2 (基于Hmac-SHA256)
  Future<void> toPBKDF2(String salt, [int iterations = 100]) async {
    appLogger.logger.i("Generating password using pbkdf2 with $iterations iterations");
    final pbkdf2 = cryptography.Pbkdf2(macAlgorithm: cryptography.Hmac.sha256(), iterations: iterations, bits: 256);
    final newSecretKey = await pbkdf2.deriveKeyFromPassword(password: password, nonce: utf8.encode(salt));
    final secretKeyBytes = await newSecretKey.extractBytes();
    List<int> finalBytes = [];
    for (var item in secretKeyBytes) {
      finalBytes.add((item % 93) + 33);
    }
    password = ascii.decode(finalBytes, allowInvalid: true);
    appLogger.logger.i("Password generated");
  }

  /// 移除特殊字符
  void removeSpChar() {
    appLogger.logger.i("Removing special chars from password");
    password = utils.removeSpChar(password);
  }

  /// 移除字母
  void removeAlpha() {
    appLogger.logger.i("Removing alphabets from password");
    password = utils.removeAlpha(password);
  }

  /// 移除数字
  void removeDigits() {
    appLogger.logger.i("Removing digits from password");
    password = utils.removeDigits(password);
  }

  /// 反转密码
  void reverse() {
    appLogger.logger.i("Reversing password");
    password = password.split('').reversed.join('');
  }

  /// 截取密码
  ///
  /// [length] 目标长度
  void crop([int length = 16]) {
    appLogger.logger.i("Cropping password to length $length");
    if (password.length > length) {
      password = password.substring(0, length);
    }
  }

  /// 插入字符
  ///
  /// [inserted] 要插入的字符
  /// [location] 插入位置
  void insert(String inserted, [int location = 0]) {
    appLogger.logger.i("Inserting $inserted to location $location");
    // 空字符串
    if (inserted.isEmpty) {
      appLogger.logger.e("Empty inserted string");
      throw ArgumentError("插入的字符串为空");
    }
    // 包含空格
    else if (inserted.contains(' ')) {
      appLogger.logger.e("Spacing(' ') detected");
      throw ArgumentError("插入的字符串包含空格");
    } else {
      if (password.isEmpty) {
        password = inserted;
        return;
      }
      int modLocation = location % password.length;
      password = password.substring(0, modLocation) + inserted + password.substring(modLocation);
    }
  }

  /// 从密码中间隔一定距离抽取字符
  ///
  /// [step] 间隔的距离
  /// [start] 第一个被抽取的字符位置
  void extract([int step = 1, int start = 0]) {
    appLogger.logger.i("Extracting characters from password (starting from $start with step $step)");
    if (step <= 0) {
      appLogger.logger.e("Step not larger than 0");
      throw ArgumentError("步长必须大于 0");
    }
    if (start < 0 || start >= password.length) {
      appLogger.logger.e("Invalid start position");
      throw ArgumentError("开始位置无效");
    }
    var result = <String>[];
    for (int i = start; i < password.length; i += step) {
      result.add(password[i]);
    }
    password = result.join('');
  }

  /// 旋转密码中的字符
  ///
  /// [steps] 旋转的步数
  /// [direction] 旋转的方向，接受 left 或 right
  void rotate(int steps, [String direction = "left"]) {
    appLogger.logger.i("Rotating characters to direction $direction with $steps steps");
    if (password.isEmpty) return;
    int effectiveSteps = steps % password.length;
    if (effectiveSteps == 0) return;

    if (direction == "left") {
      password = password.substring(effectiveSteps) +
          password.substring(0, effectiveSteps);
    } else if (direction == "right") {
      password = password.substring(password.length - effectiveSteps) +
          password.substring(0, password.length - effectiveSteps);
    }
  }

  /// 将密码重复指定的次数
  ///
  /// [times] 重复次数
  void repeat([int times = 1]) {
    appLogger.logger.i("Repeating password $times times");
    password = password * times;
  }

  /// 去除密码中重复的字符
  void deduplicate() {
    appLogger.logger.i("Deduplicating password");
    var seen = <String>{};
    var result = <String>[];
    for (var char in password.split('')) {
      if (seen.add(char)) {
        result.add(char);
      }
    }
    password = result.join('');
  }

  /// 在密码的开头或结尾填充指定的字符
  ///
  /// [length] 将密码填充到这个长度
  /// [char] 要填充的字符
  /// [position] 填充位置，接受 end 或 start
  void pad([int length = 16, String char = "A", String position = "end"]) {
    appLogger.logger.i("Padding password to length $length using char $char with position $position");
    if (position == "start") {
      password = password.padLeft(length, char);
    } else if (position == "end") {
      password = password.padRight(length, char);
    }
  }

  /// 反转密码中的部分字符
  void reversePartial(int start, int end) {
    appLogger.logger.i("Reversing password partially (from $start to $end)");
    if (start < 0 || end > password.length || start > end) {
      appLogger.logger.i("Invalid start or end position");
      throw ArgumentError("无效的开始或结束位置");
    }
    var partial = password.substring(start, end);
    password = password.substring(0, start) +
        partial.split('').reversed.join('') +
        password.substring(end);
  }

  /// 给密码追加字符
  ///
  /// [appended] 要追加的字符
  void append(String appended) {
    appLogger.logger.i("Appending character $appended to password");
    // 空字符串
    if (appended == "") {
      appLogger.logger.e("Empty appended string");
      throw ArgumentError("追加的字符串为空");
    }
    // 包含空格
    else if (appended.contains(' ')) {
      appLogger.logger.e("Spacing(' ') detected");
      throw ArgumentError("追加的字符串包含空格");
    }
    else {
      password += appended;
    }
  }

  /// 将密码长度调整为指定的长度
  ///
  /// [length] 目标长度
  /// [char] 若密码不够长，要填充的字符
  /// [position] 填充字符将填充的位置，接受 end 或 start
  void setLength([int length = 16, String char = "A", String position = "end"]) {
    appLogger.logger.i("Setting length of password to $length using padding char $char at position $position");
    if (password.length > length) {
      crop(length);
    } else {
      pad(length, char, position);
    }
  }

  /// 随机插入数字
  ///
  /// [amount] 插入数量
  /// [seed] 种子
  void insertRandDigit([int amount = 1, int seed = 0]) {
    appLogger.logger.i("Inserting $amount random digits using seed offset $seed");
    if (amount <= 0) return;

    int baseSeed = _calculateSha256AsciiSum();
    var random = Xorshift32(baseSeed + seed);

    for (int i = 0; i < amount; i++) {
      if (password.isEmpty) {
        // 生成ASCII码48-57之间的数字字符
        int asciiCode = 48 + (random.nextInt() % 10);
        password = _generateCharFromAscii(asciiCode);
      } else {
        // 生成插入位置
        int insertIndex = random.nextIntRange(0, password.length + 1);
        // 生成ASCII码48-57之间的数字字符
        int asciiCode = 48 + (random.nextInt() % 10);
        String randomDigit = _generateCharFromAscii(asciiCode);
        password = password.substring(0, insertIndex) +
            randomDigit +
            password.substring(insertIndex);
      }
    }
  }

  /// 随机插入字母
  ///
  /// [amount] 插入数量
  /// [seed] 种子
  void insertRandAlpha([int amount = 1, int seed = 0]) {
    appLogger.logger.i("Inserting $amount random alphabets using seed offset $seed");
    if (amount <= 0) return;

    int baseSeed = _calculateSha256AsciiSum();
    var random = Xorshift32(baseSeed + seed);

    for (int i = 0; i < amount; i++) {
      if (password.isEmpty) {
        // 随机选择大写或小写字母
        int letterType = random.nextInt() % 2;
        int asciiCode;
        if (letterType == 0) {
          asciiCode = 65 + (random.nextInt() % 26); // A-Z
        } else {
          asciiCode = 97 + (random.nextInt() % 26); // a-z
        }
        password = _generateCharFromAscii(asciiCode);
      } else {
        // 生成插入位置
        int insertIndex = random.nextIntRange(0, password.length + 1);
        // 随机选择大写或小写字母
        int letterType = random.nextInt() % 2;
        int asciiCode;
        if (letterType == 0) {
          asciiCode = 65 + (random.nextInt() % 26); // A-Z
        } else {
          asciiCode = 97 + (random.nextInt() % 26); // a-z
        }
        String randomAlpha = _generateCharFromAscii(asciiCode);
        password = password.substring(0, insertIndex) +
            randomAlpha +
            password.substring(insertIndex);
      }
    }
  }

  /// 随机插入特殊字符
  ///
  /// [amount] 插入数量
  /// [seed] 种子
  void insertRandSp([int amount = 1, int seed = 0]) {
    appLogger.logger.i("Inserting $amount random special characters using seed offset $seed");
    if (amount <= 0) return;

    int baseSeed = _calculateSha256AsciiSum();
    var random = Xorshift32(baseSeed + seed);

    for (int i = 0; i < amount; i++) {
      if (password.isEmpty) {
        // 从特殊字符列表中随机选择一个
        int spIndex = random.nextInt() % specialChars.length;
        password = specialChars[spIndex];
      } else {
        // 生成插入位置
        int insertIndex = random.nextIntRange(0, password.length + 1);
        // 从特殊字符列表中随机选择一个
        int spIndex = random.nextInt() % specialChars.length;
        String randomSpChar = specialChars[spIndex];
        password = password.substring(0, insertIndex) + randomSpChar + password.substring(insertIndex);
      }
    }
  }

  /// 随机打乱密码中的字符顺序
  ///
  /// [iterations] 打乱次数
  /// [seed] 种子
  void shuffle([int iterations = 10, int seed = 0]) {
    appLogger.logger.i("Shuffling password using seed offset $seed with $iterations iterations");
    if (password.isEmpty || iterations <= 0) return;

    int baseSeed = _calculateSha256AsciiSum();
    var random = Xorshift32(baseSeed + seed);

    for (int i = 0; i < iterations; i++) {
      if (password.length <= 1) {
        return;
      }

      // 生成两个不同的随机位置
      int index1 = random.nextIntRange(0, password.length);
      int index2 = random.nextIntRange(0, password.length - 1);
      if (index2 >= index1) {
        index2++;
      }

      String char = password[index1];

      // 打乱
      String beforeIndex1 = password.substring(0, index1);
      String afterIndex1 = password.substring(index1 + 1);
      String tempPassword = beforeIndex1 + afterIndex1;
      String beforeIndex2 = tempPassword.substring(0, index2);
      String afterIndex2 = tempPassword.substring(index2);
      password = beforeIndex2 + char + afterIndex2;

      // 重新计算种子
      if (i < iterations - 1) {
        baseSeed = _calculateSha256AsciiSum();
        random = Xorshift32(baseSeed + seed);
      }
    }
  }
}
