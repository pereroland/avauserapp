import 'dart:convert';
import 'package:avauserapp/components/Location/CurrentLocation.dart';
import 'package:avauserapp/components/longLog.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/main.dart';
import 'package:avauserapp/screens/home/askForPermissionBeacon.dart';
import 'package:avauserapp/screens/home/baseTabClass.dart';
import 'package:avauserapp/screens/notification/NotificationTab.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List?> locationStoreLoad(Latitude, Longitude, context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var notifyUser = prefs.getString('notifyUser').toString();

  if (notifyUser == Latitude.toString()) {
  } else {
    var notifyUser = prefs.setString('notifyUser', Latitude);
    List _categoryList = [];
    Map map = {"latitude": Latitude, "longitude": Longitude};
    Map categoryList = jsonDecode(
        await apiRequestMainPage(locationNotificationUrl, map));
    String status = categoryList['status'];
    String message = categoryList['message'];

    if (status == success_status) {
      return _categoryList;
    } else if (status == unauthorized_status) {
      await checkLoginStatus(context);
      return _categoryList;
    } else if (status == expire_token_status) {
      Map decoded = jsonDecode(await apiRefreshRequest(context));
      locationStoreLoad(Latitude, Longitude, context);
    } else {
      // _showToast(message);
      return _categoryList;
    }
  }
}

void getLocationNotificationDetail(String id) async {
  var callUserLoginCheck = await internetConnectionState();
  if (callUserLoginCheck == true) {
    Map map = {"notificationId": id};
    Map decoded = jsonDecode(
        await apiRequestMainPageWithOutCx(locationNotificationDetailUrl, map));
    String status = decoded['status'];
    String message = decoded['message'];
    if (status == success_status) {
      var recordList = decoded['record'];
      String type = recordList['type'];
      String store_id = recordList['store_id'];
      var notification_title = recordList['notification_title'];
      String notification_description = recordList['notification_description'];
      var notification_id = recordList['notification_id'];
      var products = recordList['products'];

      String store_name = recordList['store_name'];
      String offers = recordList['offers'];
      String name = recordList['name'];
      String description = recordList['description'];
      var type_id_detail = {
        'store_name': store_name,
        'offers': offers,
        'name': name,
        'description': description,
        'store_id': store_id,
      };
      String type_id = recordList['type_id'];
      var notification_image = recordList['notification_image'];
      var payloaddata = {
        "type": type,
        "id": type_id,
        "title": notification_title,
        "description": notification_description,
        "type_id_detail": type_id_detail,
        "beaconId": id,
        "notification_image": notification_image,
        "notification_id": notification_id,
        "products": products,
      };
      navigatorKey.currentState!.pushReplacement(
          MaterialPageRoute(builder: (_) => TabBarController(0)));
      if (type == '1') {
        navigatorKey.currentState!
            .push(MaterialPageRoute(builder: (_) => NewScreen(payloaddata)));
      } else {
        navigatorKey.currentState!
            .push(MaterialPageRoute(builder: (_) => NotificationTabs()));
      }
    } else if (status == unauthorized_status) {
    } else if (status == already_login_status) {
    } else if (status == data_not_found_status) {
    } else if (status == expire_token_status) {
      Map decoded = jsonDecode(await apiRefreshRequestNotCX());
      getLocationNotificationDetail(id);
    } else {}
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

/*
import 'dart:convert';
import 'package:avauserapp/components/Location/CurrentLocation.dart';
import 'package:avauserapp/components/longLog.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<List> locationStoreLoad(context,Latitude,Longitude) async {
  List _categoryList =[];


  // Map map = {"latitude": Latitude, "longitude": Longitude, "range": "500"};
  Map map = {
    "latitude":"23.2599",
    "longitude":"77.4126",
    "range":"50000"
  };
  Map categoryList =
      jsonDecode(await apiRequestMainPage(locationStoresUrl, map, context));

  String status = categoryList['status'];
  String message = categoryList['message'];
  if (status == success_status) {
    var record = categoryList['record'];

    for (int i = 0; i < record.length; i++) {
      _categoryList.add({
        "id": record[i]['id'],
        "store_name": record[i]['store_name'],
        "store_latitude": record[i]['store_latitude'],
        "store_longitude": record[i]['store_longitude'],
      });
    }
    return _categoryList;
  } else if (status == unauthorized_status) {
    await checkLoginStatus(context);
    return _categoryList;
  } else if (status == expire_token_status) {
    Map decoded = jsonDecode(await apiRefreshRequest(context));
    locationStoreLoad(context,Latitude,Longitude);
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
*/
