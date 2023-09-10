import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/shimmerEffects/imageloadshimmer.dart';
import 'package:avauserapp/screens/notification/NotificationTab.dart';
import 'package:avauserapp/screens/notification/push_notification_handle.dart';
import 'package:avauserapp/screens/product/ProductItemDetail.dart';
import 'package:avauserapp/screens/product/productList.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'baseTabClass.dart';

List<Region> region = [];

class BeaconPermission extends StatefulWidget {
  BeaconPermission({Key? key}) : super(key: key);

  @override
  _BeaconPermissionState createState() => _BeaconPermissionState();
}

class _BeaconPermissionState extends State<BeaconPermission>
    with WidgetsBindingObserver {
  late Timer timer;
  final StreamController<BluetoothState> streamController = StreamController();
  StreamSubscription<BluetoothState>? _streamBluetooth;
  StreamSubscription<RangingResult>? _streamRanging;
  final _regionBeacons = <Region, List<Beacon>>{};
  var _beacons = <Beacon>[];
  bool authorizationStatusOk = false;
  bool nearByLocationIsON = false;
  bool locationServiceEnabled = false;
  bool bluetoothEnabled = false;
  var enableBeacon = false;
  List<String> tokens = [];
  int _current = 0;
  int _currentPosition = 0;
  late Timer timerApiCall;
  var callApi = false;
  var callApiEnable = true;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    listeningState();
    beaconAuth();
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted)
        setState(() {
          showNotification();
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => TabBarController(0)));
          return Future.value(false);
        },
        child: Scaffold(
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            child: nextButton(),
          ),
          body: Container(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 8,
                  ),
                  SizedBox(
                      height: 345.0,
                      child: CarouselSlider(
                        options: CarouselOptions(
                            height: 200.0,
                            viewportFraction: 1.0,
                            autoPlay: false,
                            enableInfiniteScroll: false,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _current = index;
                                _currentPosition =
                                    int.parse(index.toString());
                              });
                            }),
                        items: [
                          authorizationStatusOk
                              ? 'assets/location.png'
                              : 'assets/locationdisable.png',
                          bluetoothEnabled
                              ? 'assets/bluetooth.png'
                              : 'assets/bluetoothdisable.png',
                        ].map((i) {
                          return Container(
                              width: MediaQuery.of(context).size.width,
                              height: 200,
                              margin: const EdgeInsets.symmetric(horizontal: 5.0),
                              decoration:
                                  const BoxDecoration(color: Colors.transparent),
                              child: GestureDetector(
                                  child: Image.asset(i, fit: BoxFit.contain),
                                  onTap: () {}));
                        }).toList(),
                      )),
                  const SizedBox(
                    height: 50.0,
                  ),
                  DotsIndicator(
                    dotsCount: 2,
                    position: _currentPosition,
                    decorator: DotsDecorator(
                      size: const Size.square(9.0),
                      activeSize: const Size(18.0, 9.0),
                      activeShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                    ),
                  ),
                  _current == 0
                      ? Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                              child: Text(
                                allTranslations.text('location_inform_message'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                    fontSize: 20.0),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            if (!authorizationStatusOk)
                              MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: const BorderSide(color: Colors.blueAccent)),
                                color: Colors.blueAccent,
                                textColor: Colors.white,
                                padding:
                                    const EdgeInsets.fromLTRB(60.0, 20.0, 60.0, 20.0),
                                onPressed: () async {
                                  await flutterBeacon.requestAuthorization;
                                },
                                child: Text(
                                  allTranslations
                                      .text('Allow_Location_Permission')
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                          ],
                        )
                      : Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                              child: Text(
                                allTranslations
                                    .text('bluethooth_inform_message'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                    fontSize: 20.0),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            if (!bluetoothEnabled)
                              MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: const BorderSide(color: Colors.blueAccent)),
                                color: Colors.blueAccent,
                                textColor: Colors.white,
                                padding:
                                    const EdgeInsets.fromLTRB(60.0, 20.0, 60.0, 20.0),
                                onPressed: () async {
                                  if (Platform.isAndroid) {
                                    try {
                                      await flutterBeacon.openBluetoothSettings;
                                    } on PlatformException catch (_) {}
                                  } else if (Platform.isIOS) {}
                                },
                                child: Text(
                                  allTranslations
                                      .text('Allow_Bluethooth_Permission')
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                  ),
                                ),
                              )
                          ],
                        ),
                ],
              ),
            ),
          ),
        ));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (_streamBluetooth != null && _streamBluetooth!.isPaused) {
        _streamBluetooth?.resume();
      }
      await checkAllRequirements();
      if (authorizationStatusOk && locationServiceEnabled && bluetoothEnabled) {
        listOfBeacons();
      } else {
        await pauseScanBeacon();
        await checkAllRequirements();
      }
    } else if (state == AppLifecycleState.paused) {
      _streamBluetooth?.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    streamController.close();
    _streamRanging?.cancel();
    _streamBluetooth?.cancel();
    flutterBeacon.close;

    super.dispose();
  }

  listeningState() async {
    _streamBluetooth = flutterBeacon
        .bluetoothStateChanged()
        .listen((BluetoothState state) async {
      streamController.add(state);
      if (BluetoothState.stateOn == state) {
        listOfBeacons();
      } else if (BluetoothState.stateOff == state) {
        // permissionAsk();
        await pauseScanBeacon();
        await checkAllRequirements();
      }
    });
  }

  checkAllRequirements() async {
    final bluetoothState = await flutterBeacon.bluetoothState;
    final bluetoothEnabled = bluetoothState == BluetoothState.stateOn;
    final authorizationStatus = await flutterBeacon.authorizationStatus;
    final authorizationStatusOk =
        authorizationStatus == AuthorizationStatus.allowed ||
            authorizationStatus == AuthorizationStatus.always;
    final locationServiceEnabled =
        await flutterBeacon.checkLocationServicesIfEnabled;

    setState(() {
      this.authorizationStatusOk = authorizationStatusOk;
      this.locationServiceEnabled = locationServiceEnabled;
      this.bluetoothEnabled = bluetoothEnabled;
    });
  }

  pauseScanBeacon() async {
    _streamRanging?.pause();
    if (_beacons.isNotEmpty) {
      setState(() {
        _beacons.clear();
      });
    }
  }

  int _compareParameters(Beacon a, Beacon b) {
    int compare = a.proximityUUID.compareTo(b.proximityUUID);

    if (compare == 0) {
      compare = a.major.compareTo(b.major);
    }

    if (compare == 0) {
      compare = a.minor.compareTo(b.minor);
    }

    return compare;
  }

  Future<void> listOfBeacons() async {
    region = [];
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck == true) {
      Map decoded =
          jsonDecode(await getApiDataRequest(activeBeaconsUrl, context));
      String status = decoded['status'];
      if (status == success_status) {
        List record = decoded['record'];
        if (record.length < 1) {
        } else {
          for (var beacon in record) {
            region.add(Region(
              identifier:
                  'com.example.myDeviceRegion' + beacon['beacon_id'].toString(),
              proximityUUID: beacon['beacon_id'].toString(),
            ));
          }
          beaconDetect(region);
        }
      } else if (status == unauthorized_status) {
        await checkLoginStatus(context);
      } else if (status == already_login_status) {
      } else if (status == data_not_found_status) {
      } else if (status == expire_token_status) {
        jsonDecode(await apiRefreshRequest(context));
        listOfBeacons();
      } else {}
    }
  }

  showNotification() async {
    for (var item in _beacons) {
      getDetail(item.proximityUUID.toString(), item);
    }
  }

  Future<void> bluethoothEnableClick() async {
    if (Platform.isAndroid) {
      try {
        await flutterBeacon.openBluetoothSettings;
      } on PlatformException catch (_) {}
    } else if (Platform.isIOS) {}
  }

  nextButton() {
    return SizedBox(
      child: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: const BorderSide(color: Colors.blueAccent)),
        color: Colors.blueAccent,
        textColor: Colors.white,
        padding: const EdgeInsets.all(8.0),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => TabBarController(0)));
        },
        child: Text(
          allTranslations.text('Continue').toUpperCase(),
          style: const TextStyle(
            fontSize: 14.0,
          ),
        ),
      ),
      height: 50.0,
    );
  }

  goBackButton() {
    return MaterialButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: const BorderSide(color: Colors.blueAccent)),
      color: Colors.white,
      textColor: Colors.blueAccent,
      padding: const EdgeInsets.all(8.0),
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text(
        allTranslations.text('Back').toUpperCase(),
        style: const TextStyle(
          fontSize: 14.0,
        ),
      ),
    );
  }

  Future<void> beaconAuth() async {
    if (bluetoothEnabled) await listOfBeacons();
  }

  void getDetail(String id, item) async {
    if (callApiEnable)
      setState(() {
        callApiEnable = false;
      });
    Map payloaddata;
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck == true) {
      Map map = {"beaconId": id};
      Map decoded =
          jsonDecode(await apiRequestMainPage(getDetailBeaconUrl, map));
      String status = decoded['status'];
      String message = decoded['message'];
      if (status == success_status) {
        List record = decoded['record'];
        for (int i = 0; i < record.length; i++) {
          var recordList = record[i];
          String type = recordList['type'];
          String storeId = recordList['store_id'];
          var notificationTitle = recordList['notification_title'];
          String notificationDescription =
              recordList['notification_description'];
          var notificationId = recordList['notification_id'];
          var products = recordList['products'];

          String storeName = recordList['store_name'];
          String offers = recordList['offers'];
          String name = recordList['name'];
          String description = recordList['description'];
          var typeIdDetail = {
            'store_name': storeName,
            'offers': offers,
            'name': name,
            'description': description,
            'store_id': storeId,
          };
          String typeId = recordList['type_id'];
          var notificationImage = recordList['notification_image'];
          payloaddata = {
            "type": type,
            "id": typeId,
            "title": notificationTitle,
            "description": notificationDescription,
            "type_id_detail": typeIdDetail,
            "beaconId": id,
            "notification_image": notificationImage,
            "notification_id": notificationId,
            "products": products,
          };

          if (type == "2") {
          } else {
            /*String type_id = decoded['type_id'];
            if (type_id == "2") {
            } else {}*/
          }
          String mapData = json.encode(payloaddata);
          await LocalNotification().showNotification(notificationTitle, mapData,
              notificationDescription, message.hashCode);
          // var android = AndroidNotificationDetails(
          //     type, notification_title,
          //     priority: Priority.high, importance: Importance.max);
          // var iOS = IOSNotificationDetails();
          // var platform = new NotificationDetails(android: android, iOS: iOS);
          // await flutterLocalNotificationsPlugin.show(
          //     randomId, notification_title, notification_description, platform,
          //     payload: mapData);
        }
        // beaconAuth();
        setState(() {
          callApiEnable = true;
        });
      } else if (status == unauthorized_status) {
        await checkLoginStatus(context);
        setState(() {
          callApiEnable = true;
        });
      } else if (status == already_login_status) {
        setState(() {
          callApiEnable = true;
        });
      } else if (status == data_not_found_status) {
        setState(() {
          callApiEnable = true;
        });
      } else if (status == expire_token_status) {
        jsonDecode(await apiRefreshRequest(context));
        setState(() {
          callApiEnable = true;
        });
        getDetail(id, item);
      } else {
        setState(() {
          callApiEnable = true;
        });
      }
    }
  }

  beaconDetect(List<Region> regions) async {
    await flutterBeacon.initializeScanning;
    await checkAllRequirements();
    if (!authorizationStatusOk ||
        !locationServiceEnabled ||
        !bluetoothEnabled) {
      return;
    }

    if (_streamRanging != null) {
      if (_streamRanging!.isPaused) {
        _streamRanging?.resume();
        return;
      }
    }

    _streamRanging =
        flutterBeacon.ranging(regions).listen((RangingResult result) {
      if (mounted) {
        setState(() {
          _regionBeacons[result.region] = result.beacons;
          _beacons.clear();
          _regionBeacons.values.forEach((list) {
            _beacons.addAll(list);
          });
          _beacons.sort(_compareParameters);
        });
      }
    });
  }
}

