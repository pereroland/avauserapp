import 'dart:async';

import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/dataLoad/marketCurrencyLoad.dart';
import 'package:avauserapp/components/dataLoad/myWallettModeLoad.dart';
import 'package:avauserapp/components/dataLoad/payoutSave.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/widget/appbar.dart';
import 'package:avauserapp/components/widget/button.dart';
import 'package:avauserapp/components/widget/text.dart';
import 'package:avauserapp/components/widget/textfield.dart';
import 'package:avauserapp/screens/home/baseTabClass.dart';
import 'package:flutter/material.dart';

class PayoutScreen extends StatefulWidget {
  @override
  _PayoutScreenState createState() => _PayoutScreenState();
}

class _PayoutScreenState extends State<PayoutScreen> {
  var loadding = true;
  var wallet_balance = "0.00";
  var payout_balance = "0.00";
  var currency = "";
  bool refresh = false;
  var currencyId = "";
  var wallet_ID = "";
  var auth_pin_code = "";
  int? selectedRadio;
  int paymentSelection = 1;
  var access_option = "2";

  TextEditingController amountController = TextEditingController();
  TextEditingController currencyController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController phonePrefixController = TextEditingController();
  String tag_add_hint = "";

  List<Map>? cinetpayMarketMap;
  List ciNetPayMargins = [];
  var cinetpayMarketFirstValue;
  List<Map>? cinetpayOperatorPhoneMap;
  var cinetpayOperatorPhoneFirstValue;
  var paymentType = allTranslations.text('cashBankCard');
  final _formKey = GlobalKey<FormState>();
  double feePercentage = 0.0;
  double marginPercentage = 0.0;
  bool send = false;
  String? marketId, operatorId, finalAmount;
  var type = "",
      amount = "",
      currency_id = "",
      method = "",
      description = "",
      market = "",
      operator = "",
      phone_number = "",
      prefix = "";

  @override
  void initState() {
    super.initState();
    selectedRadio = 1;
    amountController.addListener(() {
      getAmount();
    });
    initDataCall();
  }

