import 'dart:async';
import 'dart:convert';
import 'dart:io';
//import 'dart:ui';
import 'package:flutter/material.dart';

// import 'package:background_location/background_location.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info/device_info.dart';
import 'package:avauserapp/components/dataLoad/homeDataLoad.dart';
import 'package:avauserapp/components/deeplinkNavigation.dart';
import 'package:avauserapp/components/firebaseMessage/FirebaseNotifications.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/shimmerEffects/fullScreenLoadShimmer.dart';
import 'package:avauserapp/components/shimmerEffects/imageloadshimmer.dart';
import 'package:avauserapp/components/storeData.dart';
import 'package:avauserapp/screens/Dispute/DisputeList.dart';
import 'package:avauserapp/screens/Event/EventList.dart';
import 'package:avauserapp/screens/Fav/FavoriteItems.dart';
import 'package:avauserapp/screens/authentication/MyHomePage.dart';
import 'package:avauserapp/screens/clan/Clan.dart';
import 'package:avauserapp/screens/clan/invoiceList.dart';
import 'package:avauserapp/screens/feedback/Feedback.dart';
import 'package:avauserapp/screens/notification/push_notification_handle.dart';
import 'package:avauserapp/screens/order/OrderListDataShop.dart';
import 'package:avauserapp/screens/payout/payoutDetail.dart';
import 'package:avauserapp/screens/profile/Profile.dart';
import 'package:avauserapp/screens/setting/SettingApplication.dart';
import 'package:avauserapp/screens/transaction/TransactionListData.dart';
import 'package:avauserapp/walletData/walletSetupScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/colorconstants.dart';
import '../../components/resource/resource.dart';
import '../../constants.dart' as Constants;
import 'askForPermissionBeacon.dart';
import 'homeScreen.dart';
import 'map.dart';
import 'stores.dart';

class TabBarController extends StatefulWidget {
  TabBarController(this._currentIndex);

  int _currentIndex;

  @override
  State<StatefulWidget> createState() {
    return _TabBarControllerState(_currentIndex);
  }
}

class _TabBarControllerState extends State<TabBarController>
    with WidgetsBindingObserver {
  _TabBarControllerState(this._currentIndex);

  var callApi = true;
  late int _currentIndex;
  Map? myLang;
  var dataLoad = true;
  var home = "",
      Wallet = "",
      History = "",
      Setting = "",
      Support = "",
      aboutUs = "",
      Feedback = "",
      faq = "",
      Information = "",
      TermsAndConditions = "",
      privacyPolicy = "",
      logout = "",
      nearMe = "";
  var userId = "";
  final List<Widget> _children = [
    HomeScreen(),
    MapWidget(),
    StoreDetail(),
    EventDetail(
      eventId: null,
    ),
    ClanDetail(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    initUniLinks(context);
    saveData();
  }

  @override
  void dispose() {
    sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          _onBackPressed();
          return Future.value(false);
        },
        child: dataLoad
            ? Scaffold(
                body: _children[_currentIndex],
                bottomNavigationBar: BottomNavigationBar(
                  selectedItemColor: Constants.PrimaryColor,
                  unselectedItemColor: Colors.grey,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  onTap: onTabTapped,
                  currentIndex: _currentIndex,
                  items: [
                    BottomNavigationBarItem(
                      icon: new ImageIcon(
                        AssetImage("assets/home.png"),
                        size: 30.0,
                      ),
                      label: home,
                    ),
                    BottomNavigationBarItem(
                      icon: new ImageIcon(
                        AssetImage("assets/map.png"),
                        size: 30.0,
                      ),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: new ImageIcon(
                        AssetImage("assets/stores.png"),
                        size: 30.0,
                      ),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: new ImageIcon(
                        AssetImage("assets/eventicon.webp"),
                        size: 40.0,
                      ),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: new ImageIcon(
                        AssetImage("assets/clanicon.webp"),
                        size: 30.0,
                      ),
                      label: '',
                    )
                  ],
                ),
              )
            : fullScreenShimmer(context));
  }

  Future<bool> _onBackPressed() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            allTranslations.text('Are_you_sure'),
          ),
          content: Text(
            allTranslations.text('exit_app_text'),
          ),
          actions: <Widget>[
            MaterialButton(
              elevation: 0.0,
              child: Text(
                allTranslations.text('no'),
                style: TextStyle(color: AppColours.appTheme),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            MaterialButton(
              elevation: 0.0,
              child: Text(
                allTranslations.text('yes'),
                style: TextStyle(color: AppColours.appTheme),
              ),
              onPressed: () {
                SystemNavigator.pop();
              },
            )
          ],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        );
      },
    );
    return Future.value(false);
  }

  Future<bool> _onLocationPermission() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "BackGround Permission",
          ),
          content: Text(
            allTranslations.text("sayToLocationPermission"),
          ),
          actions: <Widget>[
            MaterialButton(
              elevation: 0.0,
              child: Text(
                allTranslations.text('no'),
                style: TextStyle(color: AppColours.appTheme),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            MaterialButton(
              elevation: 0.0,
              child: Text(
                allTranslations.text('yes'),
                style: TextStyle(color: AppColours.appTheme),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0)),
        );
      },
    );
    return Future.value(false);
  }

  Future<void> saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_interact', 'true');
    userId = prefs.getString('id') ?? "";
  }
}

