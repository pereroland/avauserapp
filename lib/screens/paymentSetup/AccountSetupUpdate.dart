import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/dialog/paymentSuccess.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/screens/Item/completePayment.dart';
import 'package:avauserapp/screens/clan/invoiceList.dart';
import 'package:avauserapp/screens/home/baseTabClass.dart';
import 'package:avauserapp/walletData/DetailPageData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';

class AccountSetUpUpdate extends StatefulWidget {
  AccountSetUpUpdate(
      {Key? key,
      this.payment_mode,
      this.paymentFor,
      this.referenceId,
      this.merchantId,
      this.cpm_trans_id,
      this.amount,
      this.record,
      this.phone_number,
      this.prifixNumber,
      this.walletCheck,
      this.isClan,
      this.storeId,
      this.id,
      this.completeUrl})
      : super(key: key);
  String? completeUrl;
  var payment_mode;
  var paymentFor;
  var referenceId;
  var merchantId;
  var cpm_trans_id;
  var amount;
  var id;
  var record;
  var phone_number;
  var prifixNumber;
  var walletCheck;
  var isClan;
  var storeId;

  _SquareOrderList createState() => _SquareOrderList();
}

class _SquareOrderList extends State<AccountSetUpUpdate> {
  final GlobalKey webViewKey = GlobalKey();

  late InAppWebViewController webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  ContextMenu? contextMenu;
  double progress = 0;
  final urlController = TextEditingController();

  String url = "";
  var oldUrl = "";

  var dataType = "";
  var idDataType;
  var dataLoad = false;
  var email;
  var businessName;
  var firstName;
  var lastName;
  String authtoken = "";
  String merchantId = "";
  String payment_mode = "";
  String payment_for = "";
  String referenceId = "";
  String phone_number = "";
  String prifix = "";
  String amount = "";
  String cpm_trans_id = "";
  var backclick = "";
  var loadData = "";
  var walletCheck = "";
  var isClan = "";
  var storeId = "";
  var typePayment = "";