  checkMarginByOperator() {
    if (ciNetPayMargins.isNotEmpty) {
      final data = ciNetPayMargins.where((element) =>
          element["market_id"] == marketId &&
          element["operator_id"] == operatorId);
      if (data.isNotEmpty) {
        try {
          feePercentage = double.parse(data.first["fee"]);
          marginPercentage = double.parse(data.first["margin"]);
          getAmount();
        } catch (_) {
          marginPercentage = 0.0;
          feePercentage = 0.0;
          getAmount();
        }
      } else {
        marginPercentage = 0.0;
        feePercentage = 0.0;
        getAmount();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var topspaceInnerBoxheight = MediaQuery.of(context).size.height / 22;
    var leftRightspaceInnerBoxheight = MediaQuery.of(context).size.height / 56;
    return WillPopScope(
      onWillPop: () {
        backNavigation(context);
        return Future.value(false);
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          bottomNavigationBar: loadding ? SizedBox.shrink() : bottonButton(),
          appBar: appBarWidget(
              text: allTranslations.text('Payout'),
              textColour: Colors.black,
              backgroundColour: Colors.white,
              onTap: () {
                backNavigation(context);
              },
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    refresh = true;
                    if (mounted) setState(() {});
                    await getDetailPrevious();
                    refresh = false;
                    if (mounted) setState(() {});
                  },
                  child: !refresh
                      ? Icon(
                          Icons.refresh,
                          color: Colors.black,
                        )
                      : SizedBox.square(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                          dimension: 20.0,
                        ),
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.transparent),
                      elevation: MaterialStateProperty.all(0.0)),
                )
              ]),
          body: loadding
              ? Container(
                  height: size.height,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20.0, right: 20.0),
                      child:
                          Image.asset('assets/PaymentCards/payment_image.webp'),
                    ),
                  ),
                )
              : Container(
                  child: Center(
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            color: AppColours.appTheme,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height / 2.5,
                            child: Padding(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    color: AppColours.dartTheme,
                                    width: MediaQuery.of(context).size.width,
                                    child: Padding(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                            currency + " " + payout_balance,
                                            style: TextStyle(
                                                color: AppColours.whiteColour,
                                                fontSize: 22.0),
                                          ),
                                          SizedBox(
                                            height: 20.0,
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.all(20.0),
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
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height / 4.2),
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
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      headerText(
                                          text: allTranslations
                                              .text('SelectPaymentMode'),
                                          size: 22.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      ButtonTheme(
                                          alignedDropdown: true,
                                          child: DropdownButton<String>(
                                            isExpanded: true,
                                            items: <String>[
                                              allTranslations
                                                  .text('cashBankCard'),
                                              allTranslations.text('mobile'),
                                              allTranslations
                                                  .text('ecobankCash')
                                            ].map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: new Text(value),
                                              );
                                            }).toList(),
                                            onChanged: (data) {
                                              if (mounted)
                                                setState(() {
                                                  paymentType = data!;
                                                  if (paymentType ==
                                                      allTranslations.text(
                                                          'cashBankCard')) {
                                                    paymentSelection = 1;
                                                    selectedRadio = 1;
                                                  } else if (paymentType ==
                                                      allTranslations
                                                          .text('mobile')) {
                                                    paymentSelection = 2;
                                                    checkMarginByOperator();
                                                    selectedRadio = 2;
                                                  } else {
                                                    paymentSelection = 3;
                                                    selectedRadio = 3;
                                                  }
                                                });
                                            },
                                            hint: Text(paymentType),
                                          )),
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      paymentSelection == 1
                                          ? cashBankCardSelection()
                                          : SizedBox.shrink(),
                                      paymentSelection == 1
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                top: 20,
                                              ),
                                              child: cashBankCard(),
                                            )
                                          : paymentSelection == 2
                                              ? mobilePayDesign()
                                              : ecoBankPayDesign()
                                    ],
                                  ),
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
      ),
    );
  }

  setSelectedRadio(int? val) {
    setState(() {
      selectedRadio = val;
    });
  }

  void backNavigation(context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TabBarController(0)),
    );
  }

  bottonButton() {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: SizedBox(
        height: 50.0,
        child: send
            ? loadingButton(size)
            : fullColouredBtn(
                text: allTranslations.text('send').toUpperCase(),
                radiusButtton: 35.0,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (finalAmount == null &&
                        paymentSelection.toString() == "2") {
                      showToast(
                          allTranslations.text("operatorAndMarketValidation"));
                    } else {
                      topUpPayoutCheck(context);
                    }
                  }
                },
              ),
      ),
    );
  }

  void topUpPayoutCheck(context) {
    if (wallet_balance.toString() == 'null') {
      showToast(allTranslations.text("insufficientAmountMessage"));
      return;
    } else if (int.parse(wallet_balance.toString()) < 1) {
      showToast(allTranslations.text("insufficientAmountMessage"));
      return;
    }
    if (paymentSelection.toString() == "1") {
      //cash
      cashSelectionData();
    } else if (paymentSelection.toString() == "2") {
      //mobile
      mobileSelectionData();
    } else {
      //eco bank
      ecobankSelectionData();
    }
    Map map = {
      "type": type,
      "amount": amount,
      "currency_id": currency_id,
      "method": method,
      "description": description,
      "market": market,
      "operator": operator,
      "phone_number": phone_number,
      "prefix": prefix
    };
    send = true;
    if (mounted) setState(() {});
    SetPayoutLoad(map: map, context: context)
        .then((value) => {callFuntion(value!)})
        .onError((error, stackTrace) => {
              if (mounted)
                {
                  send = false,
                  setState(() {}),
                  showToast(error.toString()),
                }
            });
  }

  void initDataCall() {
    getMarketData();
    getDetailPrevious();
  }

  Future<void> getDetailPrevious() async {
    Map? detail = await myWalletModeLoad(context);
    if (detail != null) {
      if (detail['status'] == "200") {
        List list = detail['record'];
        var data = list[0];
        var balance = data['wallet_balance'].toString();
        if (mounted)
          setState(() {
            if (balance ==
                    'nul l;;;;;;;;;;;;;;.............................lnkml' ||
                balance == '') {
              wallet_balance = "0.00";
            } else {
              currency = data['currency'].toString();
              currencyController.text = currency;
              currencyId = data['currency_id'].toString();
              wallet_balance = balance;
              payout_balance = detail["payout"] != null
                  ? detail["payout"].toString().replaceAll("-", "")
                  : "0.00";
              wallet_ID = data['wallet_ID'].toString();
              auth_pin_code = data['auth_pin_code'].toString();
            }
            loadding = false;
          });
      }
    }
  }

  List<Map> allOperator = [];

  checkOperatorList() {
    allOperator = [];
    cinetpayOperatorPhoneMap?.forEach((operator) {
      if (marketId == operator["marketId"]) {
        allOperator.add(operator);
      }
    });
    try {
      cinetpayOperatorPhoneFirstValue = allOperator.first["name"];
    } catch (_) {}
    if (mounted) setState(() {});
  }

  cashPayDesign() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
          child: normalFormTextfield(
              controller: amountController,
              hintText: allTranslations.text('Amount'),
              borderColour: Colors.black45),
        ),
        SizedBox(
          height: 10.0,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
          child: normalFormTextfield(
              controller: currencyController,
              hintText: allTranslations.text('Currency'),
              keyboardType: TextInputType.number,
              borderColour: Colors.black45,
              readOnly: true),
        ),
        SizedBox(
          height: 10.0,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
          child: normalFormTextfield(
              controller: descriptionController,
              hintText: allTranslations.text('description'),
              keyboardType: TextInputType.text,
              borderColour: Colors.black45),
        ),
      ],
    );
  }

  getAmount() {
    if (amountController.text.isNotEmpty) {
      if (feePercentage != 0.0 && marginPercentage != 0.0) {
        try {
          double amount = double.parse(amountController.text);
          double totalPercentage = feePercentage + marginPercentage;
          double amountCheck =
              (amount + (amount * totalPercentage / 100).roundToDouble());
          double returnAmount;
          if (amountCheck < 100) {
            double r = 100 - amountCheck;
            returnAmount = amountCheck + r;
          } else {
            double r = amountCheck.remainder(5);
            r = 5 - r;
            returnAmount = amountCheck + r.roundToDouble();
          }
          finalAmount = "${returnAmount.toInt()}";
        } catch (d) {
          finalAmount = null;
        }
      } else {
        finalAmount = null;
      }
    } else {
      finalAmount = null;
    }
    if (mounted) setState(() {});
  }

  mobilePayDesign() {
    return cinetpayMarketMap != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    items: cinetpayMarketMap!.map((Map map) {
                      return new DropdownMenuItem<String>(
                        value: map["name"].toString(),
                        onTap: () {
                          marketId = map["id"];
                          checkMarginByOperator();
                          checkOperatorList();
                        },
                        child: new Text(
                          map["name"],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        cinetpayMarketFirstValue = value;
                      });
                    },
                    hint: Text(tag_add_hint),
                    value: cinetpayMarketFirstValue,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    items: allOperator.map((Map map) {
                      return DropdownMenuItem<String>(
                        value: map["name"].toString(),
                        onTap: () {
                          operatorId = map["id"];
                          checkMarginByOperator();
                        },
                        child: new Text(
                          map["name"],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        cinetpayOperatorPhoneFirstValue = value;
                      });
                    },
                    hint: Text(tag_add_hint),
                    value: cinetpayOperatorPhoneFirstValue,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 10.0),
                child: TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black45),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black45),
                      ),
                      hintText: allTranslations.text('Amount'),
                      hintStyle: TextStyle(color: Colors.black)),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return '${allTranslations.text('PleaseEnterAmount')}';
                    }
                    return null;
                  },
                ),
              ),
              if (finalAmount != null)
                if (finalAmount!.trim().isNotEmpty)
                  Padding(
                      padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0.0),
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${allTranslations.text("finalAmountAfterFee")}:- $finalAmount",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 15),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Divider(
                              color: Colors.black45,
                              height: 2,
                              thickness: 1.2,
                            )
                          ],
                        ),
                      )),
              Padding(
                padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                child: normalFormTextfield(
                    controller: phoneNumberController,
                    hintText: allTranslations.text('EnterNumber'),
                    keyboardType: TextInputType.phone,
                    borderColour: Colors.black45),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 10.0),
                child: normalFormTextfield(
                    controller: phonePrefixController,
                    hintText: allTranslations.text('EnterPhonePrefixe'),
                    keyboardType: TextInputType.phone,
                    borderColour: Colors.black45),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                child: normalFormTextfield(
                    controller: descriptionController,
                    hintText: allTranslations.text('description'),
                    keyboardType: TextInputType.emailAddress,
                    borderColour: Colors.black45),
              )
            ],
          )
        : SizedBox.shrink();
  }

  ecoBankPayDesign() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
          child: normalFormTextfield(
              controller: amountController,
              hintText: allTranslations.text('Amount'),
              keyboardType: TextInputType.number,
              borderColour: Colors.black45),
        ),
        SizedBox(
          height: 10.0,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
          child: normalFormTextfield(
              controller: currencyController,
              hintText: allTranslations.text('Currency'),
              keyboardType: TextInputType.number,
              borderColour: Colors.black45,
              readOnly: true),
        ),
        SizedBox(
          height: 10.0,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
          child: normalFormTextfield(
              controller: nameController,
              hintText: allTranslations.text('name'),
              keyboardType: TextInputType.text,
              borderColour: Colors.black45),
        ),
        SizedBox(
          height: 10.0,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
          child: normalFormTextfield(
              controller: phoneNumberController,
              hintText: allTranslations.text('phone'),
              keyboardType: TextInputType.text,
              borderColour: Colors.black45),
        ),
        SizedBox(
          height: 10.0,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton<String>(
              isExpanded: true,
              items: cinetpayMarketMap!.map((Map map) {
                return new DropdownMenuItem<String>(
                  value: map["name"].toString(),
                  child: new Text(
                    map["name"],
                  ),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  cinetpayMarketFirstValue = value;
                });
              },
              hint: Text(tag_add_hint),
              value: cinetpayMarketFirstValue,
            ),
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        // Padding(
        //   padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        //   child: ButtonTheme(
        //     alignedDropdown: true,
        //     child: DropdownButton<String>(
        //       isExpanded: true,
        //       items: cinetpayOperatorPhoneMap.map((Map map) {
        //         return new DropdownMenuItem<String>(
        //           value: map["name"].toString(),
        //           child: new Text(
        //             map["name"],
        //           ),
        //         );
        //       }).toList(),
        //       onChanged: (String value) {
        //         setState(() {
        //           cinetpayOperatorPhoneFirstValue = value;
        //         });
        //       },
        //       hint: Text(tag_add_hint),
        //       value: cinetpayOperatorPhoneFirstValue,
        //     ),
        //   ),
        // ),
        // SizedBox(
        //   height: 10.0,
        // ),
        Padding(
          padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
          child: normalFormTextfield(
              controller: descriptionController,
              hintText: allTranslations.text('description'),
              keyboardType: TextInputType.emailAddress,
              borderColour: Colors.black45),
        )
      ],
    );
  }

  Future<void> getMarketData() async {
    await getMarketDataList(context: context)
        .then((value) => {dataSet(value ?? {})})
        .onError((error, stackTrace) => {
              showToast(error.toString()),
            });
  }

  dataSet(Map value) {
    if (mounted)
      setState(() {
        marketId = value["market_id"];
        operatorId = value["operator_id"];
        ciNetPayMargins = value["margin_fee"];
        cinetpayMarketMap = value['cinetpayMarketMap'];
        cinetpayMarketFirstValue = value['cinetpayMarketFirstValue'];
        cinetpayOperatorPhoneFirstValue =
            value['cinetpayOperatorPhoneFirstValue'];
        cinetpayOperatorPhoneMap = value['cinetpayOperatorPhoneMap'];
        checkOperatorList();
      });
  }

  cashBankCard() {
    return Column(
      children: [
        selectedRadio == 1 ? cashPayDesign() : SizedBox.shrink(),
        selectedRadio == 2 ? cashPayDesign() : SizedBox.shrink(),
        selectedRadio == 3 ? cashPayDesign() : SizedBox.shrink(),
        selectedRadio == 4 ? mobilePayDesign() : SizedBox.shrink(),
      ],
    );
  }

  cashBankCardSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Radio(
              value: 1,
              groupValue: selectedRadio,
              onChanged: (int? val) {
                access_option = "1";
                setSelectedRadio(val);
              },
            ),
            Text(allTranslations.text('cash'))
          ],
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Radio(
              value: 2,
              groupValue: selectedRadio,
              onChanged: (int? val) {
                access_option = "2";
                setSelectedRadio(val);
              },
            ),
            Text(allTranslations.text('bank'))
          ],
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Radio(
              value: 3,
              groupValue: selectedRadio,
              onChanged: (int? val) {
                access_option = "3";
                setSelectedRadio(val);
              },
            ),
            Text(allTranslations.text('card'))
          ],
        ),
      ],
    );
  }

  void cashSelectionData() {
    if (mounted)
      setState(() {
        if (selectedRadio.toString() == "1") {
          type = "1";
          amount = amountController.text;
          currency_id = currencyId;
          method = "Cash";
          description = descriptionController.text;
          market = "";
          operator = "";
          phone_number = "";
          prefix = "";
        } else if (selectedRadio.toString() == "2") {
          type = "1";
          amount = amountController.text;
          currency_id = currencyId;
          method = "Bank";
          description = descriptionController.text;
          market = "";
          operator = "";
          phone_number = "";
          prefix = "";
        } else {
          type = "1";
          amount = amountController.text;
          currency_id = currencyId;
          method = "Card";
          description = descriptionController.text;
          market = "";
          operator = "";
          phone_number = phoneNumberController.text;
          prefix = phonePrefixController.text;
        }
      });
  }

  void mobileSelectionData() {
    if (mounted)
      setState(() {
        type = "2";
        amount = amountController.text;
        currency_id = currencyId;
        method = "Phone";
        description = descriptionController.text;
        market = cinetpayMarketFirstValue;
        operator = cinetpayOperatorPhoneFirstValue;
        phone_number = phoneNumberController.text;
        prefix = phonePrefixController.text;
      });
  }

  void ecobankSelectionData() {
    if (mounted)
      setState(() {
        type = "3";
        amount = amountController.text;
        currency_id = currencyId;
        method = "ecobank";
        description = descriptionController.text;
        market = cinetpayMarketFirstValue;
        operator = cinetpayOperatorPhoneFirstValue;
        phone_number = phoneNumberController.text;
        prefix = phonePrefixController.text;
      });
  }

  callFuntion(Map value) {
    send = false;
    if (mounted) setState(() {});
    showToast(value['message'].toString());
    Navigator.pop(context);
  }
}
