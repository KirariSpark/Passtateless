import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'modules/core/logger.dart';
import 'modules/providers/app_provider.dart';
import 'modules/providers/pwd_provider.dart';
import 'ui/pages/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appLogger.init();
  appLogger.logger.i("Starting app");
  final appProvider = AppProvider();
  await appProvider.readConfig();
  runApp(Passtateless(appProvider: appProvider));
}

class Passtateless extends StatelessWidget {
  const Passtateless({super.key, required this.appProvider});

  final AppProvider appProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appProvider),
        ChangeNotifierProvider(create: (context) => PwdProvider())
      ],
      child: _AppContent()
    );
  }
}

class _AppContent extends StatelessWidget {
  const _AppContent();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Passtateless',
      theme: ThemeData(
        colorScheme: context.watch<AppProvider>().colorScheme,
        useMaterial3: true,
        fontFamily: 'SourceHans',
      ),
      darkTheme: ThemeData(
        colorScheme: context.watch<AppProvider>().darkColorScheme,
        useMaterial3: true,
        fontFamily: 'SourceHans',
      ),
      themeMode: ThemeMode.system,
      home: const MainApp(),
    );
  }
}