  @override
  void initState() {
    super.initState();
    dataGet();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> dataGet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    authtoken = prefs.getString('authtoken') ?? "";
    merchantId = widget.merchantId;
    payment_mode = widget.payment_mode;
    payment_for = widget.paymentFor;
    referenceId = widget.referenceId;
    cpm_trans_id = widget.cpm_trans_id;
    phone_number = widget.phone_number ?? "";
    amount = widget.amount;
    prifix = widget.prifixNumber ?? "225";
    walletCheck = widget.walletCheck ?? "0";
    isClan = widget.isClan.toString();
    storeId = widget.storeId.toString();
    setState(() {
      if (widget.completeUrl != null) {
        loadData = widget.completeUrl ?? "";
        dataLoad = true;
        return;
      }
      if (storeId.toString() != "null" && storeId.toString() != "") {
        typePayment = "storeId";
        loadData =
            "https://alphaxtech.net/ecity/index.php/web/CinetPay/createSignature?user_id=$authtoken&merchant_id=$merchantId&payment_mode=phone&payment_for=2&reference_id=0&order_amount=$amount&cpm_trans_id=$cpm_trans_id&store_id=$storeId&lang=fr";
      } else if (isClan.toString() != "null" && isClan.toString() != "") {
        //  for clan invoice
        typePayment = "isClan";
        loadData =
            "https://alphaxtech.net/ecity/index.php/web/CinetPay/createSignature?user_id=$authtoken&merchant_id=$merchantId&payment_mode=phone&payment_for=8&reference_id=$isClan&cpm_trans_id=$cpm_trans_id&amount=$amount&lang=fr";
      } else {
        typePayment = "walletCheck";
        if (walletCheck == "0") {
          loadData =
              "https://alphaxtech.net/ecity/index.php/web/CinetPay_wallet/createWalletSignature?user_id=$authtoken&merchant_id=$merchantId&payment_mode=$payment_mode&payment_for=$payment_for&reference_id=$referenceId&phone=$phone_number&amount=$amount&lang=fr";
        } else {
          loadData =
              "https://alphaxtech.net/ecity/index.php/web/CinetPay/createSignature?user_id=$authtoken&merchant_id=0&payment_mode=card&payment_for=3&reference_id=0&lang=fr";
        }
      }
      dataLoad = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async {
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
              onPressed: () {
                _onBackPressed();
              }),
          title: Text(
            "Ecity Payment",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: dataLoad
            ? Container(
                child: Column(children: <Widget>[
                Expanded(
                  child: Stack(
                    children: [
                      InAppWebView(
                        key: webViewKey,
                        // contextMenu: contextMenu,
                        initialUrlRequest:
                            URLRequest(url: Uri.parse(loadData), headers: {
                          // "Accept-Language": allTranslations.locale.toString()
                        }),
                        // initialFile: "assets/index.html",
                        initialUserScripts:
                            UnmodifiableListView<UserScript>([]),
                        initialOptions: options,
                        onWebViewCreated: (controller) {
                          webViewController = controller;
                        },
                        onLoadStart: (controller, url) {
                          setState(() {
                            this.url = url.toString();
                            urlController.text = this.url;
                            checkUrl(url.toString());
                          });
                        },
                        androidOnPermissionRequest:
                            (controller, origin, resources) async {
                          return PermissionRequestResponse(
                              resources: resources,
                              action: PermissionRequestResponseAction.GRANT);
                        },
                        shouldOverrideUrlLoading:
                            (controller, navigationAction) async {
                          var uri = navigationAction.request.url;

                          if (![
                            "http",
                            "https",
                            "file",
                            "chrome",
                            "data",
                            "javascript",
                            "about"
                          ].contains(uri!.scheme)) {
                            if (await canLaunch(url)) {
                              // Launch the App
                              await launch(
                                url,
                              );
                              // and cancel the request
                              return NavigationActionPolicy.CANCEL;
                            }
                          }

                          return NavigationActionPolicy.ALLOW;
                        },
                        onLoadStop: (controller, url) async {
                          setState(() {
                            this.url = url.toString();
                            urlController.text = this.url;
                            this.url = url.toString();
                            checkUrl(url.toString());
                          });
                        },
                        onLoadError: (controller, url, code, message) {},
                        onProgressChanged: (controller, progress) {
                          if (progress == 100) {}
                          setState(() {
                            this.progress = progress / 100;
                            urlController.text = this.url;
                          });
                        },
                        onUpdateVisitedHistory:
                            (controller, url, androidIsReload) {
                          setState(() {
                            this.url = url.toString();
                            urlController.text = this.url;
                          });
                        },
                        onConsoleMessage: (controller, consoleMessage) {},
                      ),
                      progress < 1.0
                          ? LinearProgressIndicator(value: progress)
                          : Container(),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(""),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(""),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(""),
                    )
                  ],
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: <Widget>[
                    MaterialButton(
                      color: AppColours.appTheme,
                      child: Icon(Icons.arrow_back),
                      onPressed: () {
                        if (webViewController != null) {
                          webViewController.goBack();
                        }
                      },
                    ),
                    MaterialButton(
                      color: AppColours.appTheme,
                      child: Icon(Icons.arrow_forward),
                      onPressed: () {
                        if (webViewController != null) {
                          webViewController.goForward();
                        }
                      },
                    ),
                    MaterialButton(
                      color: AppColours.appTheme,
                      child: Icon(Icons.refresh),
                      onPressed: () {
                        if (webViewController != null) {
                          webViewController.reload();
                        }
                      },
                    ),
                  ],
                ),
              ]))
            : Text(allTranslations.text('DataLoading')),
      ),
    );
  }

  Widget? _showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void checkUrl(String url) {
    var success = "https://alphaxtech.net/ecity/index.php/web/notify";
    var invoiceSuccess =
        "https://alphaxtech.net/ecityMerchantWeb/index.html#/home/success";
    var cancel = "https://alphaxtech.net/ecity/index.php/web/notify/cancel";
    var card_success =
        "https://alphaxtech.net/ecity/index.php/web/notify/return";
    var checkUrl = "https://secure.cinetpay.com/notifypay?csrf_token=";
    var ecityWeb = "https://alphaxtech.net/ecityMerchantWeb/index.html#/home";
    if (url.contains(checkUrl)) {
      if (oldUrl == "") {
        oldUrl = url;
      } else if (oldUrl == url) {
      } else {
        // var token = url.replaceAll(
        //     "https://secure.cinetpay.com/notifypay?csrf_token=", "");
        if (!checkPaymentTypeDetailItemLoading) checkPaymentTypeDetailItem();
      }
    }

    if (url == success || url == card_success || url == invoiceSuccess) {
      if (backclick == "") {
        if (!checkPaymentTypeDetailItemLoading) checkPaymentTypeDetailItem();
      }
      backclick = "click";
    } else if (url == cancel) {
      if (backclick == "") {
        Navigator.pop(context);
        _showToast(allTranslations.text("paymentCancelled"));
      }
      backclick = "click";
    }
    if (url == ecityWeb) {
      Navigator.pop(context);
    }
  }

  callInvoiceCheck(BuildContext context) async {
    Map map = {"cpm_trans_id": widget.cpm_trans_id};
    Map decoded = jsonDecode(await apiRequest(checkPaymentUrl, map, context));
    String status = decoded['status'];
    String message = decoded['message'];
    if (status == success_status) {
      http.post(
          Uri.parse(
              "https://alphaxtech.net/ecity/index.php/api/users/Clan/updateStatusForClanInvoiceList"),
          headers: {
            "authtoken": authtoken,
            "Content-Type": "application/json",
            "Accept-Language": allTranslations.locale.toString()
          },
          body: jsonEncode({
            "invoice_id": "${widget.id}",
            "user_id": "${widget.merchantId}"
          }));
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (_) => TabBarController(0),
        ),
      );
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (_) => InvoiceList(
            invoiceId: null,
          ),
        ),
      );
      PaymentWalletSetupDialog(context);
    } else {
      navigatorKey.currentState!.pop();
      _showToast(message);
    }
  }

  void callBookingCheck(cpm_trans_id, BuildContext context) async {
    Map map = {"cpm_trans_id": cpm_trans_id};
    Map decoded = jsonDecode(await apiRequest(checkPaymentUrl, map, context));
    String status = decoded['status'];
    String message = decoded['message'];
    if (status == success_status) {
      paymentSaveShop(cpm_trans_id);
    } else if (status == unauthorized_status) {
      await checkLoginStatus(context);
    } else if (status == already_login_status) {
    } else if (status == "408") {
      jsonDecode(await apiRefreshRequest(context));
      callBookingCheck(cpm_trans_id, context);
    }
    _showToast(message);
  }

  void paymentSaveShop(cpm_trans_id) async {
    try {
      var callUserLoginCheck = await internetConnectionState();
      if (callUserLoginCheck == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('cart_qty', '0');
        Map map = {
          "group_id": "",
          "clan_userId": "",
          "transaction_id": cpm_trans_id
        };
        Map decoded = jsonDecode(await apiRequestMainPage(saveOrderUrl, map));
        getApiDataRequest(emptyCartUrl, context);
        String status = decoded['status'];
        String message = decoded['message'];
        if (status == success_status) {
          var record = decoded['record'];
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => CompletePayment(paymentRecord: record)),
          );
        } else if (status == unauthorized_status) {
          await checkLoginStatus(context);
        } else if (status == already_login_status) {
          _showToast(message);
        } else if (status == expire_token_status) {
          jsonDecode(await apiRefreshRequest(context));
          paymentSaveShop(cpm_trans_id);
        } else {
          _showToast(message);
        }
      }
    } catch (_) {
      Navigator.pop(context);
      _showToast(allTranslations.text("something_Wrong"));
    }
  }

  Future<void> setRecord(record) async {
    String id = record['id'];
    String full_name = record['full_name'];
    String email = record['email'];
    String phone = record['phone'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('id', id);
    prefs.setString('full_name', full_name);
    prefs.setString('email', email);
    prefs.setString('phone', phone);
    prefs.setString('image', 'image');
  }

  Future<bool> _onBackPressed() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(allTranslations.text('Are_you_sure')),
          content: Text(allTranslations.text('Doyouwanttocancelpayment')),
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

  bool status = true;

  bool checkPaymentTypeDetailItemLoading = false;

  void checkPaymentTypeDetailItem() async {
    checkPaymentTypeDetailItemLoading = true;
    if (typePayment == "storeId") {
      callBookingCheck(widget.cpm_trans_id, context);
    } else if (typePayment == "isClan") {
      if (status) {
        status = false;
        callInvoiceCheck(context);
      }
    } else if (typePayment == "walletCheck") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetailPageData()),
      );
      PaymentWalletSetupDialog(context);
    }
  }
}
