import 'package:avauserapp/components/colorconstants.dart';
import 'package:flutter/material.dart';

ElevatedButton fullColouredBtn(
    {required String text,
    VoidCallback? onPressed,
    var radiusButtton,
    var colors}) {
  return ElevatedButton(
      child: Text(text, style: TextStyle(fontSize: 16, color: Colors.white)),
      style: ButtonStyle(
          foregroundColor:
              MaterialStateProperty.all<Color>(colors ?? AppColours.appTheme),
          backgroundColor:
              MaterialStateProperty.all<Color>(colors ?? AppColours.appTheme),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      radiusButtton == null ? 5.0 : radiusButtton),
                  side: BorderSide(color: colors ?? AppColours.appTheme)))),
      onPressed: onPressed);
}

SizedBox loadingButton(Size size) {
  return SizedBox(
    height: 70,
    child: ButtonTheme(
      minWidth: size.width,
      height: 60.0,
      buttonColor: AppColours.appTheme,
      child: MaterialButton(
          color: AppColours.appTheme,
          elevation: 16.0,
          shape: OutlineInputBorder(
            borderSide: BorderSide(color: AppColours.appTheme),
            borderRadius: BorderRadius.circular(25.0),
          ),
          onPressed: () {},
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          )),
    ),
  );
}

ElevatedButton trasparentColouredBtn(
    {required String text,
    VoidCallback? onPressed,
    Color? textColour,
    var radiusButtton}) {
  return ElevatedButton(
      child: Text(text,
          style: TextStyle(
              fontSize: 14,
              color: textColour == null ? AppColours.appTheme : textColour)),
      style: ButtonStyle(
          foregroundColor:
              MaterialStateProperty.all<Color>(AppColours.appTheme),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      radiusButtton == null ? 5.0 : radiusButtton),
                  side: BorderSide(color: AppColours.appTheme)))),
      onPressed: onPressed);
}

ElevatedButton fullColouredCustomBtn(
    {required String text,
    VoidCallback? onPressed,
    required Color btnColour,
    Color? textColour}) {
  return ElevatedButton(
      child: Text(text, style: TextStyle(fontSize: 14, color: textColour)),
      style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(btnColour),
          backgroundColor: MaterialStateProperty.all<Color>(btnColour),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: BorderSide(color: btnColour)))),
      onPressed: onPressed);
}

ElevatedButton trasparentColouredIconBtn(
    {var IconData,
    VoidCallback? onPressed,
    Color? textColour,
    var buttonColour}) {
  return ElevatedButton(
      child: Icon(
        IconData,
        color: buttonColour == null ? Colors.white : buttonColour,
      ),
      style: ButtonStyle(
          foregroundColor:
              MaterialStateProperty.all<Color>(AppColours.appTheme),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: BorderSide(color: AppColours.appTheme)))),
      onPressed: onPressed);
}

InkWell roundedBtn(
    {required Size size,
    required String imageName,
    VoidCallback? onTap,
    required Color borderColour,
    required Color backgroundColour}) {
  var shortestSide = size.shortestSide;
  final bool useMobileLayout = shortestSide < 600;
  var padding;
  if (useMobileLayout) {
    padding = 10.0;
  } else {
    padding = 10.0;
  }
  return InkWell(
    child: new Container(
      decoration: new BoxDecoration(
        color: backgroundColour,
        shape: BoxShape.circle,
        border: new Border.all(
          color: borderColour,
          width: 1.0,
        ),
      ),
      child: new Center(
        child: Padding(
          child: Image.asset(imageName),
          padding: EdgeInsets.all(padding),
        ),
      ),
    ),
    onTap: onTap,
  );
}

InkWell roundedCutomBtn(
    {required Size size,
    required String imageName,
    VoidCallback? onTap,
    required Color borderColour,
    required Color backgroundColour,
    var padding}) {
  var shortestSide = size.shortestSide;

  return InkWell(
    child: new Container(
      decoration: new BoxDecoration(
        color: backgroundColour,
        shape: BoxShape.circle,
        border: new Border.all(
          color: borderColour,
          width: 1.0,
        ),
      ),
      child: new Center(
        child: Padding(
          child: Image.asset(imageName),
          padding: EdgeInsets.all(padding),
        ),
      ),
    ),
    onTap: onTap,
  );
}

ElevatedButton fullColouredImageBtn(
    {icon,
    required Color backgroundColour,
    VoidCallback? onPressed,
    var radiusButtton}) {
  return ElevatedButton(
      child: icon,
      style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(backgroundColour),
          backgroundColor: MaterialStateProperty.all<Color>(backgroundColour),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      radiusButtton == null ? 5.0 : radiusButtton),
                  side: BorderSide(color: backgroundColour)))),
      onPressed: onPressed);
}
