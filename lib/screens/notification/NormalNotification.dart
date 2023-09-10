import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/shimmerEffects/sizeImageShimmer.dart';
import 'package:avauserapp/screens/notification/payment_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NormalNotificationDetail extends StatefulWidget {
  final int? notificationId;

  const NormalNotificationDetail({this.notificationId});

  @override
  _NotificationDetail createState() => _NotificationDetail();
}

class _NotificationDetail extends State<NormalNotificationDetail>
    with AutomaticKeepAliveClientMixin<NormalNotificationDetail> {
  var dataLoad = false;
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
    myLangGet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: dataLoad
          ? dataFound
              ? RefreshIndicator(
                  key: refreshKey,
                  child: ListView.builder(
                    itemCount: _list.length,
                    itemBuilder: (BuildContext context, int index) {
                      return notificationItem(_list, index, context);
                    },
                  ),
                  onRefresh: myLangGet,
                )
              : RefreshIndicator(
                  key: refreshKey,
                  child: Container(
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        child: Center(
                            child: Image.asset("assets/noproductfound.webp")),
                      ),
                    ),
                  ),
                  onRefresh: myLangGet,
                )
          : Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
              child: Center(
                child: Image.asset("assets/storeloadding.gif"),
              ),
            ),
    );
  }

  Future<void> myLangGet() async {
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck == true) {
      Map map = {"page_no": ""};
      Map decoded =
          jsonDecode(await apiRequestMainPage(appNotificationsUrl, map));
      String status = decoded['status'];
      if (status == success_status) {
        _list = decoded['record']['data'];
        if (_list.any((element) =>
            element["id"].toString() == widget.notificationId.toString())) {
          fullDetailNotification(
              _list,
              _list.indexWhere((element) =>
                  element["id"].toString() == widget.notificationId.toString()),
              context);
        }
        if (_list.length > 0) {
          setState(() {
            dataLoad = true;
            dataFound = true;
          });
        } else {
          setState(() {
            dataLoad = false;
            dataFound = false;
          });
        }
      } else if (status == unauthorized_status) {
        await checkLoginStatus(context);
      } else if (status == already_login_status) {
      } else if (status == data_not_found_status) {
        if (mounted)
          setState(() {
            dataLoad = true;
            dataFound = false;
          });
      } else {}
    }
  }

  spaceHeight() {
    return SizedBox(height: 10.0);
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
                  title: setName(_list, index),
                  subtitle: serDescription(_list, index),
                ),
              ),
            ),
          ),
        ),
        onTap: () {
          fullDetailNotification(_list, index, context);
        },
      ),
    );
  }

  void fullDetailNotification(_list, index, context) {
    String subTitle = _list[index]['payload']['body'];
    String? firstText;
    String? secondText;
    if (subTitle.contains("http")) {
      firstText = subTitle.substring(0, subTitle.indexOf("http"));
      secondText =
          subTitle.substring(subTitle.indexOf("http"), subTitle.length);
    }
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            _list[index]['payload']['title'],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                firstText != null && secondText != null
                    ? RichText(
                        text: TextSpan(children: [
                        TextSpan(
                            text: firstText,
                            style: TextStyle(color: Colors.black)),
                        TextSpan(
                            text: secondText,
                            style: TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PaymentPage(
                                            paymentUrl: secondText!)));
                                Navigator.pop(context);
                                // if (await canLaunchUrl(
                                //     Uri.parse(secondText!))) {
                                //   Navigator.pop(context);
                                //   launchUrl(Uri.parse(secondText),
                                //       webOnlyWindowName: "Payment");
                                // } else {
                                //   showToast("We not able to launch this url");
                                // }
                              }),
                      ], style: TextStyle()))
                    : Text(
                        subTitle,
                        style: TextStyle(color: Colors.black),
                      ),
                SizedBox(
                  height: 10.0,
                ),
                imageCheck(_list, index, context),
              ],
            ),
          ),
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(10.0),
          ),
        );
      },
    );
  }

  setName(list, index) {
    return Text(
      _list[index]['payload']['title'],
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  serDescription(_list, index) {
    return Html(
      data: _list[index]['payload']['body'] ?? "",
    );
  }

  imageCheck(list, index, BuildContext context) {
    var imageCheck = "";
    imageCheck = _list[index]['payload']['image'].toString();
    if (imageCheck == 'null') {
      return SizedBox.shrink();
    } else {
      return CachedNetworkImage(
        imageUrl: imageCheck,
        fit: BoxFit.fill,
        placeholder: (context, url) =>
            sizeImageShimmer(context, MediaQuery.of(context).size.width, 164.0),
        errorWidget: (context, url, error) => Image.asset(
          "Images/userimage.png",
          fit: BoxFit.cover,
        ),
        width: MediaQuery.of(context).size.width,
        height: 164,
      );
    }
  }
}
