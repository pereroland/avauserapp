import 'dart:async';

import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/dataLoad/checkPaymentLoad.dart';
import 'package:avauserapp/components/keyboardSIze.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/widget/appbar.dart';
import 'package:avauserapp/components/widget/button.dart';
import 'package:avauserapp/components/widget/rowListTile.dart';
import 'package:avauserapp/components/widget/textfield.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'PaymentSelectionData.dart';

class WalletPaymentMode extends StatefulWidget {
  WalletPaymentMode({
    Key? key,
    required this.cinetpayMarketMap,
    required this.cinetpayOperatorPhoneMap,
    required this.cinetpayMarketFirstValue,
    required this.cinetpayCurrencyFirstValue,
    required this.cinetpayOperatorPhoneFirstValue,
    this.walletData,
  }) : super(key: key);
  List<Map> cinetpayMarketMap, cinetpayOperatorPhoneMap;
  String cinetpayMarketFirstValue,
      cinetpayOperatorPhoneFirstValue,
      cinetpayCurrencyFirstValue;
  var walletData;

  @override
  _WalletPaymentModeState createState() => _WalletPaymentModeState();
}

//    List<Map>cinetpayMarketMap =[];
//     List<Map>cinetpayCurrencyMap =[];
//     List<Map>cinetpayOperatorPhoneMap =[];
class _WalletPaymentModeState extends State<WalletPaymentMode> {
  //National Id, passport, driver license

  String tag_add_hint = "";
  String tag = "National Id";
  var marketId = true;
  bool loader = false;
  var OperatorId = true;
  var PhoneId = true;
  var Currency = false;
  var PhonePrefixe = true;
  var Description = true;
  TextEditingController phone_number = TextEditingController();
  TextEditingController phone_prefix = TextEditingController();
  TextEditingController description = TextEditingController();

  @override
  void initState() {
    setData();
    super.initState();
  }

