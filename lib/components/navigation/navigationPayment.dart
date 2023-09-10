import 'package:avauserapp/components/storeData.dart';
import 'package:avauserapp/screens/paymentSetup/AccountSetupUpdate.dart';
import 'package:flutter/material.dart';

void NavigateScreen(
    {context,
    amount,
    phone_number,
    phone_prefix,
    paymentFor,
    walletCheck}) async {
  String merchantId = await SharedPrefUtils.getString('id');
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AccountSetUpUpdate(
              payment_mode: "phone",
              paymentFor: paymentFor,
              // wallet for 3
              referenceId: "0",
              merchantId: merchantId,
              cpm_trans_id: "",
              amount: amount,
              record: "",
              phone_number: phone_number,
              prifixNumber: phone_prefix,
              walletCheck: walletCheck
              //walletCheck phone for 0 card for 1 only if wallet
              )));
}
