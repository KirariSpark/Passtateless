import 'dart:math';

import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/file_mgr/core_mgr.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/pages/settings/about.dart';
import 'package:passtateless/ui/pages/settings/log_view.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/ui/widgets/styled_list_tile.dart';
import 'package:provider/provider.dart';

// 基础设置页面（所有设置项合并到单页）
class BasicSettingsPage extends StatefulWidget {
  const BasicSettingsPage({super.key});

  @override
  State<BasicSettingsPage> createState() => _BasicSettingsPageState();
}

class _BasicSettingsPageState extends State<BasicSettingsPage> {
  late final AppProvider _appProvider;

  @override
  void initState() {
    super.initState();
    _appProvider = context.read<AppProvider>();
  }

  // ————主题弹窗————
  void _showThemeDialog() {
    ui.showAlertDialogQuick(
      title: "主题",
      content: RadioGroup(
        groupValue: _appProvider.currentColor,
        onChanged: (value) async {
          _appProvider.color = value ?? AvailableColors.teal;
          Navigator.of(context).pop();
          appLogger.logger.i("Theme changed to ${value?.name}");
          final res = await _appProvider.saveConfig();
          if (mounted && res != ErrorCode.success) {
            appLogger.logger.e("Can not save config: ${res.code}");
            ui.showSnackBarQuick(res.generic, context);
          } else if (mounted) {
            appLogger.logger.i("Changes in settings saved");
          }
        },
        child: Column(
          children: [
            for (final item in AvailableColors.values) RadioListTile(
              value: item,
              shape: styles.roundedBorder,
              title: Container(
                constraints: BoxConstraints(minHeight: 50),
                decoration: BoxDecoration(
                  borderRadius: styles.borderRadius,
                  color: ColorScheme.fromSeed(seedColor: item.color).primaryContainer,
                ),
                clipBehavior: Clip.antiAlias,
              ),
            ),
          ],
        ),
      ),
      action: () => Navigator.of(context).pop(),
      actionText: "取消",
      context: context,
    );
  }

  // ————动画弹窗————
  void _showAnimationDialog() {
    ui.showAlertDialogQuick(
      title: "动画",
      content: RadioGroup(
        groupValue: _appProvider.currentDilation,
        onChanged: (value) async {
          _appProvider.currentDilation = value!;
          Navigator.of(context).pop();
          final stat = await _appProvider.saveConfig();
          if (mounted && stat != ErrorCode.success) {
            ui.showSnackBarQuick(stat.generic, context);
          }
        },
        child: Column(
          children: [
            for (final item in AnimationDilation.values) RadioListTile(
              value: item,
              title: Text(item.displayName),
              shape: styles.roundedBorder,
            ),
          ],
        ),
      ),
      action: () => Navigator.of(context).pop(),
      actionText: "取消",
      context: context,
    );
  }

  // ————日志等级————
  void _showLogLvlDialog() {
    ui.showAlertDialogQuick(
      title: "日志等级",
      content: RadioGroup(
        groupValue: _appProvider.currentLogLevel,
        onChanged: (value) {
          _changeLogLvl(value!);
          Navigator.of(context).pop();
        },
        child: Column(
          children: [
            for (var item in LogLevels.values) RadioListTile(
              value: item,
              title: Text(item.displayName),
              shape: styles.roundedBorder,
            )
          ],
        ),
      ),
      action: () => Navigator.of(context).pop(),
      actionText: "取消",
      context: context,
    );
  }

  Future<void> _changeLogLvl(LogLevels value) async {
    _appProvider.currentLogLevel = value;
    final stat = await _appProvider.saveConfig();
    if (mounted && stat != ErrorCode.success) ui.showSnackBarQuick(stat.generic, context);
  }

  Future<void> _viewLog() async {
    appLogger.logger.i("Loading log");
    final (stat, res) = await readTextFile(Paths.log.path);
    if (context.mounted && stat == ErrorCode.success) {
      appLogger.logger.i("Log loaded");
      Navigator.push(context, MaterialPageRoute(builder: (_) => LogViewPage(log: res)));
    } else {
      appLogger.logger.e("Can not load log: ${stat.code}");
      ui.showSnackBarQuick(stat.generic, context);
    }
  }