Widget drawerData(
    context, userId, profilePic, userFullName, userEmail, userImage) {
  return Drawer(
      child: Container(
    color: AppColours.whiteColour,
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        AppBar(
          title: Text(
            "ecity",
            style: TextStyle(color: AppColours.blackColour),
          ),
          leading: new IconButton(
            icon: Icon(Icons.clear),
            color: AppColours.blackColour,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: AppColours.whiteColour,
          centerTitle: true,
        ),
        SizedBox(
          height: Resource.space.medium,
        ),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileDetail()),
            );
          },
          child: DrawerHeader(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColours.whiteColour,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: userImage,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          imageShimmer(context, 80.0),
                      errorWidget: (context, url, error) => Image.asset(
                        "assets/nodata.webp",
                        fit: BoxFit.fill,
                      ),
                      width: 80,
                      height: 80,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  userFullName,
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  userEmail,
                  style: TextStyle(color: Colors.grey, fontSize: 14.0),
                )
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: Resource.space.xSmall,
        ),
        ListTile(
          leading: Icon(Icons.account_balance_wallet),
          title: Text(
            allTranslations.text('Wallet'),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WalletSetUp(
                        showAppbar: false,
                      )),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.payment),
          title: Text(
            allTranslations.text('Payout'),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PayoutScreen()),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.message),
          title: Text(
            allTranslations.text('Invoice'),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => InvoiceList(
                        invoiceId: null,
                      )),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.favorite),
          title: Text(
            allTranslations.text('FavoriteList'),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FavoriteItems()),
            );
          },
        ),

        /* ListTile(
          leading: Icon(Icons.group),
          title: Text(allTranslations.text('History')),
          onTap: () {
            Navigator.pop(context);

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HistoryDetail()),
            );
          },
        ),*/
        ListTile(
          leading: SvgPicture.asset('assets/order.svg'),
          title: Text(
            allTranslations.text('Order_History'),
          ),
          onTap: () {
            Navigator.pop(context);

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrderListCheck()),
            );
          },
        ),
        ListTile(
          leading: SvgPicture.asset('assets/transaction.svg'),
          title: Text(
            allTranslations.text('TransactionHistory'),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TransactionOrderListCheck()),
            );
          },
        ),
        ListTile(
          leading: SvgPicture.asset('assets/disputes.svg'),
          title: Text(
            allTranslations.text('disputeList'),
          ),
          onTap: () {
            Navigator.pop(context);

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DisputeList()),
            );
          },
        ),
        ListTile(
          leading: SvgPicture.asset('assets/feedback.svg'),
          title: Text(
            allTranslations.text('Feedback'),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FeedbackRoute()),
            );
          },
        ),
        ListTile(
          leading: SvgPicture.asset('assets/information.svg'),
          title: Text(
            allTranslations.text('Information'),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: SvgPicture.asset('assets/terms.svg'),
          title: Text(
            allTranslations.text('TermsAndConditions'),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: SvgPicture.asset(
            'assets/privacy.svg',
            color: Colors.grey,
          ),
          title: Text(
            allTranslations.text('privacyPolicy'),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text(
            allTranslations.text('Setting'),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingApplication()),
            );
          },
        ),
        /* ListTile(
          leading: Icon(Icons.rate_review),
          title: Text(Support),
          onTap: () {
            Navigator.pop(context);
          },
        ),*/
        /*ListTile(
          leading: Icon(Icons.rate_review),
          title: Text(aboutUs),
          onTap: () {
            Navigator.pop(context);
          },
        ),*/

        /* ListTile(
          leading: Icon(Icons.rate_review),
          title: Text(faq),
          onTap: () {
            Navigator.pop(context);
          },
        ),*/

        ListTile(
          leading: Icon(Icons.logout),
          title: Text(
            allTranslations.text('logout'),
          ),
          onTap: () {
            logoutApp(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.apps),
          title: Text(
            "App Version :  1.0.0",
          ),
          onTap: () {
            Navigator.pop(context);
/*//            Navigator.pop(context);
            Navigator.of(context)
                .push(new SettingAboutUsPageRoute(contactUs, "2"));*/
          },
        ),
      ],
    ),
  ));
}

