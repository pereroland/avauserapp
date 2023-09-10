import 'dart:async';
import 'dart:convert' as json;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:avauserapp/components/Location/CurrentLocation.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/models/nearby.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/shimmerEffects/fullScreenLoadShimmer.dart';
import 'package:avauserapp/components/widget/button.dart';
import 'package:avauserapp/screens/Event/EventDetail.dart';
import 'package:avauserapp/screens/mapItemsList/NearByContacts.dart';
import 'package:avauserapp/screens/product/productList.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/models/LocationModel.dart';
import 'baseTabClass.dart';

class MapWidget extends StatefulWidget {
  @override
  _MapWidget createState() => _MapWidget();
}

class _MapWidget extends State<MapWidget>
    with AutomaticKeepAliveClientMixin<MapWidget> {
  var dataLoad = true;
  var nearMe = "";
  var _lastMapPosition;
  Map? myLang;
  var dataFound = false;
  Completer<GoogleMapController> _controller = Completer();
  List<LocationModel> _list = [];
  final Set<Marker> _markers = {};
  var userId = "",
      profilePic = "",
      userFullName = "",
      userEmail = "",
      userImage = "";
  var storeAvailable = true;
  var Latitude;
  var Longitude;
  var detailBoxShow = false;
  var detailIconData;
  List<NearByEvents> listNearbyEvent = [];
  List<LocationModel> _markerLocations = [];

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void navigationClick(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventPageRoute(eventId: id),
      ),
    );
  }

  void _initMarkers() async {
    for (int i = 0; i < listNearbyEvent.length; i++) {
      LatLng _lastMapPositionPoints = LatLng(
          double.parse(listNearbyEvent[i].latitude),
          double.parse(listNearbyEvent[i].longitude));
      if (mounted)
        setState(() {
          final id = listNearbyEvent[i].id;
          _markers.add(Marker(
              markerId: MarkerId(id.toString()),
              position: _lastMapPositionPoints,
              infoWindow: InfoWindow(
                  title: listNearbyEvent[i].title,
                  snippet: listNearbyEvent[i].description,
                  onTap: () => navigationClick(id)),
              onTap: () {}));
        });
    }
    for (int i = 0; i < _list.length; i++) {
      Uint8List markerIcon;
      markerIcon = await getBytesFromAsset('assets/store_default_icon.png', 80);
      var Latitude = double.parse(_list[i].store_latitude);
      var Longitude = double.parse(_list[i].store_longitude);
      var markerLocation = LatLng(Latitude, Longitude);
      if (mounted)
        setState(() {
          _markers.add(Marker(
              markerId: MarkerId(LatLng(Latitude, Longitude).toString()),
              position: markerLocation,
              icon: BitmapDescriptor.fromBytes(markerIcon),
              infoWindow: InfoWindow(
                  title: _list[i].store_name,
                  snippet: _list[i].distance,
                  onTap: () {
                    showDialogMarker(i);
                  }),
              onTap: () {
                showDialogMarker(i);
              }));
        });
    }
  }

  @override
  void initState() {
    super.initState();
    myLangGet();
    validationCheck();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: dataLoad
            ? drawerData(
                context, userId, profilePic, userFullName, userEmail, userImage)
            : Text(allTranslations.text('nearMe')),
        appBar: AppBar(
          title: Text(
            allTranslations.text('nearMe'),
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: storeAvailable
            ? _lastMapPosition == null
                ? fullScreenShimmer(context)
                : Stack(
                    children: <Widget>[
                      GoogleMap(
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        mapToolbarEnabled: false,
                        initialCameraPosition: CameraPosition(
                            target: LatLng(double.parse(Latitude),
                                double.parse(Longitude)),
                            zoom: 14),
                        markers: _markers,
                        onMapCreated: (controller) => _onMapCreated(controller),
                      ),
                      if (detailBoxShow)
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding:
                                  EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 40.0),
                              child: Container(
                                  child: Stack(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                              border: Border.all(
                                                  width: 1,
                                                  color: Colors.blue,
                                                  style: BorderStyle.solid),
                                              color: Colors.white),
                                          height: 230,
                                          child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  12.0, 20.0, 12.0, 5.0),
                                              child: Scaffold(
                                                backgroundColor: Colors.white,
                                                body: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      detailIconData.store_name,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      height: 10.0,
                                                    ),
                                                    Text(
                                                      detailIconData
                                                          .store_description,
                                                      maxLines: 2,
                                                    ),
                                                    SizedBox(
                                                      height: 10.0,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 1,
                                                          child: Text(
                                                            allTranslations
                                                                .text('open'),
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Text(
                                                            detailIconData
                                                                .open_time,
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
                                                            allTranslations
                                                                .text('close'),
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Text(
                                                            detailIconData
                                                                .close_time,
                                                            maxLines: 2,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 15.0,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 15,
                                                          child: MaterialButton(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                                side: BorderSide(
                                                                    color: AppColours
                                                                        .appTheme)),
                                                            onPressed: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => Product(
                                                                        storeName:
                                                                            detailIconData
                                                                                .store_name,
                                                                        Id: detailIconData
                                                                            .id,
                                                                        isFav:
                                                                            false)),
                                                              );
                                                            },
                                                            color: AppColours
                                                                .appTheme,
                                                            textColor:
                                                                Colors.white,
                                                            child: Text(
                                                                allTranslations
                                                                    .text(
                                                                        'ViewStore'),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14)),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child:
                                                              SizedBox.shrink(),
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: IconButton(
                                                              icon: Icon(
                                                                Icons
                                                                    .navigation,
                                                                color: AppColours
                                                                    .appTheme,
                                                                size: 30.0,
                                                              ),
                                                              onPressed: () {
                                                                clickRedirection(
                                                                    3);
                                                              }),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child:
                                                              SizedBox.shrink(),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        buttons("YANGO",
                                                            Colors.red),
                                                        SizedBox(width: 5.0),
                                                        buttons("Uber",
                                                            Colors.black),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ))),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                      width: 40,
                                      margin: EdgeInsets.only(
                                          bottom: 205, left: 40.0),
                                      height: 40,
                                      child: FloatingActionButton(
                                        child: Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            detailBoxShow = false;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                            ))
                    ],
                  )
            : Stack(
                children: [
                  GoogleMap(
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    mapToolbarEnabled: false,
                    initialCameraPosition: CameraPosition(
                        target: LatLng(
                            double.parse(Latitude), double.parse(Longitude)),
                        zoom: 14),
                    markers: _markers,
                    onMapCreated: (controller) => _onMapCreated(controller),
                  ),
                ],
              ),
        floatingActionButton: detailBoxShow
            ? Text('')
            : Stack(
                children: <Widget>[
                  storeAvailable
                      ? Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(28.0, 0.0, 0.0, 20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                currentLocationFlBtn(),
                                appUserListFlBtn(),
                              ],
                            ),
                          ))
                      : SizedBox.shrink(),
                ],
              ));
  }

  Widget buttons(String title, Color color) {
    return Expanded(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: fullColouredBtn(
          colors: color,
          radiusButtton: 10.0,
          text: title,
          onPressed: () {
            clickRedirection(title == "Uber" ? 1 : 2);
          },
        ),
      ),
      flex: 4,
    );
  }

  currentLocationFlBtn() {
    return Padding(
        padding: EdgeInsets.only(bottom: 14.0),
        child: FloatingActionButton(
          heroTag: "start_home",
          backgroundColor: AppColours.appTheme,
          onPressed: () {},
          child: Icon(
            Icons.location_on,
            color: AppColours.whiteColour,
          ),
        ));
  }

  void clickRedirection(int type) {
    var latitude = double.parse(detailIconData.store_latitude);
    var longitude = double.parse(detailIconData.store_longitude);
    String storeName = "Your Location";
    if (type == 1) {
      launchMapsUrl(latitude, longitude, "Uber",
          currentLat: Latitude,
          currentLng: Longitude,
          startLocationName: storeName,
          endLocationName: detailIconData.store_name);
    } else if (type == 2) {
      launchMapsUrl(latitude, longitude, "YANGO",
          currentLat: Latitude,
          currentLng: Longitude,
          startLocationName: storeName,
          endLocationName: detailIconData.store_name);
    } else if (type == 3) {
      launchMapsUrl(latitude, longitude, "Map");
    }
  }

  appUserListFlBtn() {
    return Padding(
        padding: EdgeInsets.only(bottom: 14.0),
        child: FloatingActionButton(
          heroTag: "contact list",
          backgroundColor: AppColours.appTheme,
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NearByContact(
                        listNearBy: _list,
                        currentLat: Latitude,
                        currentLng: Longitude)));
          },
          child: Icon(
            Icons.list,
            color: AppColours.whiteColour,
          ),
        ));
  }

  Future<void> validationCheck() async {
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck == true) {
      callUSerStatusCheck();
    }
  }

  void callUSerStatusCheck() async {
    Map decodedLoc = await getLocation(context) ?? {};
    Latitude = decodedLoc['Latitude'].toString();
    Longitude = decodedLoc['Longitude'].toString();
    Map map = {"latitude": Latitude, "longitude": Longitude, "range": ""};
    Map decoded =
        json.jsonDecode(await apiRequestMainPage(nearbystoresUrl, map));
    String status = decoded['status'];
    String message = decoded['message'];
    if (status == success_status) {
      var data = decoded['record']['stores'];
      _list = data
          .map<LocationModel>((json) => LocationModel.fromJson(json))
          .toList();
      _list = {..._list}.toList();
      var nearby_event = decoded['record']['events'];
      listNearbyEvent = nearby_event
          .map<NearByEvents>((json) => NearByEvents.fromJson(json))
          .toList();
      if (_list.length > 0) {
        markerAdd(_list, Latitude, Longitude);
      } else {
        if (mounted)
          setState(() {
            _showToast(allTranslations.text("No_near_by_store_available"));
            storeAvailable = false;
          });
      }
      _initMarkers();
    } else if (status == unauthorized_status) {
      await checkLoginStatus(context);
    } else if (status == data_not_found_status) {
      _showToast(message);
    } else if (status == already_login_status) {
      _showToast(message);
    } else if (status == "408") {
      json.jsonDecode(await apiRefreshRequest(context));
      callUSerStatusCheck();
    } else {
      _showToast(message);
    }
    if (mounted)
      setState(() {
        dataLoad = true;
      });
  }

  Future<void> myLangGet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('email') ?? "";
      userId = prefs.getString('id') ?? "";
      userFullName = prefs.getString('full_name') ?? "";
      userImage = prefs.getString('image') ?? "";
      dataLoad = true;
    });
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> markerAdd(
      List<LocationModel> list, var latitude, var longitude) async {
    _markerLocations.addAll(list);
    if (mounted)
      setState(() {
        _lastMapPosition =
            LatLng(double.parse(latitude), double.parse(longitude));
        dataFound = true;
      });
  }

  @override
  bool get wantKeepAlive => true;

  void showDialogMarker(int i) {
    setState(() {
      detailIconData = _markerLocations[i];
      detailBoxShow = true;
    });
  }
}
