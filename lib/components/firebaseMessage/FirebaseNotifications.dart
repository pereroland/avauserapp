import 'dart:convert';
import 'dart:io';

import 'package:avauserapp/components/notify_message/overlay.dart';
import 'package:avauserapp/components/notify_message/src/notification/notification.dart';
import 'package:avauserapp/components/notify_message/src/notification/overlay_notification.dart';
import 'package:avauserapp/screens/Dispute/DisputeDetail.dart';
import 'package:avauserapp/screens/authentication/splash.dart';
import 'package:avauserapp/screens/clan/ChatingUser.dart';
import 'package:avauserapp/screens/clan/invoiceList.dart';
import 'package:avauserapp/screens/home/askForPermissionBeacon.dart';
import 'package:avauserapp/screens/home/baseTabClass.dart';
import 'package:avauserapp/screens/notification/NotificationTab.dart';
import 'package:avauserapp/screens/notification/push_camp_detail.dart';
import 'package:avauserapp/screens/notification/push_notification_handle.dart';
import 'package:avauserapp/screens/order/OrderListShop.dart';
import 'package:avauserapp/screens/transaction/TransactionListData.dart';
import 'package:avauserapp/walletData/DetailPageData.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:avauserapp/main.dart';
import 'package:avauserapp/screens/order/OrderDetailPayment.dart';
import 'package:avauserapp/screens/paymentSetup/AccountSetupUpdate.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';

class FirebaseNotifications {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> setUpFirebase() async {
    firebaseCloudMessagingListeners();
  }

  void firebaseCloudMessagingListeners() {
    _firebaseMessaging.getToken().then((token) {
      setToken(token);
    });
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        Map payloadData;
        payloadData = {
          "type": message.data["type"],
          "reference_id": message.data["type"] != "2"
              ? message.data["reference_id"]
              : message.data["body"].toString().contains("https:")
                  ? message.data["body"].toString().substring(
                      message.data["body"].toString().indexOf("https:"),
                      message.data["body"].toString().length)
                  : message.data["reference_id"],
        };
        String mapData = json.encode(payloadData);
        notificationClick(mapData);
      }
    });
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      notificationDialogManage(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Map payloadData;
      payloadData = {
        "type": message.data["type"],
        "reference_id": message.data["type"] != "2"
            ? message.data["reference_id"]
            : message.data["body"].toString().contains("https:")
                ? message.data["body"].toString().substring(
                    message.data["body"].toString().indexOf("https:"),
                    message.data["body"].toString().length)
                : message.data["reference_id"],
      };
      String mapData = json.encode(payloadData);
      notificationClick(mapData);
    });
  }

  Future setToken(token) async {
    if (token == null) {
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('fcm_token', token.toString());
    }
  }

  Future<void> notificationDialogManage(RemoteMessage message) async {
    var title = message.data["title"];
    var body = message.data["body"];
    debugPrint("dsawjfgpenwjgfvn ${message.data}");
    Map payloadData;
    payloadData = {
      "type": message.data["type"],
      "reference_id": message.data["type"] != "2"
          ? message.data["reference_id"]
          : message.data["body"].toString().contains("https:")
              ? message.data["body"].toString().substring(
                  message.data["body"].toString().indexOf("https:"),
                  message.data["body"].toString().length)
              : message.data["reference_id"],
    };
    String mapData = json.encode(payloadData);
    if (Platform.isAndroid)
      LocalNotification()
          .showNotification(title, mapData, body, message.hashCode);
    if (Platform.isIOS)
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                notificationClick(mapData);
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
  }
}