Future<void> logoutApp(context) async {
  try {
    var device_name = "";
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    var udid = await FlutterUdid.udid;
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      device_name = androidInfo.model.toString();
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      device_name = iosInfo.utsname.machine;
    }
    String _id = await SharedPrefUtils.getString("id");
    String _token = await SharedPrefUtils.getString("fcm_token") ?? "";
    await apiRequestMainPageWithOutCx(logoutUrl, {
      "user_id": _id,
      "fcm_tokens": _token,
      "device_id": udid,
      "device_name": device_name
    });
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => MyHomePage()));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userLogin');
    prefs.remove('authtoken');
  } catch (_) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userLogin');
    prefs.remove('authtoken');
  }
}

/*...............Beacon_Check...................*/
void checkBeaconEnableDisable(context) {
  if (region.length == 0) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyBeaconEnableApp(0)),
      );
    });
  }
}

class MyBeaconEnableApp extends StatefulWidget {
  MyBeaconEnableApp(this._currentIndex);

  int _currentIndex;

  @override
  _MyBeaconEnableAppState createState() =>
      _MyBeaconEnableAppState(_currentIndex);
}

class _MyBeaconEnableAppState extends State<MyBeaconEnableApp>
    with WidgetsBindingObserver {
  _MyBeaconEnableAppState(this._currentIndex);

  int _currentIndex;

  final StreamController<BluetoothState> streamController = StreamController();
  late StreamSubscription<BluetoothState> _streamBluetooth;
  StreamSubscription<RangingResult>? _streamRanging;
  final _regionBeacons = <Region, List<Beacon>>{};
  final _beacons = <Beacon>[];
  bool authorizationStatusOk = false;
  bool locationServiceEnabled = false;
  bool bluetoothEnabled = false;
  List<String> tokens = [];

  var callApi = false;
  var callApiEnable = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    listeningState();
    beaconCheck();
  }

  listeningState() async {
    _streamBluetooth = flutterBeacon
        .bluetoothStateChanged()
        .listen((BluetoothState state) async {
      streamController.add(state);
      if (BluetoothState.stateOn == state) {
        if (await Permission.bluetoothScan.isGranted) {
          initScanBeacon();
        } else {
          PermissionStatus scanPermission =
              await Permission.bluetoothScan.request();
          if (scanPermission.isGranted) {
            initScanBeacon();
          } else if (scanPermission.isPermanentlyDenied && Platform.isIOS) {
            initScanBeacon();
          } else {
            _showToast(allTranslations.text("bluethooth_inform_message"));
          }
        }
      } else if (BluetoothState.stateOff == state) {
        permissionAsk();
        await pauseScanBeacon();
        await checkAllRequirements();
      }
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TabBarController(0)),
      );
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

    if (mounted)
      setState(() {
        this.authorizationStatusOk = authorizationStatusOk;
        this.locationServiceEnabled = locationServiceEnabled;
        this.bluetoothEnabled = bluetoothEnabled;
      });
  }

  initScanBeacon() async {
    listOfBeacons();
  }

  pauseScanBeacon() async {
    if (_streamRanging != null) {
      _streamRanging!.pause();
      if (_beacons.isNotEmpty) {
        setState(() {
          _beacons.clear();
        });
      }
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (_streamBluetooth != null && _streamBluetooth.isPaused) {
        _streamBluetooth.resume();
      }
      await checkAllRequirements();
      if (authorizationStatusOk && locationServiceEnabled && bluetoothEnabled) {
        await initScanBeacon();
      } else {
        await pauseScanBeacon();
        await checkAllRequirements();
      }
    } else if (state == AppLifecycleState.paused) {
      _streamBluetooth.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    streamController.close();
    if (_streamRanging != null) _streamRanging!.cancel();
    _streamBluetooth.cancel();
    flutterBeacon.close;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              allTranslations.text('Home'),
              style: TextStyle(
                color: AppColours.blackColour,
              ),
            ),
            centerTitle: true,
          ),
          body: Container(
            color: AppColours.whiteColour,
            child: fullScreenShimmer(context),
          )),
    );
  }

  void listOfBeacons() async {
    region = [];

    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck == true) {
      Map decoded =
          jsonDecode(await getApiDataRequest(activeBeaconsUrl, context));
      String status = decoded['status'];
      if (status == success_status) {
        List record = decoded['record'];
        if (record.length > 1) {
          for (var beacon in record) {
            region.add(
              Region(
                identifier: 'com.example.myDeviceRegion' +
                    beacon['beacon_id'].toString(),
                proximityUUID: beacon['beacon_id'].toString(),
              ),
            );
          }
        }
        beaconDetect(region);
      } else if (status == unauthorized_status) {
        await checkLoginStatus(context);
      } else if (status == expire_token_status) {
        jsonDecode(await apiRefreshRequest(context));
      }
    }
  }

  void permissionAsk() {
    _showToast(allTranslations.text('PleaseBeaconRestartMessage'));
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TabBarController(_currentIndex)));
  }

  Future<void> beaconDetect(List<Region> region) async {
    await flutterBeacon.initializeScanning;
    await checkAllRequirements();
    if (!authorizationStatusOk ||
        !locationServiceEnabled ||
        !bluetoothEnabled) {
      if (!locationServiceEnabled) {
        _showToast(allTranslations.text('PleaseBeaconLocationRestartMessage'));
      }
      return;
    }

    if (_streamRanging != null) {
      if (_streamRanging!.isPaused) {
        _streamRanging!.resume();
        return;
      }
    }

    _streamRanging =
        flutterBeacon.ranging(region).listen((RangingResult result) {
      if (result != null && mounted) {
        setState(() {
          _regionBeacons[result.region] = result.beacons;
          _beacons.clear();
          _regionBeacons.values.forEach((list) {
            _beacons.addAll(list);
            Timer(const Duration(seconds: 2), () {
              beaconTest();
            });
          });
          _beacons.sort(_compareParameters);
        });
      }
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

  void beaconTest() {
    if (_beacons.length != 0 && mounted) showNotification(_beacons);
  }

  showNotification(_beacons) async {
    if (callApi)
      for (var item in _beacons) {
        beaconMessage(item);
      }
    if (mounted)
      setState(() {
        callApi = false;
      });
  }

  Future<void> beaconAuth() async {
    if (_regionBeacons != null) {
      if (bluetoothEnabled) await initScanBeacon();
    } else {}
  }

  Future<void> beaconMessage(item) async {
    getDetail(item.proximityUUID.toString(), item);
  }

  void getDetail(String id, item) async {
    if (callApiEnable)
      setState(() {
        callApiEnable = false;
      });
    Map payloadData;
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck == true) {
      Map map = {"beaconId": id};
      Map decoded =
          jsonDecode(await apiRequestMainPage(getDetailBeaconUrl, map));
      String status = decoded['status'];
      if (status == success_status) {
        List record = decoded['record'];
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
          payloadData = {
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
          String mapData = json.encode(payloadData);
          await LocalNotification().showNotification(notificationTitle, mapData,
              notificationDescription, DateTime.now().millisecond);
        }
        beaconAuth();
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

  Future onSelectNotification(String payload) async {
    await notificationClick(payload);
  }

  Future<void> beaconCheck() async {
    var decoded = await callHomeLoad(context, '');
    String status = decoded!['status'];
    if (status == success_status)
      Timer.periodic(Duration(seconds: 5), (timer) {
        if (mounted)
          setState(() {
            callApi = true;
          });
      });
  }
}
