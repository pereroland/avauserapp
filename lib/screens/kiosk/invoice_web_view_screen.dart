import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/widget/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class InvoicePage extends StatelessWidget {
  const InvoicePage({Key? key, required this.authToken, required this.orderId})
      : super(key: key);
  static const String routeName = "/invoicePage";

  final String authToken;
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(text: allTranslations.text('invoice')),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: Uri.parse(
              "https://alphaxtech.net/ecity/index.php/api/users/Orders/invoicedetails/$orderId/1"),
          headers: {'authtoken': authToken, 'Accept-Language': allTranslations.locale.toString()},
        ),
      ),
    );
  }
}
