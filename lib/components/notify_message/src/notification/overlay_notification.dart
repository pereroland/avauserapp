import 'package:avauserapp/components/dataLoad/locationStoreLoad.dart';
import 'package:avauserapp/components/notify_message/overlay.dart';
import 'package:avauserapp/components/notify_message/overlay_support.dart';
import 'package:avauserapp/main.dart';
import 'package:avauserapp/screens/Dispute/DisputeDetail.dart';
import 'package:avauserapp/screens/Event/EventDetail.dart';
import 'package:avauserapp/screens/home/baseTabClass.dart';
import 'package:avauserapp/screens/notification/NotificationTab.dart';
import 'package:avauserapp/screens/paymentSetup/AccountSetupUpdate.dart';
import 'package:avauserapp/walletData/walletSetupScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'notification.dart';

/// Popup a notification at the top of screen.
///
/// [duration] the notification display duration , overlay will auto dismiss after [duration].
/// if null , will be set to [kNotificationDuration].
/// if zero , will not auto dismiss in the future.
///
/// [position] the position of notification, default is [NotificationPosition.top],
/// can be [NotificationPosition.top] or [NotificationPosition.bottom].
///
OverlaySupportEntry showOverlayNotification(
  WidgetBuilder builder, {
  required Duration duration,
  Key? key,
  NotificationPosition position = NotificationPosition.top,
  required RemoteMessage notificationDetail,
}) {
  if (duration == null) {
    duration = kNotificationDuration;
  }
  return showOverlay((context, t) {
    MainAxisAlignment alignment = MainAxisAlignment.start;
    if (position == NotificationPosition.bottom)
      alignment = MainAxisAlignment.end;
    return Column(
      mainAxisAlignment: alignment,
      children: <Widget>[
        position == NotificationPosition.top
            ? GestureDetector(
                child: TopSlideNotification(builder: builder, progress: t),
                onTap: () {
                  onNotificationClicked(notificationDetail.data);
                },
              )
            : BottomSlideNotification(builder: builder, progress: t)
      ],
    );
  }, duration: duration, key: key!, curve: Curves.easeIn);
}

Future<void> onNotificationClicked(Map<String, dynamic> dataMap) async {
  var notificationType = int.tryParse(dataMap['type']);

  if (notificationType == null) {
    return;
  }
  switch (notificationType) {
    case 2:
      {
        final String? paymentUrl = dataMap["payment_url"]?.toString();
        if (paymentUrl == null || paymentUrl.isEmpty) {
          break;
        }
        navigatorKey.currentState!.pushReplacement(
          MaterialPageRoute(
            builder: (_) => AccountSetUpUpdate(
              completeUrl: paymentUrl,
            ),
          ),
        );
      }
      break;
    case 3:
      {
        var referenceId = dataMap['reference_id'].toString();
        navigatorKey.currentState!.pushReplacement(
            MaterialPageRoute(builder: (_) => TabBarController(3)));
        navigatorKey.currentState!.push(MaterialPageRoute(
            builder: (_) => EventPageRoute(eventId: referenceId.toString())));
      }
      break;
    case 7:
    case 8:
      {
        navigatorKey.currentState!.pushReplacement(
            MaterialPageRoute(builder: (_) => NotificationTabs()));
      }
      break;
    case 9:
      {
        var notificationId = dataMap['notification_id'].toString();
        getLocationNotificationDetail(notificationId);
      }
      break;
    case 11:
      {
        navigatorKey.currentState!.pushReplacement(
          MaterialPageRoute(builder: (_) => TabBarController(4)),
        );
      }
      break;
    case 12:
      {
        navigatorKey.currentState!.pushReplacement(
            MaterialPageRoute(builder: (_) => TabBarController(0)));
        navigatorKey.currentState!.pushReplacement(MaterialPageRoute(
            builder: (_) => WalletSetUp(
                  showAppbar: false,
                )));
      }
      break;
    case 14:
      {
        String disputeId = dataMap['reference_id'].toString();
        navigatorKey.currentState!.pushReplacement(
            MaterialPageRoute(builder: (_) => TabBarController(0)));
        navigatorKey.currentState!.push(MaterialPageRoute(
          builder: (context) => DisputeDetail(disputeId: disputeId),
        ));
      }
      break;
  }
}

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
/// [slideDismiss] support left/right to dismiss notification.
/// [position] the position of notification, default is [NotificationPosition.top],
/// can be [NotificationPosition.top] or [NotificationPosition.bottom].
///
OverlaySupportEntry showSimpleNotification(Widget content,
    {Widget? leading,
    required Widget subtitle,
    required Widget trailing,
    required EdgeInsetsGeometry contentPadding,
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
    key: key,
    position: position,
    notificationDetail: notification!,
  );
  return entry;
}
