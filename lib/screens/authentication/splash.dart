import 'dart:async';
import 'dart:io';
//import 'dart:js';

import 'package:avauserapp/components/language/allTransactions.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/firebaseMessage/FirebaseNotifications.dart';
import 'package:avauserapp/main.dart';
import 'package:avauserapp/screens/authentication/myhomepage.dart';
import 'package:avauserapp/screens/home/baseTabClass.dart';
import 'package:avauserapp/screens/notification/BeaconNotification.dart';
import 'package:avauserapp/screens/notification/push_notification_handle.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<String> userGlobalId = [];

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Map myLang = {};
  bool _visible = true;
  Image? myImage;
  StreamSubscription? _streamSubscription;

  final String language = 'fr';

  Future<Timer> startTime() async {
    var _duration = Duration(seconds: 2);
    return Timer(_duration, navigationPage);
  }

  void navigationPage() {
    setState(() {
      _visible = !_visible;
    });
    Timer(Duration(seconds: 4), () {
      callSecondScreen();
    });
  }

  @override
  initState() {
    super.initState();
    myLangGet();
    BeaconNotificationDetail();
    FirebaseNotifications().setUpFirebase();
    LocalNotification().configureDidReceiveLocalNotificationSubject(context);
    LocalNotification().configureSelectNotificationSubject();
  }

  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    _streamSubscription?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, //To Do   //AppColours.whiteColour,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Hero(
                  tag: "splash",
                  child: AnimatedOpacity(
                    opacity: _visible ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 2000),
                    child: Image.asset('assets/logo.png',
                      width: MediaQuery.of(context).size.width / 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<void> myLangGet() async {
    final String defaultLocale =
        Platform.localeName; // Returns locale string in the form 'en_US'
    userGlobalId.add('userId');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var loginstatus = prefs.getString('userLogin');
    var getLanguage = prefs.getString('language');
    if (getLanguage.toString() != 'fr' && getLanguage.toString() != 'en') {
      if (defaultLocale.contains('en')) {
        getLanguage = 'en';
        await allTranslations.setNewLanguage(getLanguage == 'fr' ? 'fr' : 'en');
      } else {
        getLanguage = 'fr';
        await allTranslations.setNewLanguage(getLanguage == 'fr' ? 'fr' : 'en');
      }
    } else {
      await allTranslations.setNewLanguage(getLanguage == 'fr' ? 'fr' : 'en');
    }
    if (loginstatus == null) {
      startTime();
    } else {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => MyBeaconEnableApp(0)));
  }
    Future<void> callSecondScreen() async {
      if (mounted)
        Navigator.pushReplacement(
            context as BuildContext, MaterialPageRoute(builder: (context) => MyHomePage()));
    }
  }

  Future<void> callSecondScreen() async {
    if (mounted)
      Navigator.pushReplacement(
          context as BuildContext, MaterialPageRoute(builder: (context) => MyHomePage()));
  }

}




