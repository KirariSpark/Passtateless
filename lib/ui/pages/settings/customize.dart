import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:provider/provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/ui/styles.dart' as styles;

class CustomizeSettingsPage extends StatelessWidget {
  final bool useHero;
  const CustomizeSettingsPage({super.key, required this.useHero});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    return Scaffold(
      appBar: styled.buildAppBar(title: "个性化", context: context, titleTag: useHero ? "customize" : null),
      body: Container(
        alignment: Alignment.topCenter,
        child: Container(
          padding: styles.pagePadding,
          constraints: styles.pageWidthConstraint,
          child: SingleChildScrollView(
            child: Column(
              children: [
                RadioGroup(
                  groupValue: appProvider.currentColor,
                  onChanged: (value) async {
                    Provider.of<AppProvider>(context, listen: false).color = value ?? AvailableColors.teal;
                    var res = await Provider.of<AppProvider>(context, listen: false).saveConfig();
                    if (res != ErrorCode.success && context.mounted) {
                      ui.showSnackBarQuick(res.generic, context);
                    }
                  },
                  child: Wrap(
                    runSpacing: styles.layoutSpacing,
                    spacing: styles.layoutSpacing,
                    children: [
                      for (var item in AvailableColors.values) ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 130),
                        child: RadioListTile(
                          value: item,
                          shape: styles.roundedBorder,
                          title: Text(item.displayName),
                          tileColor: item.color.withAlpha(styles.alphaAlmostTransparent),
                        ),
                      ),
                    ],
                  )
                ),
              ]
            )
          )
        )
      )
    );
  }
}