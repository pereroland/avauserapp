import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<bool> internetConnectionState([bool? isShowToast]) async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    } else {
      if (isShowToast == null || isShowToast == true)
        _showToast("Please Check internet Connection");
      return false;
    }
  } on SocketException catch (_) {
    if (isShowToast == null || isShowToast == true)
      _showToast("Please Check internet Connection");
    return false;
  }
}

void _showToast(String mesage) {
  Fluttertoast.showToast(
      msg: mesage,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0);
}
