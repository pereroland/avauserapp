import 'dart:convert';

import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';

Future<Map?> SetPayoutLoad({required Map map, context}) async {
  try {
    Map walletList =
        jsonDecode(await apiRequest(requestPayOutUrl, map, context));
    String status = walletList['status'];
    String message = walletList['message'];
    showToast(message.toString());
    if (status == success_status) {
      return walletList;
    } else if (status == unauthorized_status) {
      await checkLoginStatus(context);
      return walletList;
    } else if (status == expire_token_status) {
      Map decoded = jsonDecode(await apiRefreshRequest(context));
      SetPayoutLoad(map: map, context: context);
    } else {
      return walletList;
    }
  } catch (e) {
    return Future.error("Something went wrong");
  }
}
