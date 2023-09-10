import 'dart:convert';
import 'package:avauserapp/components/longLog.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<Map?> dropDownDataWalletLoad(context) async {
  Map categoryList =
      jsonDecode(await getApiDataRequest(getDropDownDataWalletUrl, context));
  String status = categoryList['status'];
  String message = categoryList['message'];
  if (status == success_status) {
    return categoryList;
  } else if (status == unauthorized_status) {
    await checkLoginStatus(context);
    return categoryList;
  } else if (status == expire_token_status) {
    Map decoded = jsonDecode(await apiRefreshRequest(context));
    dropDownDataWalletLoad(context);
  } else {
    _showToast(message);
    return categoryList;
  }
}

Future<Map?> getDropDownDataPayoutLoad(context) async {
  Map categoryList =
      jsonDecode(await getApiDataRequest(getDropDownDataPayoutUrl, context));
  String status = categoryList['status'];
  String message = categoryList['message'];
  if (status == success_status) {
    return categoryList;
  } else if (status == unauthorized_status) {
    await checkLoginStatus(context);
    return categoryList;
  } else if (status == expire_token_status) {
    Map decoded = jsonDecode(await apiRefreshRequest(context));
    dropDownDataWalletLoad(context);
  } else {
    _showToast(message);
    return categoryList;
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
