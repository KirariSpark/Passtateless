import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:provider/provider.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/modules/providers/app_provider.dart';

class HelpTab extends StatelessWidget {
  const HelpTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: true);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(8),
        alignment: AlignmentGeometry.topCenter,
        child: Container(
          decoration: BoxDecoration(
            color: ColorScheme.of(context).surfaceContainerLowest.withAlpha(styles.alphaSemitransparent),
            borderRadius: styles.borderRadius
          ),
          constraints: styles.pageWidthConstraint,
          child: Markdown(data: appProvider.helpContent)
        ),
      ),
    );
  }
}