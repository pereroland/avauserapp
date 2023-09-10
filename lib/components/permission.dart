import 'dart:io';

import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestPermission(
    String permissionName, Permission permission, context) async {
  final status = await permission.request();
  String permissionTxt = "Permission is ";
  if (status.isGranted) {
    return true;
  } else if (status.isDenied) {
    _messageShow(context, permissionName);
    return false;
  } else if (status.isPermanentlyDenied && Platform.isAndroid) {
    _messageShow(context, permissionName);
    return false;
  } else if (status.isRestricted) {
    _messageShow(context, permissionName);
    return false;
  } else {
    // _showToast(context, permissionTxt + status.toString());
    return false;
  }
}

void _messageShow(context, String permissionName) {
  String message;
  if (permissionName == "Location") {
    message =
        "Location permission is required to notify you about various offers available at your nearby stores.";
  } else {
    message =
        "We needed $permissionName Permission as \n\nAllow all the time\n\n for taking you better service.Please go to the Setting and Allow it";
  }
  popUp(context, message);
}

void popUp(context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Ecity'),
        content: Text(message),
        actions: [
          MaterialButton(
            elevation: 0.0,
            textColor: Colors.black,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(allTranslations.text('OK')),
          ),
        ],
      );
    },
  );
}

Widget? _showToast(BuildContext context, String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 5,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0);
}
