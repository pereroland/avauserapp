import 'dart:convert';

import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';

import '../addressFilter.dart';
import '../longLog.dart';

Future<Map?> ChangePinLoad(context, old_pin, new_pin) async {
  Map walletIDMap = {
    "old_pin": old_pin,
    "new_pin": new_pin,
  };
  Map walletList =
      jsonDecode(await apiRequest(changeSecurityPinUrl, walletIDMap, context));
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
    ChangePinLoad(context, old_pin, new_pin);
  } else {
    return walletList;
  }
}
