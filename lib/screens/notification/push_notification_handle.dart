import 'package:avauserapp/components/firebaseMessage/FirebaseNotifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:avauserapp/main.dart';
//import 'package:avauserapp/firebase_options.dart';


class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}

class LocalNotification {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('ic_launcher');

  /*
  final DarwinInitializationSettings initializationSettingsIOS =  DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int? id, String? title, String? body, String? payload) async {
        didReceiveLocalNotificationSubject.add(ReceivedNotification(
            id: id!, title: title!, body: body!, payload: payload!));
      });
*/

  final InitializationSettings initializationSettings = const InitializationSettings(
    android: initializationSettingsAndroid,
    //iOS: initializationSettingsIOS,
  );

  initialize() async {
    await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
       // onDidReceiveNotificationResponse: (notificationResponse) async {selectNotificationSubject.add(notificationResponse.payload!);}
        );
  }

  Future<void> showNotification(
      String title, String payload, String body, int value) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails('id', 'name',importance: Importance.max,priority: Priority.high,ticker: 'ticker');
    //const DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(presentAlert: true, presentSound: true, presentBadge: true);
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        //iOS: iosNotificationDetails
    );
    await flutterLocalNotificationsPlugin
        .show(value, title, body, platformChannelSpecifics, payload: payload);
  }

  void configureDidReceiveLocalNotificationSubject(context) {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text(receivedNotification.title),
          content: Text(receivedNotification.body),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                notificationClick(receivedNotification.payload);
              },
              child: const Text('Next'),
            )
          ],
        ),
      );
    });
  }

  void configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((message) async {
      await notificationClick(message);
    });
  }
}
