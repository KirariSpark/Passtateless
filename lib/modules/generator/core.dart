import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:passtateless/modules/utils/utils.dart' as utils;
import 'package:passtateless/modules/core/random.dart';

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

  // ————————公共方法————————
  /// 将字符串转为base64字符串
  void toBase64() {
    password = base64.encode(utf8.encode(original));
  }

  /// SHA256
  void toSHA256() {
    var bytes = utf8.encode(original);
    var digest = sha256.convert(bytes);
    password = digest.toString();
  }

  /// PBKDF2 (基于Hmac-SHA256)
  void toPBKDF2(String salt, [int iterations = 100]) {
    var hmac = Hmac(sha256, utf8.encode(original));
    var saltBytes = utf8.encode(salt);

    // 补充4字节的块索引（大端序，这里取第1块，刚好满足SHA256的32字节输出）
    var saltWithBlockIndex = Uint8List(saltBytes.length + 4);
    saltWithBlockIndex.setRange(0, saltBytes.length, saltBytes);
    var byteData = ByteData.view(saltWithBlockIndex.buffer, saltBytes.length, 4);
    byteData.setUint32(0, 1, Endian.big);

    // 计算 U1
    var u = hmac.convert(saltWithBlockIndex).bytes;
    var result = Uint8List.fromList(u);

    // 迭代计算 U2 到 Uc 并进行异或
    for (int i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (int j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }

    // 转为16进制字符串
    password = result.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
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

  /// 反转密码
  void reverse() {
    password = password.split('').reversed.join('');
  }

  /// 截取密码
  ///
  /// [length] 目标长度
  void crop([int length = 16]) {
    if (password.length > length) {
      password = password.substring(0, length);
    }
  }

  /// 插入字符
  ///
  /// [inserted] 要插入的字符
  /// [location] 插入位置
  void insert(String inserted, [int location = 0]) {
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
  ///
  /// [step] 间隔的距离
  /// [start] 第一个被抽取的字符位置
  void extract([int step = 1, int start = 0]) {
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
  ///
  /// [steps] 旋转的步数
  /// [direction] 旋转的方向，接受 left 或 right
  void rotate(int steps, [String direction = "left"]) {
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
  ///
  /// [length] 将密码填充到这个长度
  /// [char] 要填充的字符
  /// [position] 填充位置，接受 end 或 start
  void pad([int length = 16, String char = "A", String position = "end"]) {
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
  ///
  /// [appended] 要追加的字符
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
  ///
  /// [length] 目标长度
  /// [char] 若密码不够长，要填充的字符
  /// [position] 填充字符将填充的位置，接受 end 或 start
  void setLength([int length = 16, String char = "A", String position = "end"]) {
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
