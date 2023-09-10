import 'dart:async';
import 'dart:convert';

import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/models/transactionModel.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/screens/home/baseTabClass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/language/languageSelected.dart';

class TransactionOrderListCheck extends StatefulWidget {
  @override
  _OrderList createState() => _OrderList();
}

class _OrderList extends State<TransactionOrderListCheck> {
  var dataLoad = false;
  var Detail = "";
  var Online = "";
  var StorePickup = "";
  var PaymentInfo = "";
  var PriceDetails = "";
  var ListPrice = "";
  var SellingPrice = "";
  var Total = "";
  Map? myLang;
  int? selectedRadio;
  List<transactionModel> _list = [];
  var dataFound = false;
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  var selected = 1;
  var time_interval = '';
  var month_value = '';
  var custom_date = '';

  @override
  void initState() {
    super.initState();
    selectedRadio = 1;
    myLangGet();
  }

  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          setBackData();
          return Future.value(false);
        },
        child: Container(
          color: Colors.grey[100],
          child: Scaffold(
              appBar: AppBar(
                title: Text(
                  allTranslations.text("TransactionHistory"),
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Montaga',
                      fontWeight: FontWeight.bold),
                ),
                leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      setBackData();
                    }),
                iconTheme: IconThemeData(color: Colors.black),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () {
                      monthSelectedData();
                    },
                  )
                ],
                backgroundColor: Colors.white,
              ),
              body: Column(
                children: [
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                      height: 50.0,
                      child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(2.0),
                              child: MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(
                                        color: selected == 1
                                            ? AppColours.appTheme
                                            : AppColours.blacklightColour)),
                                onPressed: () {
                                  setState(() {
                                    selected = 1;
                                    callUSerStatusCheck(1);
                                  });
                                },
                                color: AppColours.whiteColour,
                                textColor: AppColours.appTheme,
                                child: Text(allTranslations.text('all')),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(2.0),
                              child: MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(
                                        color: selected == 2
                                            ? AppColours.appTheme
                                            : AppColours.blacklightColour)),
                                onPressed: () {
                                  setState(() {
                                    selected = 2;
                                    callUSerStatusCheck(1);
                                  });
                                },
                                color: Colors.white,
                                textColor: AppColours.appTheme,
                                child:
                                    Text(allTranslations.text('AddedAmount')),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(2.0),
                              child: MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(
                                        color: selected == 3
                                            ? AppColours.appTheme
                                            : AppColours.blacklightColour)),
                                onPressed: () {
                                  setState(() {
                                    selected = 3;
                                    callUSerStatusCheck(1);
                                  });
                                },
                                color: Colors.white,
                                textColor: AppColours.appTheme,
                                child: Text(
                                    allTranslations.text('TransferedAmount')),
                              ),
                            ),
                          ])),
                  dataLoad
                      ? dataFound
                          ? Expanded(
                              child: RefreshIndicator(
                                key: refreshKey,
                                child: dataShow(),
                                onRefresh: validationCheck,
                              ),
                            )
                          : Expanded(
                              child: RefreshIndicator(
                                key: refreshKey,
                                child: SingleChildScrollView(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    child: Image.asset(
                                        "assets/emptytransaction.webp")),
                                onRefresh: validationCheck,
                              ),
                            )
                      : Expanded(
                          child: Container(
                            color: Colors.white,
                            child: Center(
                              child: Image.asset("assets/storeloadding.gif"),
                            ),
                          ),
                        ),
                ],
              )),
        ));
  }

  Future<void> myLangGet() async {
    Map myLangData = await langTxt(context);
    setState(() {
      myLang = myLangData;
      if (myLang != null) {
        Detail = myLang!['Detail'];
        Online = myLang!['Online'];
        StorePickup = myLang!['StorePickup'];
        PaymentInfo = myLang!['PaymentInfo'];
        PriceDetails = myLang!['PriceDetails'];
        ListPrice = myLang!['ListPrice'];
        SellingPrice = myLang!['SellingPrice'];
        Total = myLang!['Total'];
      }
    });
    var check = myLangData['email'];
    validationCheck();
  }

  Future<void> validationCheck() async {
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck == true) {
      callUSerStatusCheck(1);
    }
  }

  addMoreOrder(var data) {
    List<transactionModel> newData = data
        .map<transactionModel>((json) => transactionModel.fromJson(json))
        .toList();
    for (int i = 0; i < data.length; i++) {
      _list.add(newData[i]);
    }
  }

  void callUSerStatusCheck(int page) async {
    if (mounted)
      setState(() {
        if (page == 1) dataLoad = false;
      });
    var items = "";
    if (selected == 3) {
      items = "3";
    } else {
      items = selected.toString();
    }
    Map map = {
      "page_no": "$page",
      "status": items,
      "time_interval": time_interval,
      "custom_date": custom_date,
      "month_value": month_value
    };
    Map decoded = jsonDecode(await apiRequest(paymentHistoryUrl, map, context));
    String status = decoded['status'];
    String message = decoded['message'];
    if (status == success_status) {
      var data = decoded['record']['data'];
      if (mounted)
        setState(() {
          if (page == 1) dataLoad = false;
          if (page == 1) _list.clear();
          page == 1
              ? _list = data
                  .map<transactionModel>(
                      (json) => transactionModel.fromJson(json))
                  .toList()
              : addMoreOrder(data);
          if (_list.length > 0) {
            dataFound = true;
          } else {
            dataFound = false;
          }
          callUSerStatusCheck(page + 1);
        });
    } else if (status == unauthorized_status) {
      await checkLoginStatus(context);
    } else if (status == already_login_status) {
    } else if (status == data_not_found_status) {
      setState(() {
        if (page == 1) dataFound = false;
      });
    } else if (status == "408") {
      jsonDecode(await apiRefreshRequest(context));
      callUSerStatusCheck(1);
    } else {
      _showToast(message);
    }
    setState(() {
      dataLoad = true;
    });
  }

  spaceHeight() {
    return SizedBox(height: 10.0);
  }

  listItems(List<transactionModel> _list, index, selected, context) {
    return itemCheck(_list, index, selected, context);
  }

  void _showToast(String mesage) {
    Fluttertoast.showToast(
        msg: mesage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void setBackData() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TabBarController(0)),
    );
  }

  Future<void> setBackToOrderQues(
      List<transactionModel> list, index, type) async {
    var result;
    if (result == null) {
    } else {
      validationCheck();
    }
  }

  setActionOrder(list, index) {
    var statusEnable = false;
    if (list[index].status == "1" ||
        list[index].status == "2" ||
        list[index].status == "3") {
      statusEnable = true;
    } else {
      statusEnable = false;
    }
    return statusEnable
        ? Column(
            children: [
              /* Divider(
                color: AppColours.blacklightLineColour,
              ),*/
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: AppColours.appTheme)),
                  onPressed: () {
                    var countryCode = list[index]
                        .merchant_country_code
                        .toString()
                        .replaceAll("+", "");
                    var phoneNumber = list[index]
                        .merchant_phone
                        .toString()
                        .replaceAll("+", "");
                    var callNumber = "+" + countryCode + phoneNumber;
                    if (callNumber.toString().contains("+")) {
                    } else {
                      callNumber = "+" + callNumber;
                    }
                    if (callNumber.toString().contains("+")) {
                      callNumber = callNumber.toString().replaceAll("+", "");
                    }
                    callNumber = "+" + callNumber;
                    launch("tel:" + Uri.encodeComponent('$callNumber'));
                  },
                  color: AppColours.appTheme,
                  textColor: Colors.white,
                  child: callText(),
                ),
              ),
            ],
          )
        : SizedBox.shrink();
  }

  callText() {
    return Align(
      child: Text(
        allTranslations.text('call').toUpperCase(),
        style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
        textAlign: TextAlign.center,
      ),
      alignment: Alignment.center,
    );
  }

  paymentdataShow(payment_type) {
    var colour = Colors.green;
    var colourBorder = Colors.red[100];
    String text;
    if (payment_type == "Debit") {
      colour = Colors.red;
      colourBorder = Colors.red[100];
      text = 'new order';
    } else {
      colour = Colors.green;
      colourBorder = Colors.green[100];
      text = 'cancel by admin';
    }
    return Container(
        height: 30.0,
        width: 80,
        decoration: BoxDecoration(
            color: colourBorder,
            border: Border.all(
              color: colourBorder!,
            ),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Row(
          children: [
            SizedBox(
              width: 10.0,
            ),
            Icon(
              Icons.brightness_1,
              color: colour,
              size: 10,
            ),
            SizedBox(
              width: 5.0,
            ),
            Text(
              payment_type,
              style: TextStyle(color: colour),
            )
          ],
        ));
  }

  dataShow() {
    /* var colour = Colors.green;
    var text = "";
    if (list[index].status == "1") {
      colour = Colors.red;
      text = 'new order';
    } else if (list[index].status == "2") {
      colour = Colors.green;
      text = 'dispatch ready';
    } else if (list[index].status == "3") {
      colour = Colors.green;
      text = 'on the way';
    } else if (list[index].status == "4") {
      colour = Colors.green;
      text = 'delivered';
    } else if (list[index].status == "5") {
      colour = Colors.red;
      text = 'cancel by user';
    } else if (list[index].status == "6") {
      colour = Colors.red;
      text = 'cancel by admin';
    } else {
      colour = Colors.green;
      text = 'cancel by admin';
    }*/
    return ListView.builder(
        itemCount: _list.length,
        itemBuilder: (BuildContext context, int index) {
          return listItems(_list, index, selected, context);
        });
  }

  blankDataField() {
    return SizedBox.shrink();
  }

  itemCheck(List<transactionModel> list, index, selected, context) {
    return itemsSetStatus(list, index, context);

    /* if (selected.toString() == "3") {
      return itemsSetStatus(list, index, context);
    }
    if (list[index].status == selected.toString()) {
      return itemsSetStatus(list, index, context);
    }
    if (list[index].status == selected.toString()) {
      return itemsSetStatus(list, index, context);
    }
    if (list[index].status == selected.toString()) {
      return itemsSetStatus(list, index, context);
    }
    if (list[index].status == selected.toString()) {
      return itemsSetStatus(list, index, context);
    }
    if (list[index].status == selected.toString()) {
      return itemsSetStatus(list, index, context);
    }
    if (list[index].status == selected.toString()) {
      return itemsSetStatus(list, index, context);
    } else {
      return blankDataField();
    }*/
  }

  itemsSetStatus(List<transactionModel> list, index, context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
      child: Container(
        child: InkWell(
          onTap: () {
            setBackToOrderQues(_list, index, "OrderPaymentDetail");
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          cardShow(""),
                          SizedBox(
                            height: 10.0,
                          ),
                          textbold(_list[index].market.toString()),
                          SizedBox(
                            height: 10.0,
                          ),
                          textbold(_list[index].paymentMethod.toString()),
                          SizedBox(
                            height: 10.0,
                          ),
                          textbold(_list[index].operator.toString()),
                          SizedBox(
                            height: 10.0,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(_list[index].currencySign.toString()),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            _list[index].totalAmount.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20.0),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          paymentdataShow(_list[index].paymentType.toString()),
                          SizedBox(
                            height: 10.0,
                          ),
                        ],
                      ),
                      flex: 6,
                    )
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  "${allTranslations.text("descriptionTxt")} : " +
                      _list[index].description.toString(),
                  style: TextStyle(color: AppColours.blacklightLineColour),
                ),
                SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          ),
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColours.blacklightColour),
          borderRadius: BorderRadius.all(
              Radius.circular(5.0) //                 <--- border radius here
              ),
        ),
      ),
    );
  }

  textbold(text) {
    return Text(
      text,
      maxLines: 2,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
    );
  }

  cardShow(String cardType) {
    var cardTypeData = "assets/PaymentCards/payment_image.webp";
    /*if (cardType == 'visa') {
      cardTypeData = "assets/PaymentCards/Visa.webp";
    } else if (cardType == 'chip') {
    } else if (cardType == 'mastercard') {
    } else {
      cardTypeData = "assets/PaymentCards/Visa.webp";
    }*/
    return Image.asset(
      cardTypeData,
      width: 100.0,
      height: 40.0,
    );
  }

  void monthSelectedData() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
            title: new Text(allTranslations.text('filterMonth')),
            content: SizedBox(
              height: 250,
              child: Column(
                children: [
                  MaterialButton(
                    child: Text(allTranslations.text('AllDetail')),
                    color: AppColours.appTheme,
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                      time_interval = "";
                      month_value = "";
                      custom_date = "";
                      callUSerStatusCheck(1);
                    },
                  ),
                  MaterialButton(
                    child: Text(allTranslations.text('Today')),
                    color: AppColours.appTheme,
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                      time_interval = "1";
                      month_value = "";
                      custom_date = "";
                      callUSerStatusCheck(1);
                    },
                  ),
                  MaterialButton(
                    child: Text(allTranslations.text('Yesterday')),
                    color: AppColours.appTheme,
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                      time_interval = "2";
                      month_value = "";
                      custom_date = "";
                      callUSerStatusCheck(1);
                    },
                  ),
                  MaterialButton(
                    child: Text(allTranslations.text('PickDay')),
                    color: AppColours.appTheme,
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                      time_interval = "3";
                      month_value = "";
                      custom_date = "";
                      selectStartDate(context);
                    },
                  ),
                ],
              ),
            ));
      },
    );
  }

  Future<Null> selectStartDate(BuildContext context) async {
    DateTime selectedSourceDate = DateTime.now();

    var now = new DateTime.now();
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedSourceDate,
        firstDate: DateTime(2020, now.month, now.day),
        lastDate: DateTime(5000));
    if (picked != null && picked != selectedSourceDate)
      selectedSourceDate = picked;
    var month = selectedSourceDate.month.toString();
    var day = selectedSourceDate.day.toString();
    if (selectedSourceDate.month < 10) {
      month = "0" + month;
    }
    if (selectedSourceDate.day < 10) {
      day = "0" + day;
    }
    var startDate =
        selectedSourceDate.year.toString() + "-" + month + "-" + day;
    custom_date = startDate;
    callUSerStatusCheck(1);
  }
}
