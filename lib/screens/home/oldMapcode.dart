import 'dart:async';
import 'dart:convert' as json;
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:avauserapp/components/Location/CurrentLocation.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/mapCluster/helpers/map_helper.dart';
import 'package:avauserapp/components/mapCluster/helpers/map_marker.dart';
import 'package:avauserapp/components/models/nearby.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/shimmerEffects/fullScreenLoadShimmer.dart';
import 'package:avauserapp/screens/Event/EventDetail.dart';
import 'package:avauserapp/screens/mapItemsList/NearByContacts.dart';
import 'package:avauserapp/screens/product/productList.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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

  /// Minimum zoom at which the markers will cluster
  final int _minClusterZoom = 0;

  /// Maximum zoom at which the markers will cluster
  final int _maxClusterZoom = 19;

  /// [Fluster] instance used to manage the clusters
  Fluster<MapMarker>? _clusterManager;

  /// Current map zoom. Initial zoom will be 15, street level
  double _currentZoom = 14;

  /// Map loading flag
  bool _isMapLoading = true;

  /// Markers loading flag
  bool _areMarkersLoading = true;

  /// Url image used on normal markers
  final String _markerImageUrl =
      'https://img.icons8.com/office/80/000000/marker.png';

  /// Color of the cluster circle
  final Color _clusterColor = Colors.blue;

  /// Color of the cluster text
  final Color _clusterTextColor = Colors.white;

  List<LocationModel> _markerLocations = [];

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    setState(() {
      _isMapLoading = false;
    });

    _initMarkers();
//    _markers.add(Marker(
//        // This marker id can be anything that uniquely identifies each marker.
//        markerId: MarkerId(LatLng(Latitude, Longitude).toString()),
//        //_lastMapPosition is any coordinate which should be your default
//        //position when map opens up
//        position: LatLng(Latitude, Longitude),
//        infoWindow: InfoWindow(),
//        onTap: () {}));
  }

  /// Inits [Fluster] and all the markers with network images and updates the loading state.
  void _initMarkers() async {
    final List<MapMarker> markers = [];
    for (int i = 0; i < listNearbyEvent.length; i++) {
      LatLng _lastMapPositionPoints = LatLng(
          double.parse(listNearbyEvent[i].latitude),
          double.parse(listNearbyEvent[i].longitude));

      setState(() {
        markers.add(
          MapMarker(
            id: Longitude.toString(),
            position: _lastMapPositionPoints,
            onTapIcon: () {},
            infoWindows: InfoWindow(
                title: listNearbyEvent[i].title,
                snippet: listNearbyEvent[i].description,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EventPageRoute(
                              eventId: listNearbyEvent[i].id.toString())));
                }),
          ),
        );
      });
    }

    for (int i = 0; i < _markerLocations.length; i++) {
      Uint8List markerIcon;
      if (_markerLocations[i].store_on.toString() == "0") {
        markerIcon =
            await getBytesFromAsset('assets/closestorebeacon.webp', 125);
      } else if (_markerLocations[i].beacon_on.toString() == "1") {
        markerIcon = await getBytesFromAsset('assets/map.webp', 125);
      } else {
        markerIcon = await getBytesFromAsset('assets/closebeacon.webp', 125);
      }

      var Latitude = double.parse(_markerLocations[i].store_latitude);
      var Longitude = double.parse(_markerLocations[i].store_longitude);
      var markerLocation = LatLng(Latitude, Longitude);

      final int targetWidth = 120;
      final int targetHeight = 120;
      final File markerImageFile = await DefaultCacheManager()
          .getSingleFile(_markerLocations[i].store_logo);
      final Uint8List markerImageBytes = await markerImageFile.readAsBytes();

      final Codec markerImageCodec = await instantiateImageCodec(
          markerImageBytes,
          targetWidth: targetWidth,
          targetHeight: targetHeight);

      final FrameInfo frameInfo = await markerImageCodec.getNextFrame();
      final ByteData? byteData = await frameInfo.image.toByteData(
        format: ImageByteFormat.png,
      );

      final Uint8List resizedMarkerImageBytes = byteData!.buffer.asUint8List();

      markers.add(
        MapMarker(
          id: Longitude.toString(),
          position: markerLocation,
          icon: BitmapDescriptor.fromBytes(resizedMarkerImageBytes),
          onTapIcon: () {
            showDialogMarker(i);
          },
          infoWindows: InfoWindow(
              title: _markerLocations[i].store_name,
              snippet: _markerLocations[i].distance,
              onTap: () {
                showDialogMarker(i);
              }),
        ),
      );
      // _markers.add(Marker(
      //     icon: BitmapDescriptor.fromBytes(markerIcon),
      //     // This marker id can be anything that uniquely identifies each marker.
      //     markerId: MarkerId(LatLng(Latitude, Longitude).toString()),
      //     //_lastMapPosition is any coordinate which should be your default
      //     //position when map opens up
      //     position: LatLng(Latitude, Longitude),
      //     infoWindow: InfoWindow(
      //       title: list[i].store_name,
      //       snippet:
      //           "Distance :" + list[i].distance + " " + list[i].distance_unit,
      //     ),
      //     onTap: () {})
      // );
    }

