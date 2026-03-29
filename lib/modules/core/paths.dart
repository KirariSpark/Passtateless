enum Paths {
  pwdRecord("saved_pwds.bin");

  final String path;

  const Paths(this.path);

  @override
  String toString() => path;
}
