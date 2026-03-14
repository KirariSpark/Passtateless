import 'package:flutter/material.dart';
import 'uni_styles.dart' as styles;

class CorrectionWidget extends StatelessWidget {
  final TextEditingController _wrongController;
  final TextEditingController _correctionController;
  final VoidCallback? onChanged;

  const CorrectionWidget({
    super.key,
    required TextEditingController wrongController,
    required TextEditingController correctionController,
    this.onChanged,
  })  : _correctionController = correctionController,
        _wrongController = wrongController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: styles.uniInsetsSmall,
      child: Row(
        spacing: 4,
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _wrongController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5))
                )
              ),
              onChanged: (_) => onChanged?.call(),
            )
          ),
          const Icon(Icons.arrow_forward_rounded),
          Expanded(
            child: TextField(
              controller: _correctionController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5))
                )
              ),
              onChanged: (_) => onChanged?.call(),
            )
          ),
        ],
      ),
    );
  }
}
