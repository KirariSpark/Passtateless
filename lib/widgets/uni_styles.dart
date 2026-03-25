import 'package:flutter/material.dart';

ButtonStyle uniButtonStyle = ElevatedButton.styleFrom(
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5))
    )
);

RoundedRectangleBorder uniRoundedBorder = const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(5))
);

BorderRadius uniBorderRadius = BorderRadius.circular(5);

TextStyle uniHintTextStyle = const TextStyle(fontSize: 12, color: Colors.grey);

BoxConstraints uniBoxConstraints = const BoxConstraints(maxWidth: 1010);

BoxConstraints tileWidthConstraint = const BoxConstraints(maxWidth: 400);

EdgeInsets uniInsetsSmall = const EdgeInsets.all(8);

const double layoutSpacing = 8;

const SizedBox uniSizedBoxMedium = SizedBox(width: 8, height: 8);

InputDecoration uniInputDecoration(String label) {
    return InputDecoration(
        label: Text(label),
        border: OutlineInputBorder(
            borderRadius: uniBorderRadius,
        ),
    );
}