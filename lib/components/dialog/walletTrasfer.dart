import 'dart:async';

import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/checkNumber.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/dataLoad/walletTransferLoad.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/widget/button.dart';
import 'package:avauserapp/components/widget/text.dart';
import 'package:avauserapp/components/widget/textfield.dart';
import 'package:avauserapp/main.dart';
import 'package:avauserapp/screens/home/baseTabClass.dart';
import 'package:flutter/material.dart';

Future<Map>? WalletTransferDialog(
    context,
    String walletBalance,
    String currency,
    String payment_for,
    TextEditingController walletIdController,
    TextEditingController amountController) {
  bool loading = false;
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            contentPadding: EdgeInsets.only(top: 0.0),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Container(
                width: 300.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                      decoration: BoxDecoration(
                        color: AppColours.appTheme,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0)),
                      ),
                      child: Text(
                        allTranslations.text('SendMoney'),
                        style: TextStyle(color: Colors.white, fontSize: 20.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: headerText(
                          text: allTranslations.text('EnterWalletId'),
                          size: 16.0,
                          color: AppColours.blacklightLineColour,
                          fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                      child: normalTextfield(
                          hintText: allTranslations.text('EnterID'),
                          controller: walletIdController,
                          keyboardType: TextInputType.multiline,
                          borderColour: Colors.black45),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: headerText(
                          text: allTranslations.text('Amount'),
                          size: 16.0,
                          color: AppColours.blacklightLineColour,
                          fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                      child: normalTextfield(
                          hintText: allTranslations.text('EnterAmount'),
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          borderColour: Colors.black45),
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: SizedBox(
                        height: 50.0,
                        child: loading
                            ? loadingButton(
                                Size(MediaQuery.of(context).size.width, 50))
                            : fullColouredBtn(
                                text: allTranslations
                                    .text('SendMoney')
                                    .toUpperCase(),
                                radiusButtton: 20.0,
                                onPressed: () async {
                                  if (walletIdController.text
                                          .toString()
                                          .trim()
                                          .toString() ==
                                      "") {
                                    showToast(allTranslations
                                        .text('PleaseEnterWalletId'));
                                  } else if (amountController.text
                                          .toString()
                                          .trim()
                                          .toString() ==
                                      "") {
                                    showToast(allTranslations
                                        .text('PleaseEnterAmount'));
                                  } else {
                                    var numberRight =
                                        isNumeric(amountController.text);
                                    if (numberRight) {
                                      int amount =
                                          int.parse(amountController.text);
                                      if (amount > 0) {
                                        FocusManager.instance.primaryFocus!
                                            .unfocus();
                                        loading = true;
                                        setState(() {});
                                        Map map = await walletTrasferLoad(
                                                context,
                                                walletIdController.text,
                                                amountController.text,
                                                currency,
                                                payment_for) ??
                                            {};
                                        loading = false;
                                        setState(() {});
                                        Navigator.pop(context, map);
                                      } else {
                                        showToast(allTranslations
                                            .text('PleaseEntertherightamount'));
                                      }
                                    } else {
                                      showToast(allTranslations
                                          .text('PleaseEntertherightamount'));
                                    }
                                  }
                                }),
                      ),
                    ),
                  ],
                ),
              );
            }));
      });
}

Future<Map>? WalletTransferDialogForInvoice(context, String walletBalance,
    String currency, String payment_for, String userId, clanId) {
  bool loading = false;
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            contentPadding: EdgeInsets.only(top: 0.0),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Container(
                width: 300.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                      decoration: BoxDecoration(
                        color: AppColours.appTheme,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0)),
                      ),
                      child: Text(
                        allTranslations.text('SendMoney'),
                        style: TextStyle(color: Colors.white, fontSize: 20.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: headerText(
                          text: allTranslations.text('EnterWalletId'),
                          size: 16.0,
                          color: AppColours.blacklightLineColour,
                          fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                      child: normalTextfield(
                          readOnly: true,
                          hintText: allTranslations.text('EnterID'),
                          controller: TextEditingController(text: userId),
                          keyboardType: TextInputType.name,
                          borderColour: Colors.black45),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: headerText(
                          text: allTranslations.text('Amount'),
                          size: 16.0,
                          color: AppColours.blacklightLineColour,
                          fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                      child: normalTextfield(
                          readOnly: true,
                          controller:
                              TextEditingController(text: walletBalance),
                          hintText: allTranslations.text('EnterAmount'),
                          keyboardType: TextInputType.number,
                          borderColour: Colors.black45),
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: SizedBox(
                        height: 50.0,
                        child: loading
                            ? loadingButton(
                                Size(MediaQuery.of(context).size.width, 50))
                            : fullColouredBtn(
                                text: allTranslations
                                    .text('SendMoney')
                                    .toUpperCase(),
                                radiusButtton: 20.0,
                                onPressed: () async {
                                  FocusManager.instance.primaryFocus!.unfocus();
                                  loading = true;
                                  setState(() {});
                                  Map map = await walletTrasferLoadInvoice(
                                          context,
                                          userId,
                                          walletBalance,
                                          currency,
                                          payment_for,
                                          clanId) ??
                                      {};
                                  loading = false;
                                  setState(() {});
                                  Navigator.pop(context, map);
                                  if (map['status'] == "200") {
                                    Navigator.pushAndRemoveUntil(
                                        navigatorKey.currentContext!,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TabBarController(0)),
                                        (route) => false);
                                  }
                                }),
                      ),
                    ),
                  ],
                ),
              );
            }));
      });
}
