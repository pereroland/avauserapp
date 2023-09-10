import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/dataLoad/checkPaymentLoad.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/navigation/navigationPayment.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/widget/button.dart';
import 'package:avauserapp/components/widget/pinSetWidget.dart';
import 'package:avauserapp/components/widget/text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinCheck extends StatefulWidget {
  PinCheck(
      {Key? key,
      this.walletData,
      this.cardDetail,
      this.amountDetail,
      this.topup})
      : super(key: key);
  var walletData, cardDetail, amountDetail, topup;

  @override
  _PinCheckState createState() => _PinCheckState();
}

class _PinCheckState extends State<PinCheck> {
  final formKey = GlobalKey<FormState>();
  var firstData = true;
  var secondData = true;
  var loading = false;
  var firstOtp = "";
  var secondOtp = "";
  var rightOtp = "0000";
  TextEditingController controller = TextEditingController();
  var description;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllData();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: bottonConfirmButton(context),
      appBar: AppBar(
        title: Text(
          allTranslations.text('PinCode'),
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              children: [enterPinSelectField(size, context)],
            ),
          ),
        ),
      ),
    );
  }

  enterPinSelectField(size, context) {
    return Padding(
      padding: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: Form(
        key: formKey,
        child: Padding(
            padding: const EdgeInsets.symmetric(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*firstData
                    ? firstScreen(size, context)
                    : secondScreen(size, context)*/
                secondScreen(size, context)
              ],
            )),
      ),
    );
  }

  firstScreen(size, context) {
    return Column(
      children: [
        headerText(
            text: allTranslations.text('Enterfourdigitspincode'),
            size: 16.0,
            color: Colors.black45,
            fontWeight: FontWeight.w200),
        SizedBox(
          height: 10.0,
        ),
        controllerpinSetWidget(
            context: context,
            controller: controller,
            onChanged: (value) {
              setState(() {
                firstOtp = value;
              });
            }),
      ],
    );
  }

  secondScreen(size, context) {
    return Column(
      children: [
        headerText(
            text: allTranslations.text('Confirm4digitspincode'),
            size: 16.0,
            color: Colors.black45,
            fontWeight: FontWeight.w200),
        SizedBox(
          height: 10.0,
        ),
        controllerpinSetWidget(
            context: context,
            controller: controller,
            onChanged: (value) {
              setState(() {
                secondOtp = value;
              });
            }),
      ],
    );
  }

  bottonConfirmButton(context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: SizedBox(
        height: 60.0,
        child: fullColouredBtn(
            text: allTranslations.text('Next').toUpperCase(),
            radiusButtton: 35.0,
            onPressed: () {
              if (mounted)
                setState(() {
                  secondOtpCheck(context);
                });
            }),
      ),
    );
  }

  void secondOtpCheck(context) {
    if (secondOtp.length < 4) {
      showToast(allTranslations.text("please_enter_confirm_pin"));
    } else {
      if (secondOtp == rightOtp) {
        walletPaymentAndCreate(context);
      } else {
        showToast(allTranslations.text("please_enter_right_otp"));
      }
    }
  }

  void walletPaymentAndCreate(context) {
    if (widget.topup.toString() == "direct") {
      NavigateScreen(
          context: context,
          amount: widget.amountDetail['amount'],
          phone_number: widget.cardDetail['phone_number'],
          phone_prefix: widget.cardDetail['phone_prefix'],
          paymentFor: "3",
          walletCheck: '0');
    } else {
      paymentCheck(context);
    }
  }

  Upload(BuildContext context) async {
    setState(() {
      loading = true;
    });

    description = widget.cardDetail['description'];
    if (description.toString().length < 1) {
      description = "Wallet Recharge";
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authtoken = prefs.getString('authtoken') ?? "";

    Map<String, String> headers = {"authtoken": authtoken};
    var uri = Uri.parse(addWalletDataUrl);
    var request = new http.MultipartRequest("POST", uri);
    request.headers.addAll(headers);
    walletDataCheck(request, context);
  }

  void getAllData() {
    if (mounted)
      setState(() {
        rightOtp = widget.walletData['auth_pin_code'];
      });
  }

  Future<void> walletDataCheck(request, context) async {
    var id = "";
    var walletID = "";
    var IDProofType = "";
    var IDNumber = "";
    var authPinCode = "";
    if (widget.walletData['id'].toString() == "Already setup") {
    } else {
      var stream = new http.ByteStream(DelegatingStream.typed(
          widget.walletData['ID_image_front'].openRead()));
      var length = await widget.walletData['ID_image_front'].length();
      var multipartFileIdentityFront = new http.MultipartFile(
          'ID_image_front', stream, length,
          filename: basename(widget.walletData['ID_image_front'].path));
      request.files.add(multipartFileIdentityFront);
      var streamback = new http.ByteStream(DelegatingStream.typed(
          widget.walletData['ID_image_back'].openRead()));
      var lengthback = await widget.walletData['ID_image_back'].length();
      var multipartFileIdentityBack = new http.MultipartFile(
          'ID_image_back', streamback, lengthback,
          filename: basename(widget.walletData['ID_image_back'].path));
      request.files.add(multipartFileIdentityBack);

      id = widget.walletData['id'];
      walletID = widget.walletData['wallet_ID'];
      IDProofType = widget.walletData['ID_proof_type'];
      authPinCode = rightOtp;
      IDNumber = widget.walletData['ID_number'];
    }

    request.fields['id'] = id;
    request.fields['wallet_ID'] = walletID;
    request.fields['ID_proof_type'] = IDProofType;
    request.fields['Accept-Language'] =
        jsonEncode(allTranslations.locale.toString());
    request.fields['auth_pin_code'] = authPinCode;
    request.fields['ID_number'] = IDNumber;
    reQuestParm(request, context);
  }

  Future<void> reQuestParm(request, context) async {
    request.fields['market'] = widget.cardDetail['market'];
    request.fields['operator'] = widget.cardDetail['operator'];
    request.fields['phone_number'] = widget.cardDetail['phone_number'];
    request.fields['phone_prefix'] = widget.cardDetail['phone_prefix'];
    request.fields['description'] = description;
    request.fields['currency'] = widget.amountDetail['currency'];

    var response = await request.send();
    response.stream.transform(utf8.decoder).listen((value) async {
      Map data = jsonDecode(await value);
      String status = data['status'];
      String message = data['message'];
      if (status == "200") {
        NavigateScreen(
            context: context,
            amount: widget.amountDetail['amount'],
            phone_number: widget.cardDetail['phone_number'],
            phone_prefix: widget.cardDetail['phone_prefix'],
            paymentFor: "3",
            walletCheck: '0');
      } else if (status == "408") {
        jsonDecode(await apiRefreshRequest(context));
        Upload(context);
      } else {
        showToast(message);
      }
    });
    setState(() {
      loading = false;
    });
  }

  Future paymentCheck(context) async {
    await paymentModeLoad(context, widget.walletData, widget.cardDetail,
        widget.amountDetail, "Payment");
  }
}
