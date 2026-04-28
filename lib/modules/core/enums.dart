import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

enum Paths {
  pwdRecord("saved_pwds.bin"),
  config("config.json"),
  masterPwdLabel("masterPwdChanged.txt"),
  log("log.log");

  final String path;
  const Paths(this.path);

  @override
  String toString() => path;
}

enum Presets {
  simple("simple", "简易", "简易预设，适用于对安全性要求不高的场景"),
  complex("complex", "复杂", "使用更复杂的生成流程和 PBKDF2 算法，可能较慢"),
  bank("bank", "支付密码", "基于 PBKDF2 算法生成六位的纯数字密码，可能较慢"),
  custom("custom", "自定义", "使用 JSON 完全自定义整个生成流程");

  final String preset;
  final String displayName;
  final String desc;

  const Presets(this.preset, this.displayName, this.desc);
}

enum RemindDays {
  debugAlways(Duration(milliseconds: 0), "每次启动"),
  days60(Duration(days: 60), '每 60 天'),
  days90(Duration(days: 90), '每 90 天'),
  days180(Duration(days: 180), '每 180 天'),
  never(Duration(days: 2147483647), '从不');

  final Duration value;
  final String displayName;
  const RemindDays(this.value, this.displayName);
}

enum AvailableColors {
  deepPurple(Colors.deepPurple, "深紫"),
  indigo(Colors.indigo, "靛蓝"),
  blueGrey(Colors.blue, "蓝色"),
  cyan(Colors.cyan, "青色"),
  teal(Colors.teal, "暗青"),
  green(Colors.lightGreen, "浅绿"),
  amber(Colors.yellow, "黄色"),
  orange(Colors.orange, "橙色"),
  red(Colors.red, "红色");

  final Color color;
  final String displayName;
  const AvailableColors(this.color, this.displayName);
}

enum NavigatorMode {
  material("Material（安卓）"),
  cupertino("Cupertino（苹果）");

  final String displayName;

  const NavigatorMode(this.displayName);
}

enum AnimationDilation {
  fastest(0.1, "♿♿♿"),
  veryFast(0.5, "极快"),
  fast(0.75, "快速"),
  normal(1, "标准"),
  slow(1.5, "慢速"),
  verySlow(2, "极慢"),
  slowest(10, "🐌🐌🐌");

  final double dilation;
  final String displayName;

  const AnimationDilation(this.dilation, this.displayName);
}

enum LogLevels {
  debug("调试", Level.debug),
  info("信息", Level.info),
  warning("警告", Level.warning),
  error("错误", Level.error);

  final String displayName;
  final Level lvl;

  const LogLevels(this.displayName, this.lvl);
}

enum ContrastLevels {
  veryLow(-0.7, "低"),
  low(-0.3, "较低"),
  normal(0, "普通"),
  high(0.3, "较高"),
  veryHigh(0.7, "高");

  final double contrast;
  final String displayName;

  const ContrastLevels(this.contrast, this.displayName);
}