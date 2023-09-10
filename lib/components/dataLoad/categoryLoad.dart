import 'dart:convert';
import 'package:avauserapp/components/longLog.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<List?>  callCategoryLoad(context) async {
  List _categoryList =[];
  Map categoryList = jsonDecode(await getApiDataRequest(getCategoriesUrl, context));
  String status = categoryList['status'];
  String message = categoryList['message'];
  if (status == success_status) {
    _categoryList = categoryList['record'] as List;
/*    for (int i = 0; i < record.length; i++) {
      _categoryList.add({
        "id": record[i]['id'],
        "name": record[i]['name'],
      });
    }*/
    return _categoryList;
  } else if (status == unauthorized_status) {
    await checkLoginStatus(context);
    return _categoryList;
  } else if (status == expire_token_status) {
    Map decoded = jsonDecode(await apiRefreshRequest(context));
    callCategoryLoad(context);
  } else {
    _showToast(message);
    return _categoryList;
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