class NewScreen extends StatefulWidget {
  Map valueMap;

  NewScreen(this.valueMap);

  @override
  _SettingNotification createState() => _SettingNotification(valueMap);
}

class _SettingNotification extends State<NewScreen> {
  Map valueMap;

  _SettingNotification(this.valueMap);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.black, //change your color here
          ),
          backgroundColor: AppColours.whiteColour,
          title: Text(
            allTranslations.text('New_Campaign'),
            style: const TextStyle(color: AppColours.blackColour),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              CachedNetworkImage(
                imageUrl: valueMap['notification_image'],
                fit: BoxFit.cover,
                placeholder: (context, url) => imageShimmer(context, 240.0),
                errorWidget: (context, url, error) => Image.asset(
                  "assets/nodata.webp",
                  fit: BoxFit.fill,
                ),
                height: 500.0,
                width: MediaQuery.of(context).size.width,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20.0,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            allTranslations.text('title') + " : ",
                            style: const TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Text(valueMap['title'].toString(),
                              style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.normal)),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    offerOnStore(valueMap),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(allTranslations.text('Offer') + " : ",
                              style: const TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          flex: 5,
                          child: Text(
                              valueMap['type_id_detail']['offers'].toString(),
                              style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.normal)),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: nameOfDetail(valueMap['type_id'].toString()),
                        ),
                        Expanded(
                          flex: 5,
                          child: Text(
                              valueMap['type_id_detail']['name'].toString(),
                              style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.normal)),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Text(allTranslations.text('description') + " : ",
                        style: const TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold)),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(valueMap['type_id_detail']['description'].toString(),
                        style: const TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.normal)),
                    const SizedBox(
                      height: 10.0,
                    ),
                    setBottomButton(context)
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  setBottomButton(context) {
    return SizedBox(
      height: 150,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Hero(
                tag: 'offerApply',
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ButtonTheme(
                        minWidth: 200.0,
                        height: 50.0,
                        buttonColor: AppColours.appTheme,
                        child: MaterialButton(
                          elevation: 16.0,
                          color: AppColours.appTheme,
                          shape: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColours.appTheme),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            if (valueMap['type'] == '1') {
                              if (valueMap['id'] == '2') {
                                prefs.setString('applyCupon', "true");
                                /* Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Product(
                                          storeName: valueMap['type_id_detail']
                                              ['store_name'],
                                          Id: valueMap['type_id_detail']
                                              ['store_id'],
                                          isFav: false)),
                                );*/

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ProductItemAllDetail(
                                              campaignData: valueMap,
                                              product_id: valueMap['products']
                                                  [0]['product_id'])),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Product(
                                          campaignData: valueMap,
                                          storeName: valueMap['type_id_detail']
                                              ['store_name'],
                                          Id: valueMap['type_id_detail']
                                              ['store_id'],
                                          isFav: false)),
                                );
                              }
                            } else {
                              /* Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        NotificationDetail(data: valueMap)),
                              );*/
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const NotificationTabs()),
                              );
                            }
                          },
                          child: Text(
                            allTranslations.text('Apply_Offer'),
                            style:
                                const TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Hero(
                tag: 'cancelOfferApply',
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ButtonTheme(
                        minWidth: 200.0,
                        height: 50.0,
                        buttonColor: AppColours.redColour,
                        child: MaterialButton(
                          color: AppColours.redColour,
                          elevation: 16.0,
                          shape: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColours.redColour),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                          child: Text(
                            allTranslations.text('Cancel_Offer'),
                            style:
                                const TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  nameOfDetail(typeId) {
    String name;
    if (typeId == "1") {
      name = "Category Name";
    } else {
      name = "Product Name";
    }
    return Text(name,
        style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold));
  }

  offerOnStore(Map valueMap) {
    if (valueMap['type_id_detail']['store_name'].toString() == "null") {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Text(allTranslations.text('Offer_on_(Store)') + " : ",
              style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          flex: 5,
          child: Text(valueMap['type_id_detail']['store_name'].toString(),
              style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal)),
        ),
      ],
    );
  }
}

void updateNotificationStatus(beaconId, context) async {
  var callUserLoginCheck = await internetConnectionState();
  if (callUserLoginCheck == true) {
    Map map = {"notification_id": beaconId, "status": "4"};
    await apiRequestMainPage(updateNotificationUrl, map);
  }
}
