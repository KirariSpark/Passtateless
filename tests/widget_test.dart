import 'package:passtateless/widgets/quick_options.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        body: HomePageQuickOptions(
          onEditTapped: (){},
          onBasicTapped: (){},
          onAdvancedTapped: (){},
        ),
      ),
    );
  }
}