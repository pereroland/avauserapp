import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/shimmerEffects/sizeImageShimmer.dart';
import 'package:avauserapp/screens/home/askForPermissionBeacon.dart';
import 'package:avauserapp/screens/notification/push_camp_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class BeaconNotificationDetail extends StatefulWidget {
  @override
  _NotificationDetail createState() => _NotificationDetail();
}

class _NotificationDetail extends State<BeaconNotificationDetail>
    with AutomaticKeepAliveClientMixin<BeaconNotificationDetail> {
  var dataLoad = false;
  bool tapLoad = false;
  var data;
  var STORES = "";
  late Map myLang;
  List _list = [];
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  var dataFound = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    myLangGet(0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: dataLoad
              ? dataFound
              ? RefreshIndicator(
            key: refreshKey,
            child: ListView.builder(
                itemCount: _list.length,
                itemBuilder: (BuildContext context, int index) {
                  return notificationItem(_list, index, context);
                }),
            onRefresh: () => myLangGet(0),
          )
              : RefreshIndicator(
            key: refreshKey,
            child: Container(
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                      child:
                      Image.asset("assets/noproductfound.webp")),
                ),
              ),
            ),
            onRefresh: () => myLangGet(0),
          )
              : Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: Center(
              child: Image.asset("assets/storeloadding.gif"),
            ),
          ),
        ),
        if (tapLoad)
          Container(
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Image.asset("assets/storeloadding.gif"),
            ),
          ),
      ],
    );
  }

  Future<void> myLangGet(int page) async {
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck == true) {
      Map map = {"page_no": "${page + 1}"};
      Map decoded =
      jsonDecode(await apiRequestMainPage(beaconNotificationsUrl, map));
      String status = decoded['status'];
      if (status == success_status) {
        for (int i = 0; i < decoded['record']['data'].length; i++) {
          if (!_list.any((element) =>
          element["campaign_id"] ==
              decoded['record']['data'][i]["campaign_id"])) {
            _list.add(decoded['record']['data'][i]);
          }
        }
        if (_list.length > 0) {
          if (mounted)
            setState(() {
              dataLoad = true;
              dataFound = true;
            });
        } else {
          if (mounted)
            setState(() {
              dataLoad = false;
              dataFound = false;
            });
        }
        if (mounted) myLangGet(page + 1);
      } else if (status == unauthorized_status) {
        await checkLoginStatus(context);
      } else if (status == already_login_status) {
      } else if (status == data_not_found_status) {
        if (mounted && page == 0)
          setState(() {
            dataLoad = true;
            dataFound = false;
          });
      } else if (status == expire_token_status) {
        jsonDecode(await apiRefreshRequest(context));
      } else {}
    }
  }

  spaceHeight() {
    return SizedBox(height: 10.0);
  }

  DateTime? convertStringToDateTime(String endTime) {
    try {
      String year = endTime.substring(6, 10);
      String month = endTime.substring(3, 5);
      String day = endTime.substring(0, 2);
      String hour = endTime.substring(11, 13);
      String minute = endTime.substring(14, 16);
      String amPm = endTime.substring(17, 19);
      if (amPm == "PM" || amPm.toLowerCase() == "pm") {
        hour = (int.parse(hour) + 12).toString();
        if (int.parse(hour) >= 24) {
          hour = (int.parse(hour) - 1).toString();
        }
      }
      return DateTime.parse("$year-$month-$day $hour:$minute:00").toLocal();
    } catch (_) {
      return null;
    }
  }

  notificationItem(_list, int index, BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: GestureDetector(
        child: Container(
          child: Card(
            color: Colors.white,
            child: Slidable(
              child: Container(
                color: Colors.white,
                child: ListTile(
                  onTap: () {
                    if (!tapLoad) onPressedCall(index);
                  },
                  title: Text(
                    setName(_list, index),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    serDescription(_list, index),
                    style: TextStyle(color: AppColours.blacklightLineColour),
                    maxLines: 2,
                  ),
                ),
              ),
              startActionPane: ActionPane(
                motion: Container(),
                children: [
                  IconButton(
                    tooltip: 'Archive',
                    color: Colors.blue,
                    icon: Icon(Icons.archive),
                    onPressed: () {},
                  ),
                  IconButton(
                    tooltip: 'Share',
                    color: Colors.indigo,
                    icon: Icon(Icons.share),
                    onPressed: () {},
                  ),
                ],
              ),
              endActionPane: ActionPane(
                motion: Container(),
                children: [
                  IconButton(
                    tooltip: 'More',
                    color: Colors.black45,
                    icon: Icon(Icons.more_horiz),
                    onPressed: () {},
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    color: Colors.red,
                    icon: Icon(Icons.delete),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onPressedCall(int index) async {
    DateTime? endTime = convertStringToDateTime(_list[index]["end_time"]);
    if (endTime == null) {
      return;
    }
    if (DateTime.now().isBefore(endTime)) {
      if (_list[index]["type"].toString() == "1") {
        tapLoad = true;
        if (mounted) setState(() {});
        Map payloaddata;
        var callUserLoginCheck = await internetConnectionState();
        if (callUserLoginCheck == true) {
          String referenceId = _list[index]["beacon_id"];
          Map map = {
            "beaconId": referenceId,
            "campId": _list[index]["campaign_id"],
            "notificationId": _list[index]["id"]
          };
          Map decoded =
          jsonDecode(await apiRequestMainPage(getCampDetailUrl, map));
          updateNotificationStatus(_list[index]["id"], context);
          tapLoad = false;
          if (mounted) setState(() {});
          String status = decoded['status'];
          if (status == success_status) {
            List record = decoded['record'];
            var recordList = record[0];
            var type = recordList['type'];
            var notification_title = recordList['notification_title'];
            var notification_id = recordList['notification_id'];
            String notification_description =
            recordList['notification_description'];
            String type_id = recordList['type_id'];
            var notification_image = recordList['notification_image'];
            var products = recordList['products'];
            String store_id = recordList['store_id'];
            String store_name = recordList['store_name'];
            String offers = recordList['offers'] ?? "";
            String name = recordList['name'];
            String description = recordList['description'];
            var type_id_detail = {
              'store_name': store_name,
              'offers': offers,
              'name': name,
              'description': description,
              'store_id': store_id
            };
            payloaddata = {
              "type": type,
              "id": type_id,
              "title": notification_title,
              "description": notification_description,
              "type_id_detail": type_id_detail,
              "beaconId": referenceId,
              "notification_image": notification_image,
              "notification_id": notification_id,
              "products": products,
            };
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NewScreen(payloaddata)),
            );
          }
        }
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PushCampDetails(
              details: _list[index],
            ),
          ),
        );
      }
    } else {
      showToast(allTranslations.text("campaign_expired"));
    }
  }
}

setName(_list, index) {
  var name = "";
  if (_list[index]['type'].toString() == "2") {
    name = _list[index]['notification_title'];
  } else {
    name = _list[index]['name'];
  }
  return name;
}

serDescription(_list, index) {
  var description = "";
  if (_list[index]['type'].toString() == "2") {
    description = _list[index]['notification_description'];
  } else {
    description = _list[index]['description'];
  }
  return description;
}

class ShowData extends StatelessWidget {
  ShowData(this.list, this.index, this.context);

  var list;
  var index;
  BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: list[index]['notification_image'],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => sizeImageShimmer(
                        context,
                        MediaQuery.of(context).size.width,
                        MediaQuery.of(context).size.height / 1.5),
                    errorWidget: (context, url, error) => Image.asset(
                      "assets/nodata.webp",
                      fit: BoxFit.cover,
                    ),
                    width: double.maxFinite,
                    height: MediaQuery.of(context).size.height / 1.5,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10.0, 40.0, 10.0, 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 8,
                          child: Text(
                            allTranslations.text('storeName'),
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(':'),
                        ),
                        Expanded(
                          flex: 8,
                          child: Text(
                            list[index]['store_name'],
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    spaceHeight(context),
                    spaceHeight(context),
                    Text(
                      setName(list, index),
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    spaceHeight(context),
                    spaceHeight(context),
                    Text(
                      serDescription(list, index),
                      style: allStyle(),
                    ),
                    spaceHeight(context),
                    spaceHeight(context),
                    spaceHeight(context),
                    spaceHeight(context),
                    spaceHeight(context),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            allTranslations.text('start'),
                            style: allStyle(),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(':'),
                        ),
                        Expanded(
                          flex: 8,
                          child: Text(
                            list[index]['start_time'],
                            style: allStyle(),
                          ),
                        ),
                      ],
                    ),
                    spaceHeight(context),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            allTranslations.text('end'),
                            style: allStyle(),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(':'),
                        ),
                        Expanded(
                          flex: 8,
                          child: Text(
                            list[index]['end_time'],
                            style: allStyle(),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }

  spaceHeight(BuildContext context) {
    return SizedBox(
      height: 10.0,
    );
  }

  allStyle() {
    return TextStyle(fontSize: 20.0, fontFamily: 'Montserrat');
  }
}
