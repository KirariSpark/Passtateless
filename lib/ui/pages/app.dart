import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/ui/pages/help/overview.dart';
import 'package:passtateless/ui/pages/pwd/home.dart';
import 'package:passtateless/ui/pages/settings/basic.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui ;
import 'package:passtateless/ui/pages/support/support_options.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:provider/provider.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Axis? _lastScrollDirection;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      if (appProvider.needChangeMaster) {
        appLogger.logger.w("Outdated master password detected");
        ui.showAlertDialogQuick(
          title: "主密码过期",
          content: Text("您的密码已超过设定的安全使用期限，为了您的信息安全，建议尽快更改主密码"),
          action: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          actionText: "确定",
          context: context
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final currentWidth = constraints.maxWidth;
        const int desktopWidth = 500;
        final currentAxis = currentWidth >= desktopWidth ? Axis.vertical : Axis.horizontal;

        void onNavigate(int index) {
          appProvider.currentIndex = index;
        }

        // 滚动方向改变时，重新布局前要做的事
        if (_lastScrollDirection != null && _lastScrollDirection != currentAxis) {
          appLogger.logger.d("Layout direction changed, recovering page index");
          appLogger.logger.d("Current direction is ${currentAxis.name}");
        }
        _lastScrollDirection = currentAxis;

        if (currentWidth < desktopWidth) {
          // 移动端：底部导航
          return Scaffold(
            body: SafeArea(child: _buildBodyContent(currentAxis, appProvider)),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
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
                BottomNavigationBarItem(
                  icon: Icon(Icons.coffee_outlined),
                  activeIcon: Icon(Icons.coffee),
                  label: "支持我",
                ),
              ],
              showUnselectedLabels: false,
              backgroundColor: ColorScheme.of(context).surfaceContainer,
            ),
          );
        } else {
          // 桌面/平板端：侧边栏
          return Scaffold(
            body: SafeArea(
              child: Row(
                children: [
                  NavigationRail(
                    scrollable: true,
                    indicatorShape: styles.roundedBorder,
                    selectedIndex: appProvider.currentIndex,
                    onDestinationSelected: onNavigate,
                    labelType: NavigationRailLabelType.all,
                    backgroundColor: ColorScheme.of(context).surfaceContainer,
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
                      NavigationRailDestination(
                        icon: Icon(Icons.coffee_outlined),
                        selectedIcon: Icon(Icons.coffee),
                        label: Text("支持我"),
                      ),
                    ],
                  ),
                  Expanded(child: _buildBodyContent(currentAxis, appProvider)),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildBodyContent(Axis scrollDirection, AppProvider appProvider) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: IndexedStack(
        key: ValueKey(appProvider.currentIndex),
        index: appProvider.currentIndex,
        children: [
          HomePage(),
          BasicSettingsPage(),
          HelpOverviewPage(),
          SupportOptionsPage()
        ],
      ),
    );
  }
}