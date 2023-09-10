import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:avauserapp/components/language/allTranslations.dart';

class PaymentPage extends StatefulWidget {
  final String paymentUrl;

  const PaymentPage({Key? key, required this.paymentUrl}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final GlobalKey webViewKey = GlobalKey();
  double loadingProgress = 0;

  void checkUrl(String url, BuildContext context) {
    String returnUrl =
        "https://alphaxtech.net/ecity/index.php/web/notify/return";
    if (returnUrl == url) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Ecity Payment",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SizedBox(
        child: Stack(
          children: [
            InAppWebView(
              key: webViewKey,
              initialUrlRequest: URLRequest(
                url: Uri.parse(widget.paymentUrl),
                headers: {"Accept-Language": allTranslations.locale.toString()},
              ),
              initialUserScripts: UnmodifiableListView<UserScript>([]),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  useShouldOverrideUrlLoading: true,
                  mediaPlaybackRequiresUserGesture: false,
                ),
                android: AndroidInAppWebViewOptions(
                  useHybridComposition: true,
                ),
                ios: IOSInAppWebViewOptions(
                  allowsInlineMediaPlayback: true,
                ),
              ),
              onWebViewCreated: (controller) {},
              onLoadStart: (controller, url) {
                checkUrl(url.toString(), context);
              },
              androidOnPermissionRequest:
                  (controller, origin, resources) async {
                return PermissionRequestResponse(
                  resources: resources,
                  action: PermissionRequestResponseAction.GRANT,
                );
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                return NavigationActionPolicy.ALLOW;
              },
              onLoadError: (controller, url, code, message) {},
              onProgressChanged: (controller, progress) {
                if (loadingProgress != 100) {
                  setState(() {
                    loadingProgress = progress / 100;
                  });
                }
              },
              onConsoleMessage: (controller, consoleMessage) {},
            ),
            loadingProgress < 1.0
                ? LinearProgressIndicator(value: loadingProgress)
                : Container(),
          ],
        ),
      ),
    );
  }
}
