import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:provider/provider.dart';

class AnimationSettingsPage extends StatefulWidget {
  /// 有AppBar时，是否要使用Hero动画
  final bool useHero;

  /// 是否要包含AppBar
  final bool hasAppBar;

  /// 是否有内边距
  final bool hasPadding;

  const AnimationSettingsPage({
    super.key,
    required this.useHero,
    this.hasAppBar = true,
    this.hasPadding = true
  });

  @override
  State<AnimationSettingsPage> createState() => _AnimationSettingsPageState();
}

class _AnimationSettingsPageState extends State<AnimationSettingsPage> {
  late final AppProvider appProviderRead;

  @override
  void initState() {
    super.initState();
    appProviderRead = context.read<AppProvider>();
  }

  @override
  Widget build(BuildContext context) {
    final AppProvider appProviderWatch = context.watch<AppProvider>();

    return Scaffold(
      appBar: widget.hasAppBar
        ? styled.buildAppBar(title: "动画", context: context, titleTag: widget.useHero ? HeroTags.animationSettings.tag : null)
        : null,
      body: Container(
        alignment: Alignment.topCenter,
        padding: widget.hasPadding ? styles.pagePaddingAll : EdgeInsets.zero,
        child: ConstrainedBox(
          constraints: styles.tileWidthConstraint,
          child: SingleChildScrollView(
            child: Column(
              spacing: styles.layoutSpacing,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("动画风格", style: Theme.of(context).textTheme.titleLarge),
                RadioGroup(
                  groupValue: appProviderWatch.currentNavMode,
                  onChanged: (value) async {
                    appProviderRead.currentNavMode = value!;
                    final stat = await appProviderRead.saveConfig();
                    if (stat != ErrorCode.success && context.mounted) {
                      ui.showSnackBarQuick(stat.generic, context);
                    }
                  },
                  child: Column(
                    children: [
                      for (final (index, item) in NavigatorMode.values.indexed) RadioListTile(
                        value: item,
                        title: Text(item.displayName),
                        tileColor: ColorScheme.of(context).surfaceContainerLow,
                        shape: RoundedRectangleBorder(
                          borderRadius: ui.calcRadius(
                            isFirst: index == 0, isLast: index == NavigatorMode.values.length - 1
                          ),
                        )
                      )
                    ],
                  )
                ),
                Divider(),
                Text("动画速度", style: Theme.of(context).textTheme.titleLarge),
                RadioGroup(
                  groupValue: appProviderWatch.currentDilation,
                  onChanged: (value) async {
                    appProviderRead.currentDilation = value!;
                    final stat = await appProviderRead.saveConfig();
                    if (stat != ErrorCode.success && context.mounted) {
                      ui.showSnackBarQuick(stat.generic, context);
                    }
                  },
                  child: Column(
                    children: [
                      for (final (index, item) in AnimationDilation.values.indexed) RadioListTile(
                        value: item,
                        title: Text(item.displayName),
                        tileColor: ColorScheme.of(context).surfaceContainerLow,
                        shape: RoundedRectangleBorder(
                          borderRadius: ui.calcRadius(
                            isFirst: index == 0, isLast: index == AnimationDilation.values.length - 1
                          ),
                        )
                      )
                    ],
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}