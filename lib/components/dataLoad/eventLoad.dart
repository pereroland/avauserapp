import 'dart:convert';

import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/longLog.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';

Future<Map?> eventDataListLoad(context) async {
  Map eventList =
      jsonDecode(await getApiDataRequest(clanAllEventsClanUrl, context));
  String status = eventList['status'];
  String message = eventList['message'];
  if (status == success_status) {
    return eventList;
  } else if (status == unauthorized_status) {
    await checkLoginStatus(context);
    return eventList;
  } else if (status == expire_token_status) {
    Map decoded = jsonDecode(await apiRefreshRequest(context));
    eventDataListLoad(context);
  } else {
    // showToast(message);
    return eventList;
  }
}

/*  Future<void> eventList() async {
    list =[];
    listhistory =[];
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        try {
          final result = await InternetAddress.lookup('google.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            Map map = {
              "page_no":"",
              "search":"",
              "category":"",
              "pending":"1"
            };
            Map decoded = jsonDecode(
                await apiRequestMainPage(eventListUrl, map, context));

            String status = decoded['status'];
            String message = decoded['message'];
            if (status == success_status) {
              var data = decoded['record']['upcommings'];
              var history = decoded['record']['pendings'];
              if(mounted)
              setState(() {
                list = data
                    .map<EventList>((json) => EventList.fromJson(json))
                    .toList();
                // listhistory = history
                //     .map<EventList>((json) => EventList.fromJson(json))
                //     .toList();
              });
            } else if (status == unauthorized_status) {
              await checkLoginStatus(context);
            } else if (status == data_not_found_status) {
              /* setState(() {
                data_not_found = false;
              });*/
            } else if (status == "408") {
              Map decoded = jsonDecode(await apiRefreshRequest(context));
              eventList();
            } else {
              _showToast(context, message);
            }
            setState(() {
              if (list.length > 0) {
                allEventsShow = true;
              } else {
                allEventsShow = false;
              }
              if (listhistory.length > 0) {
                allHistoryEventsShow = true;
              } else {
                allHistoryEventsShow = false;
              }
              dataLoad = true;
              refreshEventStatus = false;
              if (list.length == 0 &&
                  listRemain.length == 0 &&
                  listhistory.length == 0) {
                dataLoad = false;
                data_not_found = false;
              } else {}
            });
          }
        } on SocketException catch (_) {
          _showToast(context, internet_connection_mesage);
        }
      }
    } on SocketException catch (_) {
      _showToast(context, internet_connection_mesage);
    }
  }
*/
