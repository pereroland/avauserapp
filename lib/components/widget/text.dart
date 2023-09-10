import 'package:flutter/material.dart';

Text headerText(
    {required String text, Color? color, double? size, fontWeight, textAlign}) {
  return Text(
    text,
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: size == null ? 20.0 : size,
      color: color == null ? Colors.black : color,
    ),
    textAlign: textAlign,
  );
}
