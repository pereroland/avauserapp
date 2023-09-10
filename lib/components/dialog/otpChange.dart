import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/checkNumber.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/dataLoad/ChangePinLoad.dart';
import 'package:avauserapp/components/dataLoad/walletTransferLoad.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/widget/button.dart';
import 'package:avauserapp/components/widget/text.dart';
import 'package:avauserapp/components/widget/textfield.dart';
import 'package:avauserapp/main.dart';
import 'package:avauserapp/screens/home/baseTabClass.dart';
import 'package:flutter/material.dart';

Future pinChangeDialog(context, String oldOtp) {
  TextEditingController oldPinController = TextEditingController();
  TextEditingController newPinController = TextEditingController();
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            contentPadding: EdgeInsets.only(top: 0.0),
            content: StatefulBuilder(
                // You need this, notice the parameters below:
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
                        allTranslations.text('ChangePin'),
                        style: TextStyle(color: Colors.white, fontSize: 20.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                      child: normalTextfield(
                          hintText: allTranslations.text('EnterOldPin'),
                          controller: oldPinController,
                          maxlength: 4,
                          countertext: '',
                          keyboardType: TextInputType.number,
                          borderColour: Colors.black45),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                      child: normalTextfield(
                          hintText: allTranslations.text('EnterNewPin'),
                          controller: newPinController,
                          maxlength: 4,
                          countertext: '',
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
                        child: fullColouredBtn(
                            text: allTranslations.text('Apply'),
                            radiusButtton: 20.0,
                            onPressed: () async {
                              if (oldPinController.text
                                      .toString()
                                      .trim()
                                      .toString() ==
                                  "") {
                                showToast(
                                    allTranslations.text('PleaseEnterOldPin'));
                              } else if (newPinController.text
                                      .toString()
                                      .trim()
                                      .toString() ==
                                  "") {
                                showToast(
                                    allTranslations.text('PleaseEnterNewPin'));
                              } else {
                                if (oldPinController.text
                                        .toString()
                                        .trim()
                                        .toString() ==
                                    oldOtp) {
                                  if (newPinController.text.toString().length <
                                          4 ||
                                      newPinController.text.toString().length >
                                          4) {
                                    showToast(allTranslations
                                        .text('PleaseEnterFourDigitPin'));
                                  } else {
                                    Map map = await ChangePinLoad(
                                            context,
                                            oldPinController.text,
                                            newPinController.text) ??
                                        {};
                                    if (map['status'] == "200") {
                                      showToast(allTranslations
                                          .text('PinChangeSuccessfully'));
                                      Navigator.pop(context);
                                      navigatorKey.currentState!
                                          .pushReplacement(MaterialPageRoute(
                                              builder: (_) =>
                                                  TabBarController(0)));
                                    }
                                  }
                                } else {
                                  showToast(allTranslations
                                      .text('PleaseEnterTheCorrectOldPin'));
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
