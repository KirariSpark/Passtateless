import 'dart:math';

import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:provider/provider.dart';

class ContrastSettingsPage extends StatelessWidget {
  /// 有AppBar时，是否要使用Hero动画
  final bool useHero;
  /// 是否要包含AppBar
  final bool hasAppBar;
  /// 是否有内边距
  final bool hasPadding;

  const ContrastSettingsPage({super.key, this.useHero = true, this.hasAppBar = true, this.hasPadding = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hasAppBar ? styled.buildAppBar(
        title: "对比度",
        titleTag: useHero ? "contrast" : null,
        context: context
      ) : null,
      body: Container(
        alignment: Alignment.topCenter,
        child: Container(
          padding: hasPadding ? styles.pagePadding : null,
          constraints: styles.tileWidthConstraint,
          child: SingleChildScrollView(
            child: Column(
              spacing: styles.layoutSpacing,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RadioGroup(
                  groupValue: Provider.of<AppProvider>(context).currentContrast,
                  onChanged: (value) {
                    Provider.of<AppProvider>(context, listen: false).contrast = value!;
                  },
                  child: Column(
                    children: [
                      for (final (index, value) in ContrastLevels.values.indexed) RadioListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: index == 0 ? styles.radius : Radius.zero,
                            bottom: index == ContrastLevels.values.length - 1 ? styles.radius : Radius.zero
                          )
                        ),
                        value: value,
                        title: Text(value.displayName),
                        tileColor: ColorScheme.of(context).surfaceContainerLow,
                      )
                    ],
                  )
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
                              color: ColorScheme.of(context).primary,
                              constraints: BoxConstraints(minHeight: 100),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: ColorScheme.of(context).onPrimary,
                              constraints: BoxConstraints(minHeight: 100),
                            ),
                          ),
                          ? constraints.maxWidth > 200 ? Expanded(
                            child: Container(
                              color: ColorScheme.of(context).secondary,
                              constraints: BoxConstraints(minHeight: 100),
                            ),
                          ) : null,
                          ? constraints.maxWidth > 200 ? Expanded(
                            child: Container(
                              color: ColorScheme.of(context).onSecondary,
                              constraints: BoxConstraints(minHeight: 100),
                            ),
                          ) : null
                        ],
                      ),
                    );
                  },
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }
}