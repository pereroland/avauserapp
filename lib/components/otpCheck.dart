import 'package:avauserapp/components/dataLoad/myWallettModeLoad.dart';
import 'package:avauserapp/components/longLog.dart';
import 'package:flutter/material.dart';

import 'dialog/otpCheck.dart';

Future<String> walletOtpPayment(context) async {
  Map detail = await myWalletModeLoad(context)??{};
  var walletBalance = "";
  if (detail['status'] == "200") {
    var auth_pin_code = detail['record'][0]['auth_pin_code'];
    walletBalance = detail['record'][0]['wallet_balance'].toString();
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => otpDialog(pin: auth_pin_code)));
    if (result.toString() == "null") {
      return "Fail";
    } else {
      return "Success";
    }
  } else {
    return "Fail";
  }
}
