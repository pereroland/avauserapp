import 'dart:convert';

import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';

Future<Map?> callordersClanLoad(context) async {
  Map allordersClanList =
      jsonDecode(await getApiDataRequest(allordersClanUrl, context));
  String status = allordersClanList['status'];
  String message = allordersClanList['message'];
  if (status == success_status) {
    return allordersClanList;
  } else if (status == unauthorized_status) {
    await checkLoginStatus(context);
    return allordersClanList;
  } else if (status == expire_token_status) {
    jsonDecode(await apiRefreshRequest(context));
    callordersClanLoad(context);
  } else {
    // showToast(message);
    return allordersClanList;
  }
}