  setData() {
    if (widget.walletData.containsKey("description")) {
      phone_number.text = widget.walletData["phone_number"];
      phone_prefix.text = widget.walletData["prefix"];
      description.text = widget.walletData["description"];
      widget.cinetpayOperatorPhoneFirstValue = widget.walletData["operator"];
      widget.cinetpayMarketFirstValue =
          widget.walletData["market"] == "Cote d'Ivoire"
              ? "Cote d'ivoire"
              : widget.walletData["market"];
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: appBarWidget(
          text: 'Wallet Setup',
          textColour: Colors.black,
          backgroundColour: Colors.white,
          onTap: () {
            Navigator.pop(context);
          }),
      body: Scaffold(
        body: Padding(
          padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                MarketIdSet(size),
                SizedBox(
                  height: 20.0,
                ),
                OperatorIdIdSet(size),
                SizedBox(
                  height: 20.0,
                ),
                PhoneSet(size),
                SizedBox(
                  height: 20.0,
                ),
                Phone_prefixeSet(size),
                /* SizedBox(
                  height: 20.0,
                ),
                CurrencySet(size),*/
                SizedBox(
                  height: 20.0,
                ),
                DescriptionSet(size),
                SizedBox(
                  height: 20.0,
                ),
                bottonButton(size),
                keyBoardSize(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bottonButton(Size size) {
    return loader
        ? loadingButton(size)
        : Padding(
            padding: EdgeInsets.all(10.0),
            child: SizedBox(
              height: 140,
              child: Column(
                children: [
                  SizedBox(
                    height: 50.0,
                    width: size.width,
                    child: trasparentColouredBtn(
                      text: "save payment mode".toUpperCase(),
                      radiusButtton: 35.0,
                      onPressed: () {
                        savePhonePayment();
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  SizedBox(
                    height: 55.0,
                    width: size.width,
                    child: fullColouredBtn(
                        text: "save and CONTINUE".toUpperCase(),
                        radiusButtton: 35.0,
                        onPressed: () {
                          if (phone_number.text.toString().trim().toString() ==
                              "") {
                            showToast(allTranslations
                                .text("please_enter_phone_number"));
                          } else if (phone_prefix.text
                                  .toString()
                                  .trim()
                                  .toString() ==
                              "") {
                            showToast(allTranslations
                                .text("please_enter_phone_prefix"));
                          } else {
                            Map cardDetail = {
                              "market": widget.cinetpayMarketFirstValue,
                              "operator":
                                  widget.cinetpayOperatorPhoneFirstValue,
                              "phone_number": phone_number.text,
                              "phone_prefix": phone_prefix.text,
                              "description": description.text,
                            };
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WalletSelectionData(
                                        walletData: widget.walletData,
                                        cardDetail: cardDetail,
                                      )),
                            );
                          }
                        }),
                  )
                ],
              ),
            ),
          );
  }

  MarketIdSet(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        walletRow(
            keyName: allTranslations.text("market"),
            icon: Icon(marketId ? Icons.arrow_drop_up : Icons.arrow_drop_down),
            onTap: () {
              setState(() {
                if (marketId) {
                  marketId = false;
                } else {
                  marketId = true;
                }
              });
            }),
        marketId
            ? Padding(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 0.0),
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    items: widget.cinetpayMarketMap.map((Map map) {
                      return new DropdownMenuItem<String>(
                        value: map["name"].toString(),
                        child: new Text(
                          map["name"],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        if (value != null)
                          widget.cinetpayMarketFirstValue = value;
                      });
                    },
                    hint: Text(tag_add_hint),
                    value: widget.cinetpayMarketFirstValue,
                  ),
                ),
              )
            : SizedBox.shrink(),
      ],
    );
  }

  /*  MarketIdSet(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        walletRow(
            keyName: "Market",
            icon: Icon(marketId ? Icons.arrow_drop_up : Icons.arrow_drop_down),
            onTap: () {
              setState(() {
                if (marketId) {
                  marketId = false;
                } else {
                  marketId = true;
                }
              });
            }),
        marketId
            ? Padding(
                padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                child: normalTextfield(
                    hintText: 'Enter Wallet Id',
                    keyboardType: TextInputType.emailAddress,
                    borderColour: Colors.black45),
              )
            : SizedBox.shrink(),
      ],
    );
  }
*/
  OperatorIdIdSet(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        walletRow(
            keyName: allTranslations.text("operator"),
            icon:
                Icon(OperatorId ? Icons.arrow_drop_up : Icons.arrow_drop_down),
            onTap: () {
              setState(() {
                if (OperatorId) {
                  OperatorId = false;
                } else {
                  OperatorId = true;
                }
              });
            }),
        OperatorId
            ? Padding(
                padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    items: widget.cinetpayOperatorPhoneMap.map((Map map) {
                      return new DropdownMenuItem<String>(
                        value: map["name"].toString(),
                        child: new Text(
                          map["name"],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        if (value != null)
                          widget.cinetpayOperatorPhoneFirstValue = value;
                      });
                    },
                    hint: Text(tag_add_hint),
                    value: widget.cinetpayOperatorPhoneFirstValue,
                  ),
                ),
              )
            : SizedBox.shrink(),
      ],
    );
  }

  PhoneSet(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        walletRow(
            keyName: allTranslations.text("phone") + "*",
            icon: Icon(PhoneId ? Icons.arrow_drop_up : Icons.arrow_drop_down),
            onTap: () {
              setState(() {
                if (PhoneId) {
                  PhoneId = false;
                } else {
                  PhoneId = true;
                }
              });
            }),
        PhoneId
            ? Padding(
                padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                child: normalTextfield(
                    controller: phone_number,
                    hintText: allTranslations.text('EnterNumber'),
                    keyboardType: TextInputType.phone,
                    borderColour: Colors.black45),
              )
            : SizedBox.shrink(),
      ],
    );
  }

  Phone_prefixeSet(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        walletRow(
            keyName: allTranslations.text("phone_prefix") + "*",
            icon: Icon(
                PhonePrefixe ? Icons.arrow_drop_up : Icons.arrow_drop_down),
            onTap: () {
              setState(() {
                if (PhonePrefixe) {
                  PhonePrefixe = false;
                } else {
                  PhonePrefixe = true;
                }
              });
            }),
        PhonePrefixe
            ? Padding(
                padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                child: normalTextfield(
                    controller: phone_prefix,
                    hintText: allTranslations.text('EnterPhonePrefixe'),
                    keyboardType: TextInputType.phone,
                    borderColour: Colors.black45),
              )
            : SizedBox.shrink(),
      ],
    );
  }

  DescriptionSet(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        walletRow(
            keyName: allTranslations.text("description"),
            icon:
                Icon(Description ? Icons.arrow_drop_up : Icons.arrow_drop_down),
            onTap: () {
              setState(() {
                if (Description) {
                  Description = false;
                } else {
                  Description = true;
                }
              });
            }),
        Description
            ? Padding(
                padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                child: normalTextfield(
                    controller: description,
                    hintText: allTranslations.text('AddDescription'),
                    keyboardType: TextInputType.emailAddress,
                    borderColour: Colors.black45),
              )
            : SizedBox.shrink(),
      ],
    );
  }

/*
  CurrencySet(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        walletRow(
            keyName: "Currency",
            icon: Icon(Currency ? Icons.arrow_drop_up : Icons.arrow_drop_down),
            onTap: () {
              setState(() {
                if (Currency) {
                  Currency = false;
                } else {
                  Currency = true;
                }
              });
            }),
        Currency
            ? Padding(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 0.0),
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    items: widget.cinetpayCurrencyMap.map((Map map) {
                      return new DropdownMenuItem<String>(
                        value: map["name"].toString(),
                        child: new Text(
                          map["name"],
                        ),
                      );
                    }).toList(),
                    onChanged: (String value) {
                      setState(() {
                        widget.cinetpayCurrencyFirstValue = value;
                      });
                    },
                    hint: Text(tag_add_hint),
                    value: widget.cinetpayCurrencyFirstValue,
                  ),
                ),
              )
            : SizedBox.shrink(),
      ],
    );
  }
*/

  Future<void> savePhonePayment() async {
    loader = true;
    if (mounted) setState(() {});
    Map cardDetail = {
      "market": widget.cinetpayMarketFirstValue,
      "operator": widget.cinetpayOperatorPhoneFirstValue,
      "phone_number": phone_number.text,
      "phone_prefix": phone_prefix.text,
      "description": description.text,
    };
    await paymentModeLoad(
        context, widget.walletData, cardDetail, "", "phoneCreate");
    loader = false;
    if (mounted) setState(() {});
  }
}
