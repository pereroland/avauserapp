import 'package:avauserapp/components/LabeledCheckbox.dart';
import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/dataLoad/myWallettModeLoad.dart';
import 'package:avauserapp/components/dialog/otpChange.dart';
import 'package:avauserapp/components/dialog/otpCheck.dart';
import 'package:avauserapp/components/dialog/walletTrasfer.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/linkGenrate.dart';
import 'package:avauserapp/components/models/PaymentModel.dart';
import 'package:avauserapp/components/navigation/navigationBankData.dart';
import 'package:avauserapp/components/navigation/navigationPayment.dart';
import 'package:avauserapp/components/otpCheck.dart';
import 'package:avauserapp/components/widget/appbar.dart';
import 'package:avauserapp/components/widget/button.dart';
import 'package:avauserapp/components/widget/rowListTile.dart';
import 'package:avauserapp/components/widget/text.dart';
import 'package:avauserapp/components/widget/textfield.dart';
import 'package:avauserapp/screens/home/baseTabClass.dart';
import 'package:avauserapp/walletData/buttonAnimation/speed_dial.dart';
import 'package:avauserapp/walletData/buttonAnimation/speed_dial_child.dart';
import 'package:avauserapp/walletData/qr_code/qr_code_home.dart';
import 'package:flutter/material.dart';

import 'pinCheck.dart';

class DetailPageData extends StatefulWidget {
  final String? _walletId;

  DetailPageData({walletId})
      : _walletId = walletId,
        super();

  @override
  _DetailPageDataState createState() => _DetailPageDataState();
}

