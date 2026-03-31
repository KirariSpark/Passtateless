import 'package:flutter/material.dart';
import 'package:passtateless/modules/providers/doc_provider.dart';
import 'package:provider/provider.dart';

import 'modules/providers/app_provider.dart';
import 'modules/providers/config_provider.dart';
import 'modules/providers/pwd_provider.dart';
import 'ui/pages/generate.dart' as generate;
import 'ui/pages/help.dart' as help_tab;
import 'ui/pages/home.dart' as home_page;
import 'ui/styles.dart' as styles;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppProvider()),
        ChangeNotifierProvider(create: (context) => ConfigProvider()),
        ChangeNotifierProvider(create: (context) => PwdProvider()),
        ChangeNotifierProvider(create: (context) => DocProvider())
      ],
      child: MaterialApp(
        title: '密码生成器',
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
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final currentWidth = constraints.maxWidth;
        const int desktopWidth = 500;

        // --- 渲染逻辑 ---
        // 移动端：底部导航
        if (currentWidth < desktopWidth) {
          return Scaffold(
            body: _buildBodyContent(context, appProvider),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: appProvider.currentIndex,
              onTap: (index) {
                appProvider.currentIndex = index;
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: "主页",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.key_outlined),
                  activeIcon: Icon(Icons.key),
                  label: "生成",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.help_outline),
                  activeIcon: Icon(Icons.help),
                  label: "帮助",
                )
              ],
              showUnselectedLabels: false,
            ),
          );
        }

        // 桌面/平板端：侧边栏
        return Row(
          children: [
            NavigationRail(
              scrollable: true,
              indicatorShape: styles.roundedBorder,
              selectedIndex: appProvider.currentIndex,
              onDestinationSelected: (int index) {
                appProvider.currentIndex = index;
              },
              labelType: NavigationRailLabelType.all,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text("主页")
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.key_outlined),
                  selectedIcon: Icon(Icons.key),
                  label: Text("生成")
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.help_outline),
                  selectedIcon: Icon(Icons.help),
                  label: Text("帮助")
                )
              ]
            ),
            Expanded(child: Scaffold(body: _buildBodyContent(context, appProvider))),
          ],
        );
      },
    );
  }

  Widget _buildBodyContent(BuildContext context, AppProvider appProvider) {
    return IndexedStack(
      index: appProvider.currentIndex,
      children: const [
        home_page.HomePage(),
        generate.HomeTab(),
        help_tab.HelpPage(),
      ],
    );
  }
}