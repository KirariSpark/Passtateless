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
