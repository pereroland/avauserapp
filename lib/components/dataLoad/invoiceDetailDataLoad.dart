import 'dart:convert';

import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/longLog.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';

Future<Map?> invoiceDetailLoad(context, id) async {
  Map myclanList =
      jsonDecode(await getApiDataRequest(claninvoiceDetailtUrl + id, context));
  String status = myclanList['status'];
  String message = myclanList['message'];
  if (status == success_status) {
    return myclanList;
  } else if (status == unauthorized_status) {
    await checkLoginStatus(context);
    return myclanList;
  } else if (status == expire_token_status) {
    jsonDecode(await apiRefreshRequest(context));
    invoiceDetailLoad(context, id);
  } else {
    showToast(message);
    return myclanList;
  }
}
