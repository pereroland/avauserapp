import 'package:avauserapp/components/dataLoad/paymentModeLoad.dart';
import 'package:avauserapp/walletData/walletBankManageScreen.dart';
import 'package:flutter/material.dart';

Future<Map?> getMarketDataList({context, Map? walletData}) async {
  Map? categoryListMap = await getDropDownDataPayoutLoad(context);
  var successMessage = categoryListMap!['status'].toString();
  List<Map> cinetpayMarketMap = [];
  List<Map> cinetpayOperatorPhoneMap = [];

  var cinetpayMarketFirstValue;
  var marketId, operatorId;
  var cinetpayOperatorPhoneFirstValue;

  if (successMessage == '200') {
    var record = categoryListMap['record'];
    List cinetpayMarket = record['cinetpayMarket'];
    List cinetpayCurrency = record['cinetpayCurrency'];
    List margin = record["margin_fee"];
    List cinetpayOperatorPhone = record['cinetpayOperatorPhone'];
    for (int i = 0; i < cinetpayMarket.length; i++) {
      if (i == 0) {
        cinetpayMarketFirstValue = cinetpayMarket[i]['market_name'];
        marketId = cinetpayMarket[i]["id"];
      }
      var map = {
        "id": cinetpayMarket[i]['id'],
        "name": cinetpayMarket[i]['market_name']
      };
      cinetpayMarketMap.add(map);
    }
    for (int i = 0; i < cinetpayOperatorPhone.length; i++) {
      if (i == 0) {
        operatorId = cinetpayOperatorPhone[i]['id'];
        cinetpayOperatorPhoneFirstValue = cinetpayOperatorPhone[i]['operator'];
      }
      var map = {
        "id": cinetpayOperatorPhone[i]['id'],
        "name": cinetpayOperatorPhone[i]['operator'],
        "marketId": cinetpayOperatorPhone[i]['marketid']
      };
      cinetpayOperatorPhoneMap.add(map);
    }
    Map map = {
      "margin_fee": margin,
      "cinetpayMarketMap": cinetpayMarketMap,
      "cinetpayMarketFirstValue": cinetpayMarketFirstValue,
      "cinetpayOperatorPhoneFirstValue": cinetpayOperatorPhoneFirstValue,
      "cinetpayOperatorPhoneMap": cinetpayOperatorPhoneMap,
      "walletData": walletData,
      "market_id": marketId,
      "operator_id": operatorId,
    };
    return map;
  } else {
    return Future.error({});
  }
}