class _DetailPageDataState extends State<DetailPageData> {
  var walletBalance = "0.00";
  var Amount = true;
  bool refresh = false;
  var Currency = false;
  String tag_add_hint = "";
  var wallet_ID = "";
  var auth_pin_code = "";
  var loadding = true;
  List<PaymentModel> _list = [];
  List<bool> inputs = [];
  var DataSelected = "";
  TextEditingController amountController = TextEditingController();
  var isDataAvailable = true;
  var currencyData = "";
  var descriptionData = "";
  var marketData = "";
  var operatorData = "";
  var phone_numberData = "";
  String? selectedId;
  var phone_prefixData = "";
  var authPinCodeData = "";
  var wallet_balance = "0.00";
  var currency = "";
  static const topPortionHeight = 250.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initDataCall();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var topspaceInnerBoxheight = MediaQuery.of(context).size.height / 15;
    var leftRightspaceInnerBoxheight = MediaQuery.of(context).size.height / 56;
    var boxspaceInnerBoxheight = MediaQuery.of(context).size.height / 4;
    return WillPopScope(
        onWillPop: () {
          backNavigation(context);
          return Future.value(false);
        },
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            bottomNavigationBar:
                loadding ? SizedBox.shrink() : bottonButton(context),
            appBar: appBarWidget(
              text: 'Wallet',
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
              ],
            ),
            body: loadding
                ? Container(
                    height: size.height,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Image.asset(
                            'assets/PaymentCards/payment_image.webp'),
                      ),
                    ),
                  )
                : Container(
                    color: AppColours.appTheme,
                    child: Center(
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              color: AppColours.appTheme,
                              width: MediaQuery.of(context).size.width,
                              height: topPortionHeight,
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
                                                  color:
                                                      AppColours.whiteColour),
                                            ),
                                            SizedBox(
                                              height: 20.0,
                                            ),
                                            Text(
                                              currency +
                                                  wallet_balance.toString(),
                                              style: TextStyle(
                                                  color: AppColours.whiteColour,
                                                  fontSize: 22.0),
                                            ),
                                            SizedBox(
                                              height: 20.0,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.account_balance_wallet,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(
                                                  width: 20.0,
                                                ),
                                                SelectableText(
                                                  wallet_ID.toString(),
                                                  style: TextStyle(
                                                      color: AppColours
                                                          .whiteColour,
                                                      fontSize: 18.0),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10.0,
                                            ),
                                            /*SizedBox(
                                          height: 50.0,
                                          child: fullColouredBtn(
                                              text: allTranslations
                                                  .text('topupwallet')
                                                  .toUpperCase(),
                                              radiusButtton: 35.0,
                                              onPressed: () async {}),
                                        )*/
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
                          SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.only(top: topPortionHeight),
                              child: Container(
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
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      headerText(
                                          text: allTranslations.text("top_up"),
                                          size: 22.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                      amountSelection(size),
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child: headerText(
                                                text: allTranslations
                                                    .text('debitFrom'),
                                                size: 22.0,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Align(
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: AppColours.appTheme,
                                                ),
                                                onPressed: () {
                                                  paymentAddingNew(
                                                      context, true);
                                                },
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Container(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: _list.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return listItems(
                                              _list,
                                              index,
                                              context,
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          paymentAddingNew(context, false);
                                        },
                                        child: headerText(
                                            text:
                                                "+ ${allTranslations.text("addNewPayment")}",
                                            size: 22.0,
                                            color: AppColours.appTheme,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 30.0,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          paymentUrl();
                                        },
                                        child: headerText(
                                            text:
                                                allTranslations.text("orDebit"),
                                            size: 22.0,
                                            color: AppColours.appTheme,
                                            fontWeight: FontWeight.bold),
                                      ),
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
            floatingActionButton: SpeedDial(
              // both default to 16
              marginRight: 18,
              marginBottom: 20,
              onClose: () {},
              onOpen: () {},
              animatedIcon: AnimatedIcons.menu_close,
              animatedIconTheme: IconThemeData(size: 22.0),
              // this is ignored if animatedIcon is non null
              // child: Icon(Icons.add),
              visible: isDataAvailable,
              curve: Curves.bounceIn,
              overlayColor: Colors.black,
              overlayOpacity: 0.5,
              tooltip: 'Speed Dial',
              heroTag: 'dialOpen',
              backgroundColor: AppColours.appTheme,
              foregroundColor: Colors.white,
              elevation: 8.0,
              shape: CircleBorder(),
              child: Container(),
              children: [
                SpeedDialChild(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Image.asset('assets/linkShare.png'),
                  ),
                  backgroundColor: Colors.white,
                  labelStyle:
                      TextStyle(fontSize: 15.0, color: AppColours.appTheme),
                  onTap: () {
                    linkGeneratePaymentShare();
                  },
                ),
                SpeedDialChild(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(
                      Icons.edit,
                      color: AppColours.appTheme,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  labelStyle:
                      TextStyle(fontSize: 15.0, color: AppColours.appTheme),
                  onTap: () {
                    pinChangeDialog(context, auth_pin_code);
                  },
                ),
                SpeedDialChild(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: AppColours.appTheme,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  labelStyle:
                      TextStyle(fontSize: 15.0, color: AppColours.appTheme),
                  onTap: () async {
                    var reply = await walletOtpPayment(context);
                    if (reply == "Success") {
                      topUpWalletData(null);
                    }
                  },
                ),
                SpeedDialChild(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(
                      Icons.qr_code,
                      color: AppColours.appTheme,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  labelStyle:
                      TextStyle(fontSize: 15.0, color: AppColours.appTheme),
                  onTap: () async {
                    final walletId = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => QRCodeHomeScreen(
                          walletId: wallet_ID,
                          qrCodeImageLink:
                              "https://chart.googleapis.com/chart?chs=300x300&cht=qr&chl=$wallet_ID&choe=UTF-8",
                        ),
                      ),
                    );
                    if (walletId != null) {
                      var reply = await walletOtpPayment(context);
                      if (reply == "Success") topUpWalletData(walletId);
                    }
                  },
                )
              ],
            ),
          ),
        ));
  }

  spaceHeight() {
    return SizedBox(height: 20.0);
  }

  Future<void> paymentCheck() async {
    Map detail = await myWalletModeLoad(context) ?? {};
    if (detail['status'] == "200") {
      List list = detail['record'];
      setState(() {
        _list = list
            .map<PaymentModel>((json) => PaymentModel.fromJson(json))
            .toList();
        for (int i = 0; i < _list.length; i++) {
          if (i == 0) {
            dataSet(_list, 0);
          }
          inputs.add(false);
        }
        loadding = false;

        ItemChange(true, 0, _list, 0, context);
      });
    }
  }

  amountSelection(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        walletRow(
            keyName: allTranslations.text("Amount"),
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
                child: normalNumberTextfield(
                    hintText: allTranslations.text('EnterAmount'),
                    controller: amountController,
                    // textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.numberWithOptions(
                        decimal: true, signed: true),
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
              topUpPaymentCheck(context);
              //    List<Map> cinetpayCurrencyMap;
              //   String cinetpayCurrencyFirstValue;
            }),
      ),
    );
  }

  Future<Map> walletDetailDialog(context, String walletId, String pinCode) {
    TextEditingController walletIdController = TextEditingController();
    TextEditingController pinCodeController = TextEditingController();
    showDialog(
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
                          allTranslations.text('Wallet'),
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: headerText(
                            text: allTranslations.text("WalletId"),
                            size: 16.0,
                            color: AppColours.blacklightLineColour,
                            fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                        child: normalTextfield(
                            readOnly: true,
                            hintText: walletId,
                            controller: walletIdController,
                            keyboardType: TextInputType.name,
                            borderColour: Colors.black45),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: headerText(
                            text: allTranslations.text("PinCode"),
                            size: 16.0,
                            color: AppColours.blacklightLineColour,
                            fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                        child: normalTextfield(
                            readOnly: true,
                            hintText: pinCode,
                            controller: pinCodeController,
                            keyboardType: TextInputType.number,
                            borderColour: Colors.black45),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                    ],
                  ),
                );
              }));
        });
    return Future.value({});
  }

  Widget listItems(List<PaymentModel> list, int index, BuildContext context) {
    return Container(
      padding: new EdgeInsets.only(top: 0.0),
      child: new Container(
          padding: new EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: new LabeledCheckbox(
                    value: inputs[index],
                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
                    onChanged: (bool val) {
                      ItemChange(val, index, _list, index, context);
                    }),
              ),
              Expanded(
                flex: 8,
                child: Text(list[index].phoneNumber.toString()),
              )
            ],
          )),
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
            colors: [
              AppColours.whiteColour,
              AppColours.whiteColour,
              /*AppColours.appgradientfirstColour,
                    AppColours.appgradientsecondColour*/
            ],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.5, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp),
        borderRadius: BorderRadius.circular(12.0),
      ),
    );
  }

  void ItemChange(bool val, int index, List<PaymentModel> list, int index2,
      BuildContext context) {
    for (int i = 0; i < _list.length; i++) {
      setState(() {
        if (i == index) {
          inputs[i] = true;
          dataSet(list, index);
        } else {
          inputs[i] = false;
        }
      });
    }
  }

  void topUpPaymentCheck(context) {
    if (amountController.text.toString().trim().toString() == "") {
      showToast(allTranslations.text("PleaseEnterAmount"));
    } else if (marketData == "") {
      showToast(allTranslations.text("please_select_any_number"));
    } else {
      Map cardDetail = {
        "market": marketData,
        "operator": operatorData,
        "phone_number": phone_numberData,
        "phone_prefix": phone_prefixData,
        "description": descriptionData,
        "currency": currencyData
      };
      var amountDetail = {
        "amount": amountController.text,
      };
      var walletData = {
        "auth_pin_code": authPinCodeData,
        "id": 'Already setup'
      };
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PinCheck(
                  cardDetail: cardDetail,
                  amountDetail: amountDetail,
                  walletData: walletData,
                  topup: "direct",
                )),
      );
    }
  }

  void dataSet(List<PaymentModel> list, int index) {
    if (mounted)
      setState(() {
        marketData = list[index].market;
        operatorData = list[index].operator;
        selectedId = list[index].id;
        phone_numberData = list[index].phoneNumber;
        phone_prefixData = list[index].phonePrefix;
        descriptionData = list[index].description ?? "";
        currencyData = list[index].currency;
        authPinCodeData = list[index].authPinCode;
      });
  }

  void paymentAddingNew(context, bool edit) {
    var walletData = {};
    if (edit) {
      walletData = {
        "wallet_id": wallet_ID,
        "auth_pin_code": authPinCodeData,
        "id": selectedId,
        "phone_number": phone_numberData,
        "currency_name": currencyData,
        "description": descriptionData,
        "prefix": phone_prefixData,
        "market": marketData,
        "operator": operatorData
      };
    } else {
      walletData = {
        "wallet_id": wallet_ID,
        "currency_name": currencyData,
        "auth_pin_code": authPinCodeData,
        "id": '',
      };
    }
    getArrayList(context: context, walletData: walletData);
  }

  Future<void> getDetailPrevious() async {
    Map detail = await myWalletModeLoad(context) ?? {};
    if (detail['status'] == "200") {
      List list = detail['record'];
      var data = list[0];
      var balance = data['wallet_balance'].toString();
      if (mounted)
        setState(() {
          if (balance == 'null' || balance == '') {
            wallet_balance = "0.00";
          } else {
            currency = data['currency'].toString();
            wallet_balance = balance;
            wallet_ID = data['wallet_ID'].toString();
            auth_pin_code = data['auth_pin_code'].toString();
          }
        });
    }
  }

  void backNavigation(context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TabBarController(0)),
    );
  }

  void paymentUrl() {
    NavigateScreen(
        context: context,
        amount: '',
        phone_number: '',
        phone_prefix: '',
        paymentFor: "3",
        walletCheck: "1");
  }

  void initDataCall() async {
    await getDetailPrevious();
    await paymentCheck();
    initiateWalletPayment();
  }

  void initiateWalletPayment() async {
    if (widget._walletId == null) return;
    var reply = await walletOtpPayment(context);
    if (reply == "Success") {
      topUpWalletData(null);
    }
  }

  checkWallet(BuildContext context, String types) async {
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => otpDialog(pin: auth_pin_code)));
    if (result.toString() == "null") {
    } else {
      if (types == "sendPayment") {
        walletDetailDialog(context, wallet_ID, auth_pin_code);
      }
    }
  }

  Future<void> topUpWalletData(String? id) async {
    TextEditingController walletIdController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    if (id != null) {
      walletIdController.text = id;
    }
    var statusPayment = await WalletTransferDialog(
        context,
        wallet_balance.toString(),
        currency,
        "6",
        walletIdController,
        amountController);
    if (statusPayment != null) {
      if (statusPayment['status'] == "200") {
        if (mounted)
          setState(() {
            initDataCall();
          });
      }
    }
  }
}
