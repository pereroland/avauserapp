import 'dart:convert';

import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/longLog.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';

Future<Map?> invoiceListLoad(context) async {
  Map map = {"page_no": "", "search": ""};
  Map myclanList =
      jsonDecode(await apiRequestMainPage(claninvoiceListUrl, map));
  String status = myclanList['status'];
  String message = myclanList['message'];
  if (status == success_status) {
    return myclanList;
  } else if (status == unauthorized_status) {
    await checkLoginStatus(context);
    return myclanList;
  } else if (status == expire_token_status) {
    Map decoded = jsonDecode(await apiRefreshRequest(context));
    invoiceListLoad(context);
  } else {
    showToast(message);
    return myclanList;
  }
}
