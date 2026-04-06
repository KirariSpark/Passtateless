import 'package:flutter/material.dart';
import 'package:passtateless/modules/providers/doc_provider.dart';
import 'package:provider/provider.dart';
import 'modules/providers/app_provider.dart';
import 'modules/providers/pwd_provider.dart';
import 'ui/pages/help.dart' as help_tab;
import 'ui/pages/home.dart' as home_page;
import 'ui/pages/basic_settings.dart';
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
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueGrey,
            brightness: Brightness.dark,
          ),
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
  Axis? _lastScrollDirection;

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final currentWidth = constraints.maxWidth;
        const int desktopWidth = 500;
        final currentAxis = currentWidth >= desktopWidth
            ? Axis.vertical
            : Axis.horizontal;

        void onNavigate(int index) {
          appProvider.currentIndex = index;
          appProvider.pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }

        // 当滚动方向发生改变时，安排一个帧后回调来恢复页面索引
        if (_lastScrollDirection != null &&
            _lastScrollDirection != currentAxis) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (appProvider.pageController.hasClients) {
              appProvider.pageController.animateToPage(
                appProvider.currentIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
              );
            }
          });
        }
        _lastScrollDirection = currentAxis;

        if (currentWidth < desktopWidth) {
          // 移动端：底部导航
          return Scaffold(
            body: _buildBodyContent(currentAxis, appProvider),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: appProvider.currentIndex,
              onTap: onNavigate,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: "主页",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings),
                  label: "设置",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.help_outline),
                  activeIcon: Icon(Icons.help),
                  label: "帮助",
                ),
              ],
              showUnselectedLabels: false,
              elevation: 20,
            ),
          );
        } else {
          // 桌面/平板端：侧边栏
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  scrollable: true,
                  indicatorShape: styles.roundedBorder,
                  selectedIndex: appProvider.currentIndex,
                  onDestinationSelected: onNavigate,
                  labelType: NavigationRailLabelType.all,
                  elevation: 3,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text("主页"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text("设置"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.help_outline),
                      selectedIcon: Icon(Icons.help),
                      label: Text("帮助"),
                    ),
                  ],
                ),
                Expanded(child: _buildBodyContent(currentAxis, appProvider)),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildBodyContent(Axis scrollDirection, AppProvider appProvider) {
    return PageView(
      key: ValueKey(scrollDirection),
      controller: appProvider.pageController,
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: scrollDirection,
      children: [
        home_page.HomePage(),
        BasicSettingsPage(),
        help_tab.HelpPage(),
      ],
    );
  }
}
