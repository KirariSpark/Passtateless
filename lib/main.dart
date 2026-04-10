import 'package:flutter/material.dart';
import 'package:passtateless/modules/providers/doc_provider.dart';
import 'package:provider/provider.dart';

import 'modules/providers/app_provider.dart';
import 'modules/providers/pwd_provider.dart';
import 'ui/pages/splash.dart';

void main() {
  runApp(const Passtateless());
}

class Passtateless extends StatelessWidget {
  const Passtateless({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppProvider()),
        ChangeNotifierProvider(create: (context) => PwdProvider()),
        ChangeNotifierProvider(create: (context) => DocProvider()),
      ],
      child: MaterialApp(
        title: 'Passtateless',
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
        home: const SplashPage(),
      ),
    );
  }
}
