import 'dart:convert';
import 'package:avauserapp/components/longLog.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<String?> walletLoad(context) async {
  var walletBalance = "";
  var callUserLoginCheck = await internetConnectionState();
  if (callUserLoginCheck == true) {
    Map decoded = jsonDecode(await getApiDataRequest(myWallettUrl, context));
    String status = decoded['status'];
    if (status == success_status) {
      var record = decoded['record'];
      var wallet_setup_done = record['wallet_setup_done'];
      if (wallet_setup_done == "true") {
        var wallet_balance = record['wallet_balance'];
        walletBalance = wallet_balance.toString();
      } else {
        walletBalance = "NA";
      }
    } else if (status == unauthorized_status) {
      await checkLoginStatus(context);
    } else if (status == already_login_status) {
    } else if (status == data_not_found_status) {
    } else if (status == expire_token_status) {
      Map decoded = jsonDecode(await apiRefreshRequest(context));
      walletLoad(context);
    } else {}
    return walletBalance;
  } else {}
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
