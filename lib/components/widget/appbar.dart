import 'package:flutter/material.dart';

AppBar appBarWidget(
    {var backButton,
    Color? backgroundColour,
    var text,
    var backButtonColour,
    var textColour,
    VoidCallback? onTap,
    var actions}) {
  return AppBar(
      title: text == null
          ? Text('')
          : Text(
              text,
              style: TextStyle(
                  color: textColour == null ? Colors.black : textColour),
            ),
      iconTheme: IconThemeData(
        color: backButtonColour == null
            ? Colors.black
            : backButtonColour, //change your color here
      ),
      backgroundColor:
          backgroundColour == null ? Colors.white : backgroundColour,
      centerTitle: true,
      leading: BackButton(onPressed: onTap),
      actions: actions);
}
