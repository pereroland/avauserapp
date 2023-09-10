import 'package:flutter/material.dart';

/// Provides data for a speed dial child
class SpeedDialChild {
  /// The label to render to the left of the button
  final String label;

  /// The style of the label
  final TextStyle labelStyle;
  final Color? labelBackgroundColor;

  final Widget child;
  final Color backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final VoidCallback onTap;
  final ShapeBorder? shape;

  SpeedDialChild({
    required this.label,
    required this.labelStyle,
    this.labelBackgroundColor,
    required this.child,
    required this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    required this.onTap,
    this.shape,
  });
}
