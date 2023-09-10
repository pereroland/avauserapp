import 'dart:convert';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:avauserapp/components/longLog.dart';

Future<Map?> checkWalletIdLoad(context, String walletId, var currency,
    cinetpayCurrencyFirstValueId) async {
  Map walletIDMap = {
    "wallet_ID": walletId,
    "currency_name": currency,
    "currency_id": cinetpayCurrencyFirstValueId
  };
  Map walletList = jsonDecode(
      await apiRequest(walletIDAvailablityUrl, walletIDMap, context));
  String status = walletList['status'];
  String message = walletList['message'];
  if (status == success_status) {
    return walletList;
  } else if (status == unauthorized_status) {
    await checkLoginStatus(context);
    return walletList;
  } else if (status == expire_token_status) {
    Map decoded = jsonDecode(await apiRefreshRequest(context));
    checkWalletIdLoad(
        context, walletId, currency, cinetpayCurrencyFirstValueId);
  } else {
    return walletList;
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
