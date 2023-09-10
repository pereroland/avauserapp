

import 'package:avauserapp/components/language/allTransactions.dart';
import 'package:avauserapp/components/deeplinkNavigation.dart';
import 'package:avauserapp/firebase_options.dart';
import 'package:avauserapp/screens/authentication/forgot.dart';
import 'package:avauserapp/screens/authentication/myhomepage.dart';
import 'package:avauserapp/screens/authentication/splash.dart';
import 'package:avauserapp/screens/notification/push_notification_handle.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/subjects.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:async';


import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> myBackgroundMessageHandler(RemoteMessage? message) async {}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await allTranslations.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await LocalNotification().flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  await LocalNotification().initialize();
  runApp( MyApp());
}
final GlobalKey<NavigatorState> navigatorKey =
GlobalKey(debugLabel: "Main Navigator");
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject = BehaviorSubject<String>();

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AVA Master APPLICATION',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'AVA Master Home Page'),
    );
  }
  _MyApplicationState createState() => _MyApplicationState();
}


class _MyApplicationState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    allTranslations.onLocaleChangedCallback = _onLocaleChanged;
  }

  _onLocaleChanged() async {}

  @override
  void dispose() {
//    sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
         GlobalCupertinoLocalizations.delegate,
       ],
      supportedLocales: const [
        Locale('en', 'EN'), // English, no country code
        Locale('fr', 'FR'), // French, no country code
        Locale('sp', 'SP'), // Spanish, no country code
        Locale('da', 'DA'), // Spanish, no country code
        Locale('de', 'GR'), // Spanish, no country code
      ],
      navigatorKey: navigatorKey,
      routes: <String, WidgetBuilder>{
        '/LoginRegistraion': (BuildContext context) => MyHomePage(),
        '/ForgotPassword': (BuildContext context) => ForgotRoute()
      },
      //debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }


}
