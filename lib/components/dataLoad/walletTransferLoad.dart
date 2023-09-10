import 'dart:convert';
import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/longLog.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<Map?> walletTrasferLoad(
    context, walletId, amount, currency, payment_for) async {
  Map walletIDMap = {
    "other_user_wallet_ID": walletId,
    "amount_to_send": amount,
    "currency": currency,
    "payment_for": payment_for
  };
  Map walletList =
      jsonDecode(await apiRequest(walletToWalletUrl, walletIDMap, context));
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
    walletTrasferLoad(context, walletId, amount, currency, payment_for);
  } else {
    return walletList;
  }
}

Future<Map?> walletTrasferLoadInvoice(
    context, walletId, amount, currency, payment_for, clanId) async {
  Map walletIDMap = {
    "other_user_wallet_ID": walletId,
    "amount_to_send": amount,
    "currency": currency,
    "payment_for": payment_for,
    'clan_id': clanId
  };
  Map walletList =
      jsonDecode(await apiRequest(walletToWalletClanUrl, walletIDMap, context));
  String status = walletList['status'];
  String message = walletList['message'];
  showToast(message.toString());
  if (status == success_status) {
    return walletList;
  } else if (status == unauthorized_status) {
    await checkLoginStatus(context);
    return walletList;
  } else if (status == expire_token_status) {
    jsonDecode(await apiRefreshRequest(context));
    walletTrasferLoad(context, walletId, amount, currency, payment_for);
  } else {
    return walletList;
  }
}