/*    for (LatLng markerLocation in _markerLocations) {
      final BitmapDescriptor markerImage =
      await MapHelper.getMarkerImageFromUrl(_markerImageUrl);


    }*/

    _clusterManager = await MapHelper.initClusterManager(
      markers,
      _minClusterZoom,
      _maxClusterZoom,
    );

    await _updateMarkers();
  }

  /// Gets the markers and clusters to be displayed on the map for the current zoom level and
  /// updates state.
  Future<void> _updateMarkers([double? updatedZoom]) async {
    if (_clusterManager == null || updatedZoom == _currentZoom) return;

    if (updatedZoom != null) {
      _currentZoom = updatedZoom;
    }

    setState(() {
      _areMarkersLoading = true;
    });

    final updatedMarkers = await MapHelper.getClusterMarkers(
      _clusterManager!,
      _currentZoom,
      _clusterColor,
      _clusterTextColor,
      80,
    );
/*    _markers.add(Marker(
      // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(LatLng(Latitude, Longitude).toString()),
        //_lastMapPosition is any coordinate which should be your default
        //position when map opens up
        position: LatLng(Latitude, Longitude),
        infoWindow: InfoWindow(),
        onTap: () {}));*/
    _markers
      ..clear()
      ..addAll(updatedMarkers);

    setState(() {
      _areMarkersLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    myLangGet();
    validationCheck();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                      // Google Map widget
                      Opacity(
                        opacity: _isMapLoading ? 0 : 1,
                        child: GoogleMap(
                          onTap: (latlng) {
                            final RenderObject? renderBox =
                                context.findRenderObject();
                            // Rect _itemRect =
                            //     renderBox!.localToGlobal(Offset.zero) &
                            //       renderBox.size;
                          },
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          mapToolbarEnabled: false,
                          initialCameraPosition: CameraPosition(
                              target: _lastMapPosition, zoom: 14),
                          markers: _markers,
                          onMapCreated: (controller) =>
                              _onMapCreated(controller),
                          onCameraMove: (position) =>
                              _updateMarkers(position.zoom),
                        ),
                      ),

                      // Map loading indicator
                      Opacity(
                        opacity: _isMapLoading ? 1 : 0,
                        child: Center(child: CircularProgressIndicator()),
                      ),

                      // Map markers loading indicator
                      if (_areMarkersLoading)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Card(
                              elevation: 2,
                              color: Colors.grey.withOpacity(0.9),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Text(
                                  allTranslations.text('Loading'),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      detailBoxShow
                          ? Align(
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
                                            height: 170,
                                            child: Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    12.0, 20.0, 12.0, 5.0),
                                                child: Scaffold(
                                                  backgroundColor: Colors.white,
                                                  body: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        detailIconData
                                                            .store_name,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
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
                                                                  .text(
                                                                      'close'),
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
                                                    ],
                                                  ),
                                                  bottomNavigationBar: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 15,
                                                        child: MaterialButton(
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          18.0),
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
                                                              allTranslations.text(
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
                                                                    .appTheme),
                                                            onPressed: () {
                                                              var Latitude =
                                                                  double.parse(
                                                                      detailIconData
                                                                          .store_latitude);
                                                              var Longitude =
                                                                  double.parse(
                                                                      detailIconData
                                                                          .store_longitude);
                                                              launchMapsUrl(
                                                                  Latitude,
                                                                  Longitude);
                                                            }),
                                                      ),
                                                    ],
                                                  ),
                                                ))),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          bottom: 145, left: 40.0),
                                      child: Align(
                                        alignment: Alignment.bottomRight,
                                        child: SizedBox(
                                          width: 40,
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
                                    ),
                                  ],
                                )),
                              ))
                          : SizedBox.shrink(),
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
                    onCameraMove: (position) => _updateMarkers(position.zoom),
                  ),
                ],
              ) /*GoogleMap(
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                markers: _markers,
                mapType: MapType.normal,
                initialCameraPosition:
                    CameraPosition(target: _lastMapPosition, zoom: 14),
                onMapCreated: _onMapCreated,
              )*/
        ,
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
                    builder: (context) => NearByContact(listNearBy: _list)));
          },
          child: Icon(
            Icons.list,
            color: AppColours.whiteColour,
          ),
        ));
  }

/*
  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
*/
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
      var nearby_event = decoded['record']['events'] as List;
      listNearbyEvent = nearby_event
          .map<NearByEvents>((json) => NearByEvents.fromJson(json))
          .toList();
      if (_list.length > 0) {
        markerAdd(_list, Latitude, Longitude);
      } else {
        setState(() {
          _showToast("No Near By Store found");
          storeAvailable = false;
        });
      }
    } else if (status == unauthorized_status) {
      await checkLoginStatus(context);
    } else if (status == data_not_found_status) {
//    _showToast(context, message);
    } else if (status == already_login_status) {
      _showToast(message);
    } else if (status == "408") {
      Map decoded = json.jsonDecode(await apiRefreshRequest(context));
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

  void _showToast(String mesage) {
    Fluttertoast.showToast(
        msg: mesage,
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

void launchMapsUrl(double lat, double lon) async {
  final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
