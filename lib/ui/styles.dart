import 'package:flutter/material.dart';

RoundedRectangleBorder roundedBorder = const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(5))
);

ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    shape: roundedBorder
);

BorderRadius borderRadius = BorderRadius.circular(5);

BoxConstraints uniBoxConstraints = const BoxConstraints(maxWidth: 1010);

BoxConstraints pageWidthConstraint = const BoxConstraints(maxWidth: 800);

BoxConstraints tileWidthConstraint = const BoxConstraints(maxWidth: 400);

BoxConstraints tileHeightConstraint = const BoxConstraints(maxHeight: 300);

EdgeInsets uniInsetsSmall = const EdgeInsets.all(8);

EdgeInsets pagePadding = const EdgeInsets.symmetric(horizontal: 16);

const double layoutSpacing = 8;

const SizedBox spacingSizedBox = SizedBox(width: 8, height: 8);

InputDecoration uniInputDecoration(String label) {
    return InputDecoration(
        label: Text(label),
        border: OutlineInputBorder(
            borderRadius: borderRadius,
        ),
    );
}

const int alphaTransparent = 64;

const int alphaOpaque = 224;

const int alphaSemitransparent = 192;