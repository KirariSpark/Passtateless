import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/ui/styles.dart' as styles;

class CustomizeSettingsPage extends StatelessWidget {
  const CustomizeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    return Scaffold(
      appBar: styled.buildAppBar(title: "个性化", titleTag: "customize", context: context),
      body: Container(
        alignment: Alignment.topCenter,
        child: Container(
          padding: styles.pagePadding,
          constraints: styles.pageWidthConstraint,
          child: SingleChildScrollView(
            child: Column(
              children: [
                RadioGroup(
                  groupValue: appProvider.color,
                  onChanged: (value) {
                    Provider.of<AppProvider>(context, listen: false).color = value ?? Colors.blueGrey;
                  },
                  child: Wrap(
                    runSpacing: styles.layoutSpacing,
                    spacing: styles.layoutSpacing,
                    children: [
                      for (var item in AvailableColors.values) ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 130),
                        child: RadioListTile(
                          value: item.color,
                          shape: styles.roundedBorder,
                          title: Text(item.name),
                          tileColor: item.color.withAlpha(styles.alphaAlmostTransparent),
                        ),
                      ),
                      // Container(
                      //   decoration: BoxDecoration(
                      //     gradient: LinearGradient(
                      //       colors: [
                      //         Colors.blueAccent.withAlpha(styles.alphaAlmostTransparent),
                      //         Colors.teal.withAlpha(styles.alphaAlmostTransparent),
                      //         Colors.amberAccent.withAlpha(styles.alphaAlmostTransparent)
                      //       ]
                      //     ),
                      //     borderRadius: styles.borderRadius
                      //   ),
                      //   constraints: BoxConstraints(maxWidth: 130),
                      //   child: RadioListTile(
                      //     value: Colors.brown,
                      //     shape: styles.roundedBorder,
                      //     title: Text("莫奈")
                      //   ),
                      // )
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