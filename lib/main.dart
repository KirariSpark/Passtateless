import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_provider.dart';
import 'providers/config_provider.dart';
import 'pages/generate.dart' as generate;
import 'pages/generate_config.dart' as generate_config;
import 'pages/correction_config.dart' as correction_config;
import 'pages/help_tab.dart' as help_tab;
import 'widgets/uni_styles.dart' as styles;

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
        ChangeNotifierProvider(create: (context) => ConfigProvider())
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
  bool _isRailExtended = false;
  double? _previousMaxWidth;

  final List<_Destination> _destinations = const [
    _Destination(Icons.password, '生成'),
    _Destination(Icons.settings, '生成配置'),
    _Destination(Icons.published_with_changes_rounded, '输入矫正'),
    _Destination(Icons.help_outline, '帮助'),
  ];

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final currentWidth = constraints.maxWidth;
        final prevWidth = _previousMaxWidth ?? 0;
        const int desktopWideWidth = 800;
        const int desktopNarrowWidth = 500;
        bool needsUpdate = false;

        // 是否跨越了桌面宽屏宽度
        final crossedDesktopWide =
            (prevWidth < desktopWideWidth) != (currentWidth < desktopWideWidth);
        if (crossedDesktopWide) {
          // 如果当前变宽了，则展开；否则收起
          final isEnteringWide = currentWidth >= desktopWideWidth;
          if (_isRailExtended != isEnteringWide) {
            _isRailExtended = isEnteringWide;
            needsUpdate = true;
          }
        }

        // 是否跨越了桌面窄屏宽度
        // 仅当从更窄进入时，确保收起
        final crossedDesktopNarrow = (prevWidth < desktopNarrowWidth) !=
            (currentWidth < desktopNarrowWidth);
        if (crossedDesktopNarrow &&
            currentWidth >= desktopNarrowWidth &&
            currentWidth < desktopWideWidth) {
          if (_isRailExtended) {
            _isRailExtended = false;
            needsUpdate = true;
          }
        }

        // 更新记录的宽度
        _previousMaxWidth = currentWidth;

        // 如果状态发生了改变，请求重绘
        if (needsUpdate) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {});
            }
          });
        }

        // --- 渲染逻辑 ---
        // 移动端：底部导航
        if (currentWidth < desktopNarrowWidth) {
          return Scaffold(
            body: _buildBodyContent(context, appProvider),
            bottomNavigationBar: NavigationBar(
              selectedIndex: appProvider.currentIndex,
              onDestinationSelected: (int index) {
                appProvider.currentIndex = index;
              },
              destinations: _destinations
                  .map((d) => NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.icon),
                label: d.label,
              ))
                  .toList(),
            ),
          );
        }

        // 桌面/平板端：侧边栏
        return Row(
          children: [
            NavigationRail(
              scrollable: true,
              selectedIndex: appProvider.currentIndex,
              onDestinationSelected: (int index) {
                appProvider.currentIndex = index;
              },
              extended: _isRailExtended,
              // 上部
              leading: IconButton(
                style: styles.uniButtonStyle,
                onPressed: () {
                  setState(() {
                    _isRailExtended = !_isRailExtended;
                  });
                },
                icon: const Icon(Icons.menu_rounded),
              ),
              // 导航
              destinations: _destinations
                  .map((d) => NavigationRailDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.icon),
                label: Text(d.label, style: theme.textTheme.bodyMedium),
              )).toList(),
            ),
            Expanded(
              child: Scaffold(
                body: _buildBodyContent(context, appProvider),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBodyContent(BuildContext context, AppProvider appProvider) {
    return IndexedStack(
      index: appProvider.currentIndex,
      children: const [
        generate.HomeTab(),
        generate_config.ConfigTab(),
        correction_config.CorrectionTab(),
        help_tab.HelpTab(),
      ],
    );
  }
}

class _Destination {
  final IconData icon;
  final String label;

  const _Destination(this.icon, this.label);
}
