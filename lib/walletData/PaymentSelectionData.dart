import 'dart:convert';

import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/widget/button.dart';
import 'package:avauserapp/components/widget/rowListTile.dart';
import 'package:avauserapp/components/widget/text.dart';
import 'package:avauserapp/components/widget/textfield.dart';
import 'package:avauserapp/screens/paymentSetup/AccountSetupUpdate.dart';
import 'package:flutter/material.dart';

import 'pinCheck.dart';

class WalletSelectionData extends StatefulWidget {
  WalletSelectionData({Key? key, this.walletData, this.cardDetail}) : super();

  var walletData;
  var cardDetail;

  @override
  _WalletSelectionDataState createState() => _WalletSelectionDataState();
}

class _WalletSelectionDataState extends State<WalletSelectionData> {
  var walletBalance = "0.00";
  var Amount = false;
  var Currency = false;
  String tag_add_hint = "";
  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    paymentCheck();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var topspaceInnerBoxheight = MediaQuery.of(context).size.height / 15;
    var leftRightspaceInnerBoxheight = MediaQuery.of(context).size.height / 56;
    var boxspaceInnerBoxheight = MediaQuery.of(context).size.height / 4;
    return new Scaffold(
      bottomNavigationBar: bottonButton(context),
      appBar: AppBar(
        title: Text(
          "Wallet",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Container(
          child: Center(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    color: AppColours.appTheme,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 3,
                    child: Padding(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            color: AppColours.dartTheme,
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    allTranslations.text("Balance"),
                                    style: TextStyle(
                                        color: AppColours.whiteColour),
                                  ),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  Text(
                                    "XOF " + walletBalance.toString(),
                                    style: TextStyle(
                                        color: AppColours.whiteColour,
                                        fontSize: 22.0),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(30.0),
                            ),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.fromLTRB(
                          leftRightspaceInnerBoxheight,
                          topspaceInnerBoxheight,
                          leftRightspaceInnerBoxheight,
                          0.0),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 220.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height / 1.5,
                    width: size.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(30),
                        topLeft: Radius.circular(30),
                      ),
                      border: Border.all(
                        width: 3,
                        color: Colors.white,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            headerText(
                                text: "Top-Up Wallet",
                                size: 22.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                            amountSelection(size),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  AddWalletBtn(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 12.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: ButtonTheme(
              minWidth: 200.0,
              height: 50.0,
              buttonColor: AppColours.appTheme,
              child: MaterialButton(
                elevation: 8.0,
                shape: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColours.appTheme),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                onPressed: () async {
                  var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AccountSetUpUpdate(
                                payment_mode: "phone",
                                paymentFor: "3",
                                // wallet for 3
                                referenceId: "0",
                                merchantId: "0",
                                cpm_trans_id: "",
                                amount: "",
                                record: "",
                              )));
                  if (result == null || result == "null") {
                  } else {
                    paymentCheck();
                  }
                },
                child: Text(
                  allTranslations.text('Proceedforpayment'),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  spaceHeight() {
    return SizedBox(height: 20.0);
  }

  void paymentCheck() async {
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck == true) {
      Map decoded = jsonDecode(await getApiDataRequest(myWallettUrl, context));
      String status = decoded['status'];
      if (status == success_status) {
        var record = decoded['record'];
        var wallet_setup_done = record['wallet_setup_done'];
        if (wallet_setup_done == "true") {
          setState(() {
            var wallet_balance = record['wallet_balance'];
            walletBalance = wallet_balance.toString();
          });
        }
      } else if (status == unauthorized_status) {
        await checkLoginStatus(context);
      } else if (status == already_login_status) {
      } else if (status == data_not_found_status) {
      } else if (status == expire_token_status) {
        jsonDecode(await apiRefreshRequest(context));
        paymentCheck();
      } else {}
    }
  }

  amountSelection(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        walletRow(
            keyName: "Amount",
            icon: Icon(Amount ? Icons.arrow_drop_up : Icons.arrow_drop_down),
            onTap: () {
              setState(() {
                if (Amount) {
                  Amount = false;
                } else {
                  Amount = true;
                }
              });
            }),
        Amount
            ? Padding(
                padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                child: normalTextfield(
                    controller: amountController,
                    hintText: allTranslations.text('EnterAmount'),
                    keyboardType: TextInputType.number,
                    borderColour: Colors.black45),
              )
            : SizedBox.shrink(),
      ],
    );
  }

  bottonButton(context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: SizedBox(
        height: 60.0,
        child: fullColouredBtn(
            text: allTranslations.text('topupwallet').toUpperCase(),
            radiusButtton: 35.0,
            onPressed: () {
              if (amountController.text.toString().trim().toString() == "") {
                showToast("Please enter Amount.");
              } else {
                var amountDetail = {
                  "amount": amountController.text,
                };
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PinCheck(
                          walletData: widget.walletData,
                          cardDetail: widget.cardDetail,
                          amountDetail: amountDetail)),
                );
                //    List<Map> cinetpayCurrencyMap;
                //   String cinetpayCurrencyFirstValue;
              }
            }),
      ),
    );
  }
}
