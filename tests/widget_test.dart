import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/ui/widgets/eval_res.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:zxcvbn/zxcvbn.dart';

void main() {
  // debugPaintSizeEnabled = true;
  runApp(TestApp());
}

class TestApp extends StatefulWidget {
  const TestApp({super.key});

  @override
  State<TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PwdProvider(),
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
          useMaterial3: true,
          fontFamily: 'SourceHans',
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey, brightness: Brightness.dark),
          useMaterial3: true,
          fontFamily: 'SourceHans',
        ),
        themeMode: ThemeMode.system,
        home: Scaffold(
          body: EvalRes(
            evalRes: Zxcvbn().evaluate("i am using this as password come fight me lol")
          )
        ),
      ),
    );
  }
}