import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../modules/utils/utils.dart' as utils;

// ————————Xorshift算法————————
/// Xorshift32算法实现
class Xorshift32 {
  int _state;

  Xorshift32(int seed) : _state = seed != 0 ? seed : 0x12345678;

  /// 生成下一个32位随机数
  int nextInt() {
    _state ^= _state << 13;
    _state ^= _state >> 17;
    _state ^= _state << 5;
    // 保持为32位无符号整数
    _state = _state & 0xFFFFFFFF;
    return _state;
  }

  /// 生成指定范围内的随机整数
  int nextIntRange(int min, int max) {
    if (min >= max) return min;
    int range = max - min;
    int randomValue = nextInt();
    return min + (randomValue % range);
  }
}

class Generator {
  String original;
  String password = "";
  bool spCharMissing = false;
  final List<String> specialChars = ["!", "@", "#", "=", "%", "^", "&", "*"];

  Generator(this.original);

  // ————————辅助方法————————
  /// 通过ASCII码生成字符（32-126为可打印字符）
  String _generateCharFromAscii(int asciiCode) {
    // 确保ASCII码在32-126范围内（可打印字符）
    if (asciiCode < 32) asciiCode = 32;
    if (asciiCode > 126) asciiCode = 126;
    return String.fromCharCode(asciiCode);
  }

  /// 计算当前密码的SHA256前7位字符的各自的ASCII码之和
  int _calculateSha256AsciiSum() {
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
    return sum;
  }

  // ————————检查类方法————————
  /// 检查输入是否合法
  int checkInput() {
    // 空
    if (original.isEmpty) {
      return 1;
    }
    // 有空格
    else if (original.contains(' ')) {
      return 2;
    }
    // 有字母和数字以外的字符
    else if (!RegExp(r'^[a-zA-Z0-9]*$').hasMatch(original)) {
      return 3;
    } else {
      return 0;
    }
  }

  /// 检查密码是否合法
  String checkPassword({int minLength = 8, int maxLength = 16}) {
    // 缺失：特殊字符
    spCharMissing = true;
    for (String i in specialChars) {
      if (password.contains(i)) {
        spCharMissing = false;
        break;
      }
    }

    if (password.isEmpty) {
      return "密码为空";
    } else if (password.contains(' ')) {
      return "密码包含空格";
    } else if (!(RegExp(r'[a-z]').hasMatch(password))) {
      return "密码缺失小写字母";
    } else if (!(RegExp(r'[A-Z]').hasMatch(password))) {
      return "密码缺失大写字母";
    } else if (!(RegExp(r'[0-9]').hasMatch(password))) {
      return "密码缺失数字";
    } else if (spCharMissing) {
      return "密码缺失特殊字符";
    } else if (password.length < minLength) {
      return "密码长度不足";
    } else if (password.length > maxLength) {
      return "密码太长";
    } else {
      return "";
    }
  }

  // ————————处理类方法————————
  /// 将字符串转为base64字符串
  void toBase64() {
    password = base64.encode(utf8.encode(password));
  }

  /// SHA256
  void toSHA256() {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    password = digest.toString();
  }

  /// 移除特殊字符
  void removeSpChar() {
    password = utils.removeSpChar(password);
  }

  /// 移除字母
  void removeAlpha() {
    password = utils.removeAlpha(password);
  }

  /// 移除数字
  void removeDigits() {
    password = utils.removeDigits(password);
  }

  // ————————密码类方法————————
  /// 反转密码
  void reverse() {
    password = password.split('').reversed.join('');
  }

  /// 截取密码
  void crop({int length = 16}) {
    if (password.length > length) {
      password = password.substring(0, length);
    }
  }

  /// 插入字符
  void insert(String inserted, int location) {
    // 空字符串
    if (inserted.isEmpty) {
      throw ArgumentError("插入的字符串为空");
    }
    // 包含空格
    else if (inserted.contains(' ')) {
      throw ArgumentError("插入的字符串包含空格");
    } else {
      if (password.isEmpty) {
        password = inserted;
        return;
      }
      int modLocation = location % password.length;
      password = password.substring(0, modLocation) +
          inserted +
          password.substring(modLocation);
    }
  }

  /// 从密码中间隔一定距离抽取字符
  void extract(int step, {int start = 0}) {
    if (step <= 0) {
      throw ArgumentError("步长必须大于 0");
    }
    if (start < 0 || start >= password.length) {
      throw ArgumentError("开始位置无效");
    }
    var result = <String>[];
    for (int i = start; i < password.length; i += step) {
      result.add(password[i]);
    }
    password = result.join('');
  }

  /// 旋转密码中的字符
  void rotate(int steps, {String direction = "left"}) {
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
  void repeat(int times) {
    password = password * times;
  }

  /// 去除密码中重复的字符
  void deduplicate() {
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
  void pad({int length = 16, String char = "A", String position = "end"}) {
    if (position == "start") {
      password = password.padLeft(length, char);
    } else if (position == "end") {
      password = password.padRight(length, char);
    }
  }

  /// 反转密码中的部分字符
  void reversePartial(int start, int end) {
    if (start < 0 || end > password.length || start > end) {
      throw ArgumentError("无效的开始或结束位置");
    }
    var partial = password.substring(start, end);
    password = password.substring(0, start) +
        partial.split('').reversed.join('') +
        password.substring(end);
  }

  /// 给密码追加字符
  void append(String appended) {
    // 空字符串
    if (appended == "") {
      throw ArgumentError("追加的字符串为空");
    }
    // 包含空格
    else if (appended.contains(' ')) {
      throw ArgumentError("追加的字符串包含空格");
    }
    // 被追加：是字符串
    else {
      password += appended;
    }
  }

  /// 将密码长度调整为指定的长度
  void adjustLength({int length = 16, String char = "A", String position = "end"}) {
    if (password.length > length) {
      crop(length: length);
    } else {
      pad(length: length, char: char, position: position);
    }
  }

  /// 随机插入数字
  void insertRandNum(int amount, {int seed = 0}) {
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
  void insertRandAlpha(int amount, {int seed = 0}) {
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
  void insertRandSp(int amount, {int seed = 0}) {
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
        password = password.substring(0, insertIndex) +
            randomSpChar +
            password.substring(insertIndex);
      }
    }
  }

  /// 随机打乱密码中的字符顺序
  void shuffle(int seed, int iterations) {
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
