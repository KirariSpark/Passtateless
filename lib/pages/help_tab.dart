import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:provider/provider.dart';
import 'package:passtateless/widgets/uni_styles.dart' as styles;
import 'package:passtateless/providers/app_provider.dart';

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
          constraints: styles.uniBoxConstraints,
          decoration: BoxDecoration(
            color: Theme.of(context).hoverColor,
            borderRadius: styles.uniBorderRadius,
          ),
          child: ClipRRect(
            borderRadius: styles.uniBorderRadius,
            child: Markdown(data: appProvider.helpContent),
          ),
        ),
      ),
    );
  }
}