Future<void> notificationClick(String payload) async {
  Map valueMap = json.decode(payload);
  if (!valueMap.containsKey("notification_id")) {
    String notificationType = valueMap["type"];
    String referenceId = valueMap["reference_id"];
    if (notificationType == "1") {
      navigatorKey.currentState!
          .push(MaterialPageRoute(builder: (_) => SplashScreen()));
    } else if (notificationType == "2") {
      navigatorKey.currentState!
          .push(MaterialPageRoute(builder: (_) => TabBarController(0)));
      navigatorKey.currentState!.pushReplacement(
        MaterialPageRoute(
          builder: (_) => AccountSetUpUpdate(
            completeUrl: referenceId,
          ),
        ),
      );
    } else if (notificationType == "3") {
      navigatorKey.currentState!
          .push(MaterialPageRoute(builder: (_) => TabBarController(3)));
    } else if (notificationType == "4") {
      navigatorKey.currentState!
          .push(MaterialPageRoute(builder: (_) => TabBarController(0)));
    } else if (notificationType == "5") {
      navigatorKey.currentState!
          .push(MaterialPageRoute(builder: (_) => TabBarController(0)));
    } else if (notificationType == "6") {
      navigatorKey.currentState!
          .push(MaterialPageRoute(builder: (_) => TabBarController(0)));
      navigatorKey.currentState!
          .push(MaterialPageRoute(builder: (_) => DetailPageData()));
    } else if (notificationType == "7") {
      navigatorKey.currentState!
          .push(MaterialPageRoute(builder: (_) => TabBarController(0)));
      navigatorKey.currentState!
          .push(MaterialPageRoute(builder: (_) => OrderList()));
    } else if (notificationType == "8") {
      navigatorKey.currentState!
          .push(MaterialPageRoute(builder: (_) => TabBarController(0)));
      navigatorKey.currentState!.push(
        MaterialPageRoute(builder: (context) => NotificationTabs(index: 1)),
      );
      // navigatorKey.currentState!
      //     .push(MaterialPageRoute(builder: (_) => NormalNotificationDetail()));
    } else if (notificationType == "9") {
      navigatorKey.currentState!
          .push(MaterialPageRoute(builder: (_) => TabBarController(0)));
      navigatorKey.currentState!.push(
        MaterialPageRoute(builder: (context) => NotificationTabs(index: 1)),
      );
      // navigatorKey.currentState!
      //     .push(MaterialPageRoute(builder: (_) => NormalNotificationDetail()));
    } else if (notificationType == "11") {
      navigatorKey.currentState!
          .push(MaterialPageRoute(builder: (_) => TabBarController(0)));
      navigatorKey.currentState!.push(MaterialPageRoute(
          builder: (_) => InvoiceList(
                invoiceId: referenceId,
              )));
    } else if (notificationType == "12") {
      navigatorKey.currentState!
          .push(MaterialPageRoute(builder: (_) => TabBarController(0)));
      navigatorKey.currentState!.push(MaterialPageRoute(
          builder: (_) => OrderPaymentDetail(
                id: referenceId,
              )));
    } else if (notificationType == "14") {
      navigatorKey.currentState!
          .push(MaterialPageRoute(builder: (_) => TabBarController(0)));
      navigatorKey.currentState!.push(MaterialPageRoute(
          builder: (_) => DisputeDetail(
                disputeId: referenceId,
              )));
    } else if (notificationType == "15") {
      navigatorKey.currentState!
          .push(MaterialPageRoute(builder: (_) => TabBarController(0)));
      navigatorKey.currentState!.push(MaterialPageRoute(
          builder: (_) => ChattingUserDetail(
                chatGroupId: referenceId,
              )));
    } else if (notificationType == "16") {
      navigatorKey.currentState!
          .push(MaterialPageRoute(builder: (_) => TabBarController(0)));
      navigatorKey.currentState!
          .push(MaterialPageRoute(builder: (_) => TransactionOrderListCheck()));
    } else if (valueMap['type'] == '80') {
      updateNotificationStatus(
          valueMap['notification_id'], navigatorKey.currentContext);
      Navigator.push(
        navigatorKey.currentContext!,
        MaterialPageRoute(
          builder: (context) => PushCampDetails(details: valueMap),
        ),
      );
    } else if (notificationType == "70") {
      Map payloaddata;
      Navigator.pop(navigatorKey.currentContext!);
      var callUserLoginCheck = await internetConnectionState();
      if (callUserLoginCheck == true) {
        Map map = {"beaconId": referenceId};
        Map decoded =
            jsonDecode(await apiRequestMainPage(getDetailBeaconUrl, map));
        String status = decoded['status'];
        if (status == success_status) {
          List record = decoded['record'];
          for (int i = 0; i < record.length; i++) {
            var recordList = record[i];
            var type = recordList['type'];
            updateNotificationStatus(
                recordList['notification_id'], navigatorKey.currentContext);
            var notification_title = recordList['notification_title'];
            var notification_id = recordList['notification_id'];
            String notification_description =
                recordList['notification_description'];
            String type_id = recordList['type_id'];
            var notification_image = recordList['notification_image'];
            var products = recordList['products'];
            String store_id = recordList['store_id'];
            String store_name = recordList['store_name'];
            String offers = recordList['offers'];
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
              navigatorKey.currentContext!,
              MaterialPageRoute(builder: (context) => NewScreen(payloaddata)),
            );
          }
        }
      }
    }
  } else {
    String notificationType = valueMap["type"].toString();
    if (notificationType == "70") {
      String referenceId = valueMap["reference_id"] ?? valueMap["beaconId"];
      Map payloadData;
      // Navigator.pop(navigatorKey.currentContext!);
      var callUserLoginCheck = await internetConnectionState();
      if (callUserLoginCheck == true) {
        Map map = {
          "beaconId": referenceId,
          "campId": valueMap["campaign_id"],
          "notificationId": valueMap["notification_id"]
        };
        Map decoded =
            jsonDecode(await apiRequestMainPage(getCampDetailUrl, map));
        String status = decoded['status'];
        if (status == success_status) {
          List record = decoded['record'];
          for (int i = 0; i < record.length; i++) {
            var recordList = record[i];
            var type = recordList['type'];
            updateNotificationStatus(
                recordList['notification_id'], navigatorKey.currentContext);
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
              "beaconId": referenceId,
              "notification_image": notificationImage,
              "notification_id": notificationId,
              "products": products,
            };
            Navigator.push(
              navigatorKey.currentContext!,
              MaterialPageRoute(builder: (context) => NewScreen(payloadData)),
            );
          }
        }
        //   }
        // else {
        //     Navigator.push(
        //       navigatorKey.currentContext!,
        //       MaterialPageRoute(builder: (context) => NotificationTabs()),
        //     );
        //   }
      }
    } else if (valueMap['type'] == '80') {
      updateNotificationStatus(
          valueMap['notification_id'], navigatorKey.currentContext);
      Navigator.push(
        navigatorKey.currentContext!,
        MaterialPageRoute(
          builder: (context) => PushCampDetails(details: valueMap),
        ),
      );
    } else if (valueMap['type'] == '1') {
      Navigator.push(
        navigatorKey.currentContext!,
        MaterialPageRoute(builder: (context) => NewScreen(valueMap)),
      );
    } else {
      Navigator.push(
        navigatorKey.currentContext!,
        MaterialPageRoute(builder: (context) => NotificationTabs()),
      );
    }
  }

  // Future<void> onNotificationClicked(Map<String, dynamic> dataMap) async {
  //   var notificationType = int.tryParse(dataMap['type']);
  //
  //   if (notificationType == null) {
  //     return;
  //   }
  //   switch (notificationType) {
  //     case 2:
  //       {
  //         final String paymentUrl = dataMap["payment_url"]?.toString();
  //         if (paymentUrl == null || paymentUrl.isEmpty) {
  //           break;
  //         }
  //         navigatorKey.currentState.pushReplacement(
  //           MaterialPageRoute(
  //             builder: (_) => AccountSetUpUpdate(
  //               completeUrl: paymentUrl,
  //             ),
  //           ),
  //         );
  //       }
  //       break;
  //     case 3:
  //       {
  //         var referenceId = dataMap['reference_id'].toString();
  //         navigatorKey.currentState.pushReplacement(
  //             MaterialPageRoute(builder: (_) => TabBarController(3)));
  //         navigatorKey.currentState.push(MaterialPageRoute(
  //             builder: (_) => EventDetail(referenceId)));
  //       }
  //       break;
  //     case 7:
  //     case 8:
  //       {
  //         navigatorKey.currentState.pushReplacement(
  //             MaterialPageRoute(builder: (_) => NotificationTabs()));
  //       }
  //       break;
  //     case 9:
  //       {
  //         var notificationId = dataMap['notification_id'].toString();
  //         getLocationNotificationDetail(notificationId);
  //       }
  //       break;
  //     case 11:
  //       {
  //         navigatorKey.currentState.pushReplacement(
  //           MaterialPageRoute(builder: (_) => TabBarController(4)),
  //         );
  //       }
  //       break;
  //     case 12:
  //       {
  //         navigatorKey.currentState.pushReplacement(
  //             MaterialPageRoute(builder: (_) => TabBarController(0)));
  //         navigatorKey.currentState.pushReplacement(
  //             MaterialPageRoute(builder: (_) => WalletSetUp()));
  //       }
  //       break;
  //     case 14:
  //       {
  //         final disputeId = dataMap['reference_id'];
  //         navigatorKey.currentState.pushReplacement(
  //             MaterialPageRoute(builder: (_) => TabBarController(0)));
  //         navigatorKey.currentState.push(MaterialPageRoute(
  //           builder: (context) => DisputeDetail(disputeId: disputeId),
  //         ));
  //       }
  //       break;
  //   }
  // }

  ///
  /// Show a simple notification above the top of window.
  ///
  ///
  /// [content] see more [ListTile.title].
  /// [leading] see more [ListTile.leading].
  /// [subtitle] see more [ListTile.subtitle].
  /// [trailing] see more [ListTile.trailing].
  /// [contentPadding] see more [ListTile.contentPadding].
  ///
  /// [background] the background color for notification , default is [ThemeData.accentColor].
  /// [foreground] see more [ListTileTheme.textColor],[ListTileTheme.iconColor].
  ///
  /// [elevation] the elevation of notification, see more [Material.elevation].
  /// [autoDismiss] true to auto hide after duration [kNotificationDuration].
  ///   [slideDismiss] support left/right to dismiss notification.
  /// [position] the position of notification, default is [NotificationPosition.top],
  /// can be [NotificationPosition.top] or [NotificationPosition.bottom].
  ///
  OverlaySupportEntry showSimpleNotification(Widget content,
      {required Widget leading,
      required Widget subtitle,
      required Widget trailing,
      EdgeInsetsGeometry? contentPadding,
      required Color background,
      required Color foreground,
      double elevation = 16,
      required Duration duration,
      Key? key,
      bool autoDismiss = true,
      bool slideDismiss = false,
      NotificationPosition position = NotificationPosition.top,
      RemoteMessage? notification}) {
    final entry = showOverlayNotification(
      (context) {
        return SlideDismissible(
          enable: slideDismiss,
          key: ValueKey(key),
          child: Material(
            color: background,
            elevation: elevation,
            child: SafeArea(
                bottom: position == NotificationPosition.bottom,
                top: position == NotificationPosition.top,
                child: ListTileTheme(
                  textColor: foreground,
                  iconColor: foreground,
                  child: ListTile(
                    leading: leading,
                    title: content,
                    subtitle: subtitle,
                    trailing: trailing,
                    contentPadding: contentPadding,
                  ),
                )),
          ),
        );
      },
      duration: autoDismiss ? duration : Duration.zero,
      key: key!,
      position: position,
      notificationDetail: notification!,
    );
    return entry;
  }
}
