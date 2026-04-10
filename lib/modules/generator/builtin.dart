List<Map<String, dynamic>> simple = [
  {"name": "toBase64"},
  {"name": "insertRandDigit", "args": [3]},
  {"name": "insertRandSp", "args": [2]},
  {"name": "insertRandAlpha", "args": [2]},
  {"name": "crop", "args": [12]}
];

List<Map<String, dynamic>> complex = [
  {"name": "toBase64"},
  {"name": "toSHA256"},
  {"name": "toPBKDF2", "args": ["#password", 100000]},
  {"name": "reverse"},
  {"name": "extract", "args": [2, 1]},
  {"name": "insertRandDigit", "args": [10, 42]},
  {"name": "insertRandSp", "args": [10, 42]},
  {"name": "insertRandAlpha", "args": [10, 42]},
  {"name": "setLength", "args": [16, "X", "end"]}
];

List<Map<String, dynamic>> bank = [
  {"name": "toBase64"},
  {"name": "toSHA256"},
  {"name": "toPBKDF2", "args": ["#password", 100000]},
  {"name": "rotate", "args": [5, "right"]},
  {"name": "extract", "args": [3, 0]},
  {"name": "toSHA256"},
  {"name": "removeAlpha"},
  {"name": "removeSpChar"},
  {"name": "setLength", "args": [6, "0", "end"]}
];
