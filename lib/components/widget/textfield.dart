import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

TextField normalTextfield(
    {required String hintText,
    TextEditingController? controller,
    TextInputType? keyboardType,
    bool? readOnly,
    Icon? suffixIcon,
    Color? borderColour,
    Color? hintColour,
    Color? textColour,
    TextInputAction? textInputAction,
    String? countertext,
    int? maxlength,
    ValueChanged<String>? onChanged}) {
  return TextField(
    onChanged: onChanged,
    readOnly: readOnly == null ? false : readOnly,
    controller: controller,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    maxLength: maxlength,
    style: TextStyle(color: textColour == null ? Colors.black : textColour),
    decoration: new InputDecoration(
      counterText: countertext,
      suffixIcon: suffixIcon == null ? SizedBox.shrink() : suffixIcon,
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
            color: borderColour == null ? Colors.transparent : borderColour),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
            color: borderColour == null ? Colors.transparent : borderColour),
      ),
      hintText: hintText,
      hintStyle:
          TextStyle(color: hintColour == null ? Colors.black : hintColour),
    ),
  );
}

TextFormField normalFormTextfield(
    {required String hintText,
    TextEditingController? controller,
    TextInputType? keyboardType,
    bool? readOnly,
    Icon? suffixIcon,
    Color? borderColour,
    Color? hintColour,
    Color? textColour,
    String? countertext,
    int? maxlength,
    ValueChanged<String>? onChanged}) {
  return TextFormField(
    onChanged: onChanged,
    readOnly: readOnly == null ? false : readOnly,
    controller: controller,
    keyboardType: keyboardType,
    style: TextStyle(color: textColour == null ? Colors.black : textColour),
    decoration: new InputDecoration(
      suffixIcon: suffixIcon == null ? SizedBox.shrink() : suffixIcon,
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
            color: borderColour == null ? Colors.transparent : borderColour),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
            color: borderColour == null ? Colors.transparent : borderColour),
      ),
      hintText: hintText,
      hintStyle:
          TextStyle(color: hintColour == null ? Colors.black : hintColour),
    ),
    validator: (value) {
      if (value!.isEmpty) {
        return '${allTranslations.text("please_enter")} $hintText';
      }
      return null;
    },
  );
}

TextField normalNumberTextfield(
    {required String hintText,
    TextEditingController? controller,
    TextInputType? keyboardType,
    bool? readOnly,
    Icon? suffixIcon,
    Color? borderColour,
    Color? hintColour,
    Color? textColour,
    String? countertext,
    int? maxlength,
    ValueChanged<String>? onChanged}) {
  return TextField(
    onChanged: onChanged,
    readOnly: readOnly == null ? false : readOnly,
    controller: controller,
    inputFormatters: <TextInputFormatter>[
      FilteringTextInputFormatter.digitsOnly
    ],
    // Only numbers can be entered
    textInputAction: TextInputAction.next,
    keyboardType: keyboardType,
    style: TextStyle(color: textColour == null ? Colors.black : textColour),
    decoration: new InputDecoration(
      suffixIcon: suffixIcon == null ? SizedBox.shrink() : suffixIcon,
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
            color: borderColour == null ? Colors.transparent : borderColour),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
            color: borderColour == null ? Colors.transparent : borderColour),
      ),
      hintText: hintText,
      hintStyle:
          TextStyle(color: hintColour == null ? Colors.black : hintColour),
    ),
  );
}

TextFormField borderTextfield(
    {required String hintText,
    TextEditingController? controller,
    TextInputType? keyboardType,
    var radiusCircular,
    FormFieldValidator<String>? validatordata,
    Color? appColour,
    var maxLines}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    maxLines: maxLines ?? 1,
    decoration: new InputDecoration(
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(radiusCircular ?? 10.0),
        ),
        borderSide:
            BorderSide(color: appColour ?? AppColours.appTheme, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(radiusCircular ?? 10.0),
        ),
        borderSide:
            BorderSide(color: appColour ?? AppColours.appTheme, width: 1.0),
      ),
      hintText: hintText,
    ),
    validator: validatordata,
  );
}
