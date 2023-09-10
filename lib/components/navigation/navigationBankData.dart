import 'package:flutter/material.dart';

import 'package:avauserapp/walletData/walletBankManageScreen.dart';
import 'package:avauserapp/components/dataLoad/paymentModeLoad.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';

Future<void> getArrayList({context, Map? walletData}) async {
  dialogShow(context, true);
  Map categoryListMap = await dropDownDataWalletLoad(context) ?? {};
  var successMessage = categoryListMap['status'].toString();
  List<Map> cinetpayMarketMap = [];
  List<Map> cinetpayCurrencyMap = [];
  List<Map> cinetpayOperatorPhoneMap = [];

  var cinetpayMarketFirstValue;
  var cinetpayCurrencyFirstValue;
  var cinetpayOperatorPhoneFirstValue;

  if (successMessage == '200') {
    var record = categoryListMap['record'];
    List cinetpayMarket = record['cinetpayMarket'];
    List cinetpayCurrency = record['cinetpayCurrency'];
    List cinetpayOperatorPhone = record['cinetpayOperatorPhone'];
    for (int i = 0; i < cinetpayMarket.length; i++) {
      if (i == 0) {
        cinetpayMarketFirstValue = cinetpayMarket[i]['market_name'];
      }
      var map = {
        "id": cinetpayMarket[i]['id'],
        "name": cinetpayMarket[i]['market_name']
      };
      cinetpayMarketMap.add(map);
    }
    for (int i = 0; i < cinetpayCurrency.length; i++) {
      if (i == 0) {
        cinetpayCurrencyFirstValue = cinetpayCurrency[i]['currency_name'];
      }
      var map = {
        "id": cinetpayCurrency[i]['id'],
        "name": cinetpayCurrency[i]['currency_name']
      };
      cinetpayCurrencyMap.add(map);
    }
    for (int i = 0; i < cinetpayOperatorPhone.length; i++) {
      if (i == 0) {
        cinetpayOperatorPhoneFirstValue = cinetpayOperatorPhone[i]['operator'];
      }
      var map = {
        "id": cinetpayOperatorPhone[i]['id'],
        "name": cinetpayOperatorPhone[i]['operator']
      };
      cinetpayOperatorPhoneMap.add(map);
    }
    dialogShow(context, false);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WalletPaymentMode(
              cinetpayMarketMap: cinetpayMarketMap,
              cinetpayCurrencyFirstValue: cinetpayCurrencyFirstValue,
              // cinetpayCurrencyMap: cinetpayCurrencyMap,
              cinetpayMarketFirstValue: cinetpayMarketFirstValue,
              cinetpayOperatorPhoneFirstValue: cinetpayOperatorPhoneFirstValue,
              cinetpayOperatorPhoneMap: cinetpayOperatorPhoneMap,
              walletData: walletData)),
    );
  }
}