  void _showAbout() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage()));
  }

  @override
  Widget build(BuildContext context) {
    final appProviderWatch = context.watch<AppProvider>();
    final contentColor = ColorScheme.of(context).onSurface;

    // 第一栏：主题 / 动画 / 日志等级
    final basicTopCol = [
      StyledListTileSimple(
        title: "主题",
        leadingIcon: Icons.color_lens_outlined,
        trailing: Icon(Icons.arrow_drop_down),
        onTap: _showThemeDialog,
        isFirst: true,
      ),
      StyledListTileSimple(
        title: "动画",
        leadingIcon: Icons.animation,
        trailing: Icon(Icons.arrow_drop_down),
        onTap: _showAnimationDialog,
      ),
      StyledListTileSimple(
        title: "日志等级",
        leadingIcon: Icons.signal_cellular_null,
        trailing: Icon(Icons.arrow_drop_down),
        onTap: _showLogLvlDialog,
        isLast: true,
      ),
    ];

    // 第二栏：对比度（宽屏默认展开，窄屏默认收起）
    List<Widget> contrastCol(bool expanded) => [
      Container(
        decoration: BoxDecoration(
          borderRadius: styles.borderRadius,
          color: ColorScheme.of(context).surfaceContainerLow,
        ),
        child: ExpansionTile(
          leading: Icon(Icons.contrast, color: contentColor),
          title: Text("对比度"),
          initiallyExpanded: expanded,
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          shape: styles.roundedBorder,
          collapsedShape: styles.roundedBorder,
          iconColor: contentColor,
          collapsedIconColor: contentColor,
          textColor: contentColor,
          collapsedTextColor: contentColor,
          childrenPadding: styles.uniInsetsSmall,
          children: [
            Column(
              spacing: styles.layoutSpacing,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RadioGroup(
                  groupValue: appProviderWatch.currentContrast,
                  onChanged: (value) {
                    _appProvider.contrast = value!;
                    _appProvider.saveConfig();
                  },
                  child: Column(
                    children: [
                      for (final (index, value) in ContrastLevels.values.indexed) RadioListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: ui.calcRadius(
                            isFirst: index == 0,
                            isLast: index == ContrastLevels.values.length - 1,
                          ),
                        ),
                        value: value,
                        title: Text(value.displayName),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1),
                Text("预览", style: Theme.of(context).textTheme.titleLarge),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Container(
                      decoration: BoxDecoration(borderRadius: styles.borderRadius),
                      clipBehavior: Clip.antiAlias,
                      constraints: BoxConstraints(maxHeight: min(constraints.maxWidth * 0.25, 300)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              color: ColorScheme.of(context).primaryContainer,
                              constraints: BoxConstraints(minHeight: 100),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: ColorScheme.of(context).onPrimaryContainer,
                              constraints: BoxConstraints(minHeight: 100),
                            ),
                          ),
                          ? constraints.maxWidth > 200 ? Expanded(
                            child: Container(
                              color: ColorScheme.of(context).secondaryContainer,
                              constraints: BoxConstraints(minHeight: 100),
                            ),
                          ) : null,
                          ? constraints.maxWidth > 200 ? Expanded(
                            child: Container(
                              color: ColorScheme.of(context).onSecondaryContainer,
                              constraints: BoxConstraints(minHeight: 100),
                            ),
                          ) : null,
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ];

    // 第一栏：查看日志 / 关于
    final miscCol = [
      StyledListTileSimple(
        title: "查看日志",
        leadingIcon: Icons.paste_outlined,
        trailing: Icon(Icons.arrow_forward),
        isFirst: true,
        onTap: _viewLog,
      ),
      StyledListTileSimple(
        title: "关于",
        leadingIcon: Icons.info_outline,
        trailing: Icon(Icons.arrow_forward),
        onTap: _showAbout,
        isLast: true,
      ),
    ];

    return Scaffold(
      appBar: styled.buildAppBar(title: "设置", context: context),
      body: SingleChildScrollView(
        child: Container(
          padding: styles.pagePaddingAll,
          alignment: Alignment.centerLeft,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 足够宽时并排双栏
              final wide = constraints.maxWidth >= styles.layoutChangeWidth;

              // 双栏
              Widget wideLayout() {
                Widget tile(List<Widget> children) => ConstrainedBox(
                  constraints: styles.tileWidthConstraint,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                  ),
                );
                return Row(
                  key: const ValueKey("wide"),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: styles.layoutSpacing,
                  children: [
                    Flexible(child: tile([...basicTopCol, styles.spacingSizedBox, ...miscCol])),
                    Flexible(child: tile(contrastCol(true))),
                  ],
                );
              }

              // 单栏
              Widget narrowLayout() => ConstrainedBox(
                key: const ValueKey("narrow"),
                constraints: styles.tileWidthConstraint,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...basicTopCol,
                    styles.spacingSizedBox,
                    ...contrastCol(false),
                    styles.spacingSizedBox,
                    ...miscCol,
                  ],
                ),
              );

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                layoutBuilder: (currentChild, previousChildren) => Stack(
                  alignment: AlignmentDirectional.topStart,
                  textDirection: Directionality.of(context),
                  children: [
                    ...previousChildren,
                    ?currentChild,
                  ],
                ),
                child: wide ? wideLayout() : narrowLayout(),
              );
            },
          ),
        ),
      ),
    );
  }
}
