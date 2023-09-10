import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/language/languageSelected.dart';
import 'package:avauserapp/components/launchurl.dart';
import 'package:avauserapp/components/models/LocationModel.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/resource/resource.dart';
import 'package:avauserapp/components/shimmerEffects/imageloadshimmer.dart';
import 'package:avauserapp/components/widget/button.dart';
import 'package:avauserapp/screens/product/productList.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class NearByContact extends StatefulWidget {
  List<LocationModel> listNearBy;
  var currentLat;
  var currentLng;

  NearByContact(
      {Key? key, required this.listNearBy, this.currentLat, this.currentLng});

  @override
  _nearByContact createState() => _nearByContact(listNearBy);
}

class _nearByContact extends State<NearByContact> {
  List<LocationModel> listNearBy;

  _nearByContact(this.listNearBy);

  TextEditingController titleController = new TextEditingController();
  Map? myLang;
  String nearByContacts = "",
      requestContact = "",
      welcomeTxtheaderDetail = "",
      userId = "",
      send = "",
      pending = "",
      cancel = "",
      request = "",
      call = "",
      internet_connection_mesage = "",
      message = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myLangGet();
    // new FirebaseChat().setUpFirebase(context);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            allTranslations.text('nearByStore'),
            style: TextStyle(color: AppColours.appTheme, fontSize: 16.0),
          ),
          centerTitle: true,
          backgroundColor: AppColours.whiteColour,
        ),
        body: SingleChildScrollView(
            child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: listNearBy.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListData(listNearBy, index, context);
                })

            /* Column(children: <Widget>[
            Card(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: Resource.space.huge,
                  ),
                  titleFiled(),
                  buttonContactData(),
                  SizedBox(
                    height: Resource.space.xMedium,
                  ),
                ],
              ),
            ),
            Card(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: Resource.space.huge,
                  ),
                  titleFiled(),
                  SizedBox(
                    height: Resource.space.xMedium,
                  ),
                  buttonAddContactData(),
                  SizedBox(
                    height: Resource.space.xMedium,
                  ),
                ],
              ),
            ),
            Card(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: Resource.space.huge,
                  ),
                  titleFiled(),
                  SizedBox(
                    height: Resource.space.xMedium,
                  ),
                  buttonAddContactData(),
                  SizedBox(
                    height: Resource.space.xMedium,
                  ),
                ],
              ),
            ),
          ]),*/
            ));
  }

  void clickRequestPopup(listNearBy, index, context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Text(
                requestContact,
                style: TextStyle(
                    color: AppColours.appTheme, fontWeight: FontWeight.bold),
              ),
              Padding(
                  padding: EdgeInsets.fromLTRB(80.0, 0.0, 80.0, 10.0),
                  child: Divider(
                    color: AppColours.redColour,
                    thickness: 1.0,
                  )),
              SizedBox(
                height: Resource.space.medium,
              ),
              Text(welcomeTxtheaderDetail),
              Image.asset('assets/logo.png'),
              Padding(
                padding: EdgeInsets.fromLTRB(40.0, 2.0, 40.0, 0.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ButtonTheme(
                        minWidth: 200.0,
                        height: 40.0,
                        buttonColor: AppColours.appTheme,
                        child: MaterialButton(
                          color: AppColours.appTheme,
                          shape: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColours.appTheme),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          onPressed: () async {
//                            Navigator.pop(context);
                            /*   Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => InviteContact(listNearBy[index].id)));*/
                            myDiscoveryModeChange(listNearBy[index].id, context,
                                internet_connection_mesage);
                            // Navigator.pushReplacement(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => MyHome(0)));
                          },
                          child: Text(
                            send,
                            style: TextStyle(
                                fontSize: 16.0, color: AppColours.whiteColour),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 2.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ButtonTheme(
                        minWidth: 200.0,
                        height: 40.0,
                        buttonColor: AppColours.whiteColour,
                        child: MaterialButton(
                          elevation: 0.0,
                          shape: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColours.appTheme),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                          child: Text(
                            cancel,
                            style: TextStyle(
                                fontSize: 16.0, color: AppColours.appTheme),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ])),
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          );
        });
  }

  addImage() {
    return Hero(
        tag: "speed-dial-hero-tag",
        child: GestureDetector(
          onTap: () {},
          child: Icon(
            IconData(
              0xe900,
              fontFamily: 'upload',
            ),
            color: AppColours.appTheme,
            size: 62.0,
          ),
        ));
  }

  titleFiled(List<LocationModel> listNearBy, int index, BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 0.0),
        child: Column(
          children: <Widget>[
            new Row(
              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: CachedNetworkImage(
                          height: MediaQuery.of(context).size.height / 8,
                          imageUrl: listNearBy[index].store_logo,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              imageShimmer(context, 58.0),
                          errorWidget: (context, url, error) => Image.asset(
                            "Images/userimage.png",
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    )),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                      text: listNearBy[index].store_name,
                                      style: TextStyle(
                                          color: AppColours.blackColour,
                                          fontSize: 16.0)),
                                  TextSpan(
                                      text: " (" +
                                          listNearBy[index].distance +
                                          " km"
                                              ")",
                                      style: TextStyle(
                                          color: AppColours.blackColour,
                                          fontSize: 16.0)),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: SizedBox.shrink(),
                          ),
                          Expanded(
                            flex: 1,
                            child: IconButton(
                                icon: Icon(Icons.navigation,
                                    color: AppColours.appTheme),
                                onPressed: () {
                                  var Latitude = double.parse(
                                      listNearBy[index].store_latitude);
                                  var Longitude = double.parse(
                                      listNearBy[index].store_longitude);
                                  launchMapsUrl(Latitude, Longitude, "Map");
                                }),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: Resource.space.large,
                      ),
                      Text(
                        listNearBy[index].store_description,
                        style: TextStyle(fontSize: 16.0),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              allTranslations.text('open'),
                              maxLines: 2,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              listNearBy[index].open_time,
                              maxLines: 2,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              allTranslations.text('close'),
                              maxLines: 2,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              listNearBy[index].close_time,
                              maxLines: 2,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  buttonContactData(listNearBy, index, context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
        child: Container(
          child: new Container(
              child: new Row(
            children: <Widget>[
              Expanded(flex: 1, child: callBtn(listNearBy, index, context)),
              Expanded(flex: 1, child: messageBtn(listNearBy, index, context)),
            ],
          )),
        ));
  }

  Widget requestBtn(listNearBy, index, context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 2.0),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 10.0,
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: EdgeInsets.only(left: 0.0),
              child: ButtonTheme(
                minWidth: 120.0,
                height: 40.0,
                buttonColor: AppColours.whiteColour,
                child: MaterialButton(
                  elevation: 0.0,
                  shape: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColours.appTheme),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Product(
                              storeName: listNearBy[index].store_name,
                              Id: listNearBy[index].id,
                              isFav: false)),
                    );
                    // clickRequestPopup(listNearBy, index, context);
                  },
                  child: Text(
                    allTranslations.text('ViewStore'),
                    style:
                        TextStyle(fontSize: 16.0, color: AppColours.appTheme),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 5.0,
          ),
          Expanded(
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: fullColouredBtn(
                    colors: Colors.red,
                    radiusButtton: 10.0,
                    text: "YANGO",
                    onPressed: () {
                      var Latitude =
                          double.parse(listNearBy[index].store_latitude);
                      var Longitude =
                          double.parse(listNearBy[index].store_longitude);
                      launchMapsUrl(Latitude, Longitude, "YANGO",
                          currentLat: widget.currentLat,
                          currentLng: widget.currentLng,
                          startLocationName: "Your Location",
                          endLocationName: listNearBy[index].store_name);
                      //  [widget.currentLat,widget.currentLng]
                    })),
            flex: 4,
          ),
          SizedBox(
            width: 5.0,
          ),
          Expanded(
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: fullColouredBtn(
                    colors: Colors.black,
                    radiusButtton: 10.0,
                    text: "Uber",
                    onPressed: () {
                      var Latitude =
                          double.parse(listNearBy[index].store_latitude);
                      var Longitude =
                          double.parse(listNearBy[index].store_longitude);
                      launchMapsUrl(Latitude, Longitude, "Uber",
                          currentLat: widget.currentLat,
                          currentLng: widget.currentLng,
                          startLocationName: "Your Location",
                          endLocationName: listNearBy[index].store_name);
                      //  [widget.currentLat,widget.currentLng]
                    })),
            flex: 4,
          ),
          SizedBox(
            width: 10.0,
          )
        ],
      ),
    );
  }

  Widget callBtn(listNearBy, index, context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 2.0, 5.0, 2.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: ButtonTheme(
              minWidth: 200.0,
              height: 40.0,
              buttonColor: AppColours.whiteColour,
              child: MaterialButton(
                  elevation: 0.0,
                  shape: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColours.appTheme),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  onPressed: () {
                    var callNumber = listNearBy[index].country_code +
                        "" +
                        listNearBy[index].phone_number;
                    if (callNumber.toString().contains("+")) {
                      callNumber = callNumber.toString().replaceAll("+", "");
                    }
                    callNumber = "+" + callNumber;
                    launch("tel:" + Uri.encodeComponent('$callNumber'));
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.call,
                        color: AppColours.appTheme,
                      ),
                      SizedBox(
                        width: Resource.space.medium,
                      ),
                      Text(
                        call,
                        style: TextStyle(
                            fontSize: 16.0, color: AppColours.appTheme),
                      ),
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget messageBtn(listNearBy, index, context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 2.0, 10.0, 2.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: ButtonTheme(
              minWidth: 200.0,
              height: 40.0,
              buttonColor: AppColours.whiteColour,
              child: MaterialButton(
                elevation: 0.0,
                shape: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColours.appTheme),
                  borderRadius: BorderRadius.circular(10.0),
                ),
//                onPressed: ()=>launch("sms://" + listNearBy[index].phone_number),
                onPressed: () {
                  chatUserOpen(
                      listNearBy[index].id, listNearBy[index].devide_token);
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.message,
                      color: AppColours.appTheme,
                    ),
                    SizedBox(
                      width: Resource.space.medium,
                    ),
                    Text(
                      message,
                      style:
                          TextStyle(fontSize: 16.0, color: AppColours.appTheme),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  buttonAddContactData(listNearBy, index, context) {
    return requestBtn(listNearBy, index, context);
  }

  Future<void> myLangGet() async {
    Map myLangData = await langTxt(context);
    setState(() {
      myLang = myLangData;
      if (myLang != null) {
        nearByContacts = myLang!['nearByContacts'];
        requestContact = myLang!['requestContact'];
        welcomeTxtheaderDetail = myLang!['welcomeTxtheaderDetail'];
        send = myLang!['send'];
        pending = myLang!['pending'];
        cancel = myLang!['cancel'];
        request = myLang!['request'];
        call = myLang!['call'];
        internet_connection_mesage = myLang!['internet_connection_mesage'];
        message = myLang!['message'];
      }
    });
    // var check = myLang['email'];
  }

  Widget ListData(
      List<LocationModel> listNearBy, int index, BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: Resource.space.huge,
          ),
          titleFiled(listNearBy, index, context),
          buttonSet(listNearBy, index, context),
          SizedBox(
            height: Resource.space.xMedium,
          ),
        ],
      ),
    );
  }

  buttonSet(listNearBy, index, context) {
    return buttonAddContactData(listNearBy, index, context);
/*    if (listNearBy[index].status == "0") {
      return buttonAddContactData(listNearBy, index, context);
    } else if (listNearBy[index].status == "1") {
      return pendingBtn(listNearBy, index, context);
    } else if (listNearBy[index].status == "2") {
      return buttonAddContactData(listNearBy, index, context);
    } else if (listNearBy[index].status == "3") {
      return buttonContactData(listNearBy, index, context);
    } else if (listNearBy[index].status == "4") {
      return pendingBtn(listNearBy, index, context);
    } else {
      return pendingBtn(listNearBy, index, context);
    }*/
  }

  Widget pendingBtn(listNearBy, index, context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(50.0, 2.0, 50.0, 2.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: ButtonTheme(
              minWidth: 120.0,
              height: 40.0,
              buttonColor: AppColours.blacklightLineColour,
              child: MaterialButton(
                elevation: 0.0,
                shape: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: AppColours.blacklightLineColour),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                onPressed: () async {
//                clickRequestPopup(listNearBy, index,context);
                },
                child: Text(
                  pending,
                  style:
                      TextStyle(fontSize: 16.0, color: AppColours.whiteColour),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void chatUserOpen(idUser, devide_token) {
    // Navigator.of(context).push(new ChatPageRoute(idUser,devide_token));
  }
}

Future<void> myDiscoveryModeChange(
    String memberId, context, internet_connection_mesage) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userId;
  userId = prefs.getString('userId') ?? "";
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      Map map = {"request_by": userId, "request_for": memberId, "note": ""};
      Map decoded =
          jsonDecode(await apiRequestMainPage('addContactUserUrl', map));
      String status = decoded['status'];
      String message = decoded['message'];
      if (status == success_status) {
      } else if (status == unauthorized_status) {
        await checkLoginStatus(context);
      } else if (status == "408") {
        Map decoded = jsonDecode(await apiRefreshRequest(context));
        myDiscoveryModeChange(memberId, context, internet_connection_mesage);
      } else {
        _showToast(context, message);
      }
      _showToast(context, message);
    }
  } on SocketException catch (_) {
    _showToast(context, internet_connection_mesage);
  }
}

