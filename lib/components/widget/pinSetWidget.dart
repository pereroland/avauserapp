import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

PinCodeTextField pinSetWidget({ValueChanged<String>? onChanged, context}) {
  return PinCodeTextField(
    backgroundColor: Colors.white,
    textStyle: TextStyle(color: Colors.white),
    appContext: context,
    pastedTextStyle: TextStyle(
      color: Color(0xffC4C4C4),
    ),
    length: 4,
    obscureText: false,
    obscuringCharacter: '*',
    animationType: AnimationType.fade,
    validator: (v) {
      if (v!.length < 3) {
        return "I'm from validator";
      } else {
        return null;
      }
    },
    pinTheme: PinTheme(
      inactiveColor: Color(0xffC4C4C4),
      inactiveFillColor: Color(0xffC4C4C4),
      shape: PinCodeFieldShape.circle,
      activeFillColor: Color(0xffC4C4C4),
      activeColor: Color(0xffC4C4C4),
      disabledColor: Color(0xffC4C4C4),
      selectedFillColor: Color(0xffC4C4C4),
      selectedColor: Color(0xffC4C4C4),
    ),
    cursorColor: Colors.black,
    animationDuration: Duration(milliseconds: 300),
    enableActiveFill: true,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    boxShadows: [
      BoxShadow(
        offset: Offset(0, 1),
        color: Colors.black12,
        blurRadius: 10,
      )
    ],
    onCompleted: (v) {},
    // onTap: () {
    // },
    onChanged: onChanged!,
    beforeTextPaste: (text) {
      //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
      //but you can show anything you want here, like your pop up saying wrong paste format or etc
      return true;
    },
  );
}

PinCodeTextField controllerpinSetWidget(
    {ValueChanged<String>? onChanged, context, controller}) {
  return PinCodeTextField(
    backgroundColor: Colors.white,
    textStyle: TextStyle(color: Colors.white),
    appContext: context,
    pastedTextStyle: TextStyle(
      color: Color(0xffC4C4C4),
    ),
    length: 4,
    obscureText: false,
    obscuringCharacter: '*',
    animationType: AnimationType.fade,
    validator: (v) {
      if (v!.length < 3) {
        return "I'm from validator";
      } else {
        return null;
      }
    },
    pinTheme: PinTheme(
      inactiveColor: Color(0xffC4C4C4),
      inactiveFillColor: Color(0xffC4C4C4),
      shape: PinCodeFieldShape.circle,
      activeFillColor: Color(0xffC4C4C4),
      activeColor: Color(0xffC4C4C4),
      disabledColor: Color(0xffC4C4C4),
      selectedFillColor: Color(0xffC4C4C4),
      selectedColor: Color(0xffC4C4C4),
    ),
    controller: controller,
    cursorColor: Colors.black,
    animationDuration: Duration(milliseconds: 300),
    enableActiveFill: true,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    boxShadows: [
      BoxShadow(
        offset: Offset(0, 1),
        color: Colors.black12,
        blurRadius: 10,
      )
    ],
    onCompleted: (v) {},
    // onTap: () {
    // },
    onChanged: onChanged!,
    beforeTextPaste: (text) {
      //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
      //but you can show anything you want here, like your pop up saying wrong paste format or etc
      return true;
    },
  );
}
