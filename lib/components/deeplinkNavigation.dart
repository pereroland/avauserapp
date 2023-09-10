import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/main.dart';
import 'package:avauserapp/screens/Event/EventDetail.dart';
import 'package:avauserapp/screens/authentication/login.dart';
import 'package:avauserapp/screens/home/baseTabClass.dart';
import 'package:avauserapp/screens/kiosk/kiosk_payment_screen.dart';
import 'package:avauserapp/screens/paymentSetup/AccountSetupUpdate.dart';
import 'package:avauserapp/screens/product/ProductItemDetail.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';

import 'networkConnection/apiStatus.dart';
import 'networkConnection/apis.dart';
import 'networkConnection/httpConnection.dart';

StreamSubscription? sub;

bool loading = false;

Future<Null> initUniLinks(context) async {
  try {
    String? initialLink = await getInitialLink();

    if (initialLink != null && !loading) {
      loading = true;
      final prefs = await SharedPreferences.getInstance();
      var loginStatus = prefs.getString('userLogin');
      if (loginStatus != null) {
        checkData(initialLink.toString(), context);
      }
    }
  } catch (err) {}

  sub = linkStream.listen((String? link) async {
    print('link listen called');
    if (link != null && !loading) {
      if (!loading) {
        loading = true;
        final prefs = await SharedPreferences.getInstance();
        var loginStatus = prefs.getString('userLogin');
        if (loginStatus != null) {
          checkData(link.toString(), context);
        }
      }
    }
  }, onError: (err) {
    print('error while listening to deeplinks');
    print(err);
  });
}

void checkData(String linkString, context) async {
  print('deeplink called');
  try {
    log("DAFJP $linkString");
    if (linkString.contains('Products')) {
      var str = linkString;
      var pieces =
          str.split('https://alphaxtech.net/ecity/api/users/Products/detail/');
      loading = false;
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProductItemAllDetail(
                product_id: pieces.length >= 1
                    ? pieces[1].toString()
                    : pieces[0].toString())),
      );
    } else if (linkString.contains('createSignature')) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getString("userLogin")!.toLowerCase() == "true") {
        List<String> parameters = [];
        parameters = linkString.split("?")[1].split("&");
        // String userId = parameters[0].split("=")[1];
        String merchantId = parameters[1].split("=")[1];
        String paymentMode = parameters[2].split("=")[1];
        String paymentFor = parameters[3].split("=")[1];
        String referenceId = parameters[4].split("=")[1];
        String orderAmount = parameters[5].split("=")[1];
        String cpmTransId = parameters[6].split("=")[1];
        String storeId = parameters[7].split("=")[1];
        // String pos = parameters[8].split("=")[1];
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => TabBarController(0)),
            (route) => false);
        Navigator.push(
          navigatorKey.currentContext!,
          MaterialPageRoute(
            builder: (context) => AccountSetUpUpdate(
              completeUrl: linkString,
              payment_mode: paymentMode,
              merchantId: merchantId,
              paymentFor: paymentFor,
              storeId: storeId,
              referenceId: referenceId,
              cpm_trans_id: cpmTransId,
              amount: orderAmount,
            ),
          ),
        );
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginRoute()),
            (route) => false);
      }
    } else if (linkString.contains('kiosk_wallet')) {
      //checking if the user is logged in
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getString("userLogin")!.toLowerCase() == "true") {
        //user is logged in
        //decoding order id and user id from url string

        final uri = Uri.tryParse(linkString);
        if (uri == null) {
          showToast('Could not open link: uri is null');
          return;
        }
        final pathSegments = uri.pathSegments;
        if (pathSegments.length < 3) {
          showToast(
              'Could not open link: segment length ${pathSegments.length}');
          return;
        }

        // pathSegments: [
        //         "kiosk_wallet",
        //         transactionId,
        //         SharedPrefHelper.kioskId,
        //         cartTotal,
        //         addUserWalletId,
        //         addMerchantWalletId
        //       ],

        final transactionId = pathSegments[1];
        final kioskId = pathSegments[2];
        final cartTotal = pathSegments[3];
        final addUserWalletId = pathSegments[4];
        final addMerchantWalletId = pathSegments[5];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => KioskPaymentScreen(
              transactionId: transactionId,
              kioskId: kioskId,
              total: cartTotal,
              addUserWalletId: addUserWalletId,
              addMerchantWalletId: addMerchantWalletId,
            ),
          ),
        );
      } else {
        //if the user is not logged in, then sending the user to login screen.
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginRoute()),
            (route) => false);
      }
    } else {
      var initialLinkString = linkString.toString();
      var splitUrl = initialLinkString.split("?").toList();

      var eventAndPrivateSplit = splitUrl[1].split("&").toList();
      var eventIdSplit = eventAndPrivateSplit[0].split("=").toList();
      var privateIdSplit = eventAndPrivateSplit[1].split("=").toList();
      String eventId = eventIdSplit[1].toString();
      String privateId = privateIdSplit[1].toString();
      String? eventDataId;
      try {
        var eventDataIdSplit = eventAndPrivateSplit[2].split("=").toList();
        eventDataId = eventDataIdSplit[1].toString();
      } catch (_) {}
      if (eventId.length == 0) {
        eventId = " ";
      }
      if (privateId.length == 0) {
        privateId = " ";
      }
      Navigator.push(navigatorKey.currentContext!,
          MaterialPageRoute(builder: (context) => TabBarController(3)));
      if (eventDataId != null) {
        Navigator.push(
          navigatorKey.currentContext!,
          MaterialPageRoute(
            builder: (_) => EventPageRoute(
              eventId: eventDataId!,
            ),
          ),
        );
      }
      getDeepLink(eventId, privateId, context);
    }
  } catch (_) {}
}

Future<void> getDeepLink(eventId, privateId, context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var userId = prefs.getString('id');
  Map map = {"event": eventId, "user_id": userId, "private": privateId};
  Map decoded = jsonDecode(await apiRequestMainPage(acceptEventUrl, map));
  String status = decoded['status'];
  if (status == success_status) {
    Fluttertoast.showToast(msg: allTranslations.text("youJoinedEvent"));
  } else if (status == unauthorized_status) {
    await checkLoginStatus(context);
  } else if (status == "408") {
    jsonDecode(await apiRefreshRequest(context));
    getDeepLink(eventId, privateId, context);
  } else {}
}
