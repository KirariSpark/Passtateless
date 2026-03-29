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