_showToast(BuildContext context, String message) {
  if (message.toLowerCase() != "success")
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0);
}

void launchMapsUrl(double lat, double lon, var type,
    {var currentLat,
    var currentLng,
    var startLocationName,
    var endLocationName}) async {
  String url = '';
  if (type == "Map") {
    url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
  } else if (type == "Uber") {
    var client_id = "q-xxt0DHW-llMZsQneJeO_MsYE6VR4tB";
    var product_id = "a1111c8c-c720-46c3-8534-2fcdd730040d ";
    var addressStart = startLocationName;
    var addressEnd = endLocationName;

    final _authority = "m.uber.com";
    final _path = "/ul";
    final _params = {
      "client_id": client_id.toString(),
      "action": "setPickup",
      "pickup[latitude]": currentLat.toString(),
      "pickup[longitude]": currentLng.toString(),
      "pickup[nickname]": "UberHQ",
      "pickup[formatted_address]": "",
      "dropoff[latitude]": lat.toString(),
      "dropoff[longitude]": lon.toString(),
      "dropoff[nickname]": "",
      "dropoff[formatted_address]": addressEnd.toString(),
    };
    url = Uri.https(_authority, _path, _params).toString();
    print("URLLL: $url");
  } else {
    var app_code = "2187871";
    var ref = "ak210705";
    var appmetrica_tracking_id = "386659076819479524";
    var level = "50";

    // url = 'https://$app_code.redirect.appmetrica.yandex.com/route?start-lat=$currentLat&start-lon=$currentLng&end-lat=$lat&end-lon=$lon&level=$level&ref=$ref&appmetrica_tracking_id=$appmetrica_tracking_id';
    url =
        'https://$app_code.redirect.appmetrica.yandex.com/route?start-lat=$currentLat&start-lon=$currentLng&end-lat=$lat&end-lon=$lon&level=$level&ref=$ref&appmetrica_tracking_id=$appmetrica_tracking_id';
  }
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchURL(url);
  } else {
    throw 'Could not launch $url';
  }

  /*document link for uber and yandex
   is ,
  yandex:- https://yandex.com/dev/taxi/doc/dg/concepts/deeplinks.html#deeplinks
  uber:- https://developer.uber.com/docs/riders/ride-requests/tutorials/deep-links/introduction*/
}
