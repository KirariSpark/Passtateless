import 'package:flutter/material.dart';

enum Paths {
  pwdRecord("saved_pwds.bin");

  final String path;

  const Paths(this.path);

  @override
  String toString() => path;
}

enum Presets {
  simple("simple", "简易"),
  complex("complex", "复杂"),
  bank("bank", "支付密码"),
  custom("custom", "自定义");

  final String preset;
  final String displayName;

  const Presets(this.preset, this.displayName);
}

enum RemindDays {
  days60('60', '60天'),
  days90('90', '90天'),
  days180('180', '180天'),
  never('0', '关闭');

  final String value;
  final String displayName;
  const RemindDays(this.value, this.displayName);
}

enum AvailableColors {
  deepPurple(Colors.purple, "紫色"),
  indigo(Colors.indigo, "靛蓝"),
  blueGrey(Colors.blue, "蓝色"),
  teal(Colors.teal, "暗青"),
  greed(Colors.lightGreen, "浅绿"),
  amber(Colors.yellow, "黄色"),
  orange(Colors.orange, "橙色"),
  red(Colors.red, "红色");

  final MaterialColor color;
  final String name;
  const AvailableColors(this.color, this.name);
}