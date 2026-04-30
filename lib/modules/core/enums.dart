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

enum DocItems {
  basic("基本信息", "basic", "本软件的介绍", "assets/docs/basic.md"),
  getStarted("开始使用", "get_started", "查看此文档以快速上手", "assets/docs/get_started.md"),
  faq("常见问题", "faq", "你可能会遇到的问题", "assets/docs/faq.md"),
  jsonBasic("JSON 基础", "json_basic", "了解基础的 JSON 语法", "assets/docs/json_basic.md"),
  cfg("配置生成器", "cfg", "了解生成器的功能及其参数", "assets/docs/cfg.md"),
  cfgTips("生成器提示", "cfg_tips", "在配置生成器时，你应该注意的一些事情", "assets/docs/cfg_tips.md"),
  features("特色功能", "features", "Passtateless 的特殊功能", "assets/docs/features.md"),
  importExport("导入导出", "import_export", "备份、恢复和分享你的数据", "assets/docs/import_export.md");


  final String displayName;
  final String mode;
  final String desc;
  final String path;

  const DocItems(this.displayName, this.mode, this.desc, this.path);
}

const List<DocItems> editorHelpItems = [DocItems.jsonBasic, DocItems.cfg, DocItems.cfgTips];