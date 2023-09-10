import 'dart:convert';

import 'package:async/async.dart';
import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/navigation/navigationPayment.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/walletData/DetailPageData.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'myWallettModeLoad.dart';

// Future<Map<dynamic, dynamic>?> paymentModeLoad(context, walletData, cardDetail,
//     amountDetail, auth_pin_code_pin, String type) async {
//   var id = "";
//   var wallet_ID = "";
//   var ID_proof_type = "";
//   var ID_number = "";
//   var auth_pin_code = "";
//   var currency = "";
//
//   //  var walletData, cardDetail, amountDetail;
//
//   var description = cardDetail['description'];
//   if (description.toString().length < 1) {
//     description = "Wallet Recharge";
//   }
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String authtoken = prefs.getString('authtoken') ?? "";
//
//   Map<String, String> headers = {"authtoken": authtoken};
//   var uri = Uri.parse(addWalletDataUrl);
//   var request = new http.MultipartRequest("POST", uri);
//   request.headers.addAll(headers);
//   if (walletData['id'].toString() == "Already setup") {
//   } else {
//     var stream = new http.ByteStream(
//         DelegatingStream.typed(walletData['ID_image_front'].openRead()));
//     var length = await walletData['ID_image_front'].length();
//     var multipartFile_identity_front = new http.MultipartFile(
//         'ID_image_front', stream, length,
//         filename: basename(walletData['ID_image_front'].path));
//     request.files.add(multipartFile_identity_front);
//     var streamback = new http.ByteStream(
//         DelegatingStream.typed(walletData['ID_image_back'].openRead()));
//     var lengthback = await walletData['ID_image_back'].length();
//     var multipartFile_identity_back = new http.MultipartFile(
//         'ID_image_back', streamback, lengthback,
//         filename: basename(walletData['ID_image_back'].path));
//     request.files.add(multipartFile_identity_back);
//
//     id = walletData['id'].toString();
//     wallet_ID = walletData['wallet_ID'];
//     ID_proof_type = walletData['ID_proof_type'];
//     auth_pin_code = auth_pin_code_pin;
//     ID_number = walletData['ID_number'];
//     currency = walletData['currency_name'];
//   }
//
//   request.fields['id'] = id;
//   request.fields['wallet_ID'] = wallet_ID;
//   request.fields['ID_proof_type'] = ID_proof_type;
//   request.fields['auth_pin_code'] = auth_pin_code;
//   request.fields['ID_number'] = ID_number;
//   request.fields['market'] = cardDetail['market'];
//   request.fields['operator'] = cardDetail['operator'];
//   request.fields['phone_number'] = cardDetail['phone_number'];
//   request.fields['phone_prefix'] = cardDetail['phone_prefix'];
//   request.fields['description'] = description;
//   request.fields['currency'] = currency;
//   var response = await request.send();
//   response.stream.transform(utf8.decoder).listen((value) async {
//     Map data = await jsonDecode(value);
//     String status = data['status'];
//     String message = data['message'];
//     if (status == "200") {
//       if (type == "Payment") {
//         NavigateScreen(
//             context: context,
//             amount: amountDetail['amount'],
//             phone_number: cardDetail['phone_number'],
//             phone_prefix: cardDetail['phone_prefix'],
//             paymentFor: "3",
//             walletCheck: "0");
//       } else {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => DetailPageData()),
//         );
//       }
//       // return data;
//     } else if (status == "408") {
//       jsonDecode(await apiRefreshRequest(context));
//       paymentModeLoad(
//           context, walletData, cardDetail, amountDetail, auth_pin_code, type);
//     } else {
//       showToast(message);
//       // return data;
//     }
//   });
// }

paymentModeLoad(
    context, walletData, cardDetail, amountDetail, String type) async {
  String idProofType = "", idNumber = "";
  var description = cardDetail['description'];
  if (description.toString().length < 1) {
    description = "Wallet Recharge";
  }
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String authtoken = prefs.getString('authtoken')!;
  Map<String, String> headers = {"authtoken": authtoken};
  var uri = Uri.parse(addWalletDataUrl);
  var request = http.MultipartRequest("POST", uri);
  request.headers.addAll(headers);
  if (walletData.containsKey("ID_image_front")) {
    var stream = http.ByteStream(
        DelegatingStream.typed(walletData['ID_image_front'].openRead()));
    var length = await walletData['ID_image_front'].length();
    var multipartFile_identity_front = http.MultipartFile(
        'ID_image_front', stream, length,
        filename: basename(walletData['ID_image_front'].path));
    request.files.add(multipartFile_identity_front);
    var streamback = http.ByteStream(
        DelegatingStream.typed(walletData['ID_image_back'].openRead()));
    var lengthback = await walletData['ID_image_back'].length();
    var multipartFile_identity_back = http.MultipartFile(
        'ID_image_back', streamback, lengthback,
        filename: basename(walletData['ID_image_back'].path));
    request.files.add(multipartFile_identity_back);
    idProofType = walletData["ID_proof_type"];
    idNumber = walletData["ID_number"];
  }
  if (walletData["currency_name"] == null ||
      walletData["currency_name"] == "null" ||
      walletData["currency_name"] == "" ||
      idNumber == "" ||
      idProofType == "") {
    Map detail = await myWalletModeLoad(context) ?? {};
    if (detail['status'] == "200") {
      walletData["currency_name"] = detail['record'][0]["currency"];
      idNumber = detail['record'][0]["ID_number"];
      idProofType = detail['record'][0]["ID_proof_type"];
    }
  }
  request.fields['id'] = walletData['id'].toString();
  request.fields['wallet_ID'] = walletData["wallet_id"];
  request.fields['ID_proof_type'] = idProofType;
  request.fields['auth_pin_code'] = walletData['auth_pin_code'];
  request.fields['ID_number'] = idNumber;
  request.fields['market'] = cardDetail['market'];
  request.fields['Accept-Language'] =
      jsonEncode(allTranslations.locale.toString());
  request.fields['operator'] = cardDetail['operator'];
  request.fields['phone_number'] = cardDetail['phone_number'];
  request.fields['phone_prefix'] = cardDetail['phone_prefix'];
  request.fields['description'] = description;
  request.fields['currency'] = walletData["currency_name"];
  var response = await request.send();
  response.stream.transform(utf8.decoder).listen((value) async {
    Map data = jsonDecode(await value);
    String? status = data['status'];
    String? message = data['message'];
    if (status == "200") {
      if (type == "Payment") {
        NavigateScreen(
            context: context,
            amount: amountDetail['amount'],
            phone_number: cardDetail['phone_number'],
            phone_prefix: cardDetail['phone_prefix'],
            paymentFor: "3",
            walletCheck: "0");
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailPageData()),
        );
      }
    } else if (status == "408") {
      jsonDecode(await apiRefreshRequest(context));
      paymentModeLoad(context, walletData, cardDetail, amountDetail, type);
    } else {
      showToast(message!);
    }
  });
}
