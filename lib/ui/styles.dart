import 'package:flutter/material.dart';

double _radius = 5;

ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    shape: roundedBorder
);

Radius radius = Radius.circular(_radius);

RoundedRectangleBorder roundedBorder = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(_radius))
);

BorderRadius borderRadius = BorderRadius.circular(_radius);


BoxConstraints pageWidthConstraint = const BoxConstraints(maxWidth: 800);

BoxConstraints tileWidthConstraint = const BoxConstraints(maxWidth: 400);

BoxConstraints tileWidthConstraintSmall = const BoxConstraints(maxWidth: 300);

BoxConstraints tileHeightConstraint = const BoxConstraints(maxHeight: 300);

EdgeInsets uniInsetsSmall = const EdgeInsets.all(8);

EdgeInsets pagePadding = const EdgeInsets.symmetric(horizontal: 16);

EdgeInsets pagePaddingAll = const EdgeInsets.all(16);

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

const int alphaAlmostTransparent = 96;

const int alphaOpaque = 224;

const int alphaSemitransparent = 192;