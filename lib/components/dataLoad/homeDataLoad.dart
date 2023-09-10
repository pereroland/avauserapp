import 'dart:convert';

import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/screens/notification/push_notification_handle.dart';
import 'package:flutter_udid/flutter_udid.dart';

Future<Map?> callHomeLoad(context, String city) async {
  var internetConnectionCheck = await internetConnectionState();
  var url = bannersUrl + city;
  if (internetConnectionCheck == true) {
    Map decoded = jsonDecode(await getApiDataRequest(url, context));
    return decoded;
  }
}

Future<void> callCampaign(context,
    {required String lat, required String long}) async {
  var internetConnectionCheck = await internetConnectionState(false);
  var url = baseUrl + nearByBeacon;
  if (internetConnectionCheck == true) {
    try {
      String deviceId = await FlutterUdid.udid;
      Map data = jsonDecode(await apiRequest(
          url,
          {
            "latitude": lat,
            "longitude": long,
            "range": "10",
            "device_id": deviceId
          },
          context));
      String status = data['status'];
      ;
      if (status == success_status) {
        List record = data['record'];
        for (int i = 0; i < record.length; i++) {
          var recordList = record[i];
          var type = recordList['type'];
          var notificationTitle = recordList['notification_title'];
          var notificationId = recordList['notification_id'];
          String notificationDescription =
              recordList['notification_description'];
          String typeId = recordList['type_id'];
          var notificationImage = recordList['notification_image'];
          var products = recordList['products'];
          String storeId = recordList['store_id'];

          String storeName = recordList['store_name'];
          String offers = recordList['offers'];
          String name = recordList['name'];
          String description = recordList['description'];
          var typeIdDetail = {
            'store_name': storeName,
            'offers': offers,
            'name': name,
            'description': description,
            'store_id': storeId
          };
          Map payloadData = {
            "type": type == "2" ? "80" : "70",
            "id": typeId,
            "campaign_id": recordList["id"],
            "title": notificationTitle,
            "description": notificationDescription,
            "type_id_detail": typeIdDetail,
            "beaconId": recordList["beacon_id"],
            "notification_image": notificationImage,
            "notification_id": notificationId,
            "products": products,
          };
          String mapData = json.encode(payloadData);
          await LocalNotification().showNotification(notificationTitle, mapData,
              notificationDescription, DateTime.now().millisecond);
        }
      }
    } catch (_) {}
  }
}
