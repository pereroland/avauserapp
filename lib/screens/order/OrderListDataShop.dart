import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/models/OrderListModel.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/shimmerEffects/sizeImageShimmer.dart';
import 'package:avauserapp/screens/home/baseTabClass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/language/languageSelected.dart';
import 'OrderDetailPayment.dart';

class OrderListCheck extends StatefulWidget {
  @override
  _OrderList createState() => _OrderList();
}

class _OrderList extends State<OrderListCheck> {
  Icon actionIcon = new Icon(Icons.search, color: AppColours.appTheme);
  Widget appBarTitle = Text(
    "All Orders",
    style: TextStyle(color: Colors.black),
  );
  final TextEditingController _searchQuery = new TextEditingController();
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
  List<OrderListModel> _list = [];
  var dataFound = false;
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  var selected = 0;
  var monthSelected = "0";
  var showSearch = true;
  var _SearchPick = true;
  var _searchText = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedRadio = 1;
    myLangGet();
  }

  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  _OrderList() {
    _searchQuery.addListener(() {
      if (_searchQuery.text.isEmpty) {
        setState(() {
          _searchText = "";
        });
        callUSerStatusCheck(1);
      } else {
        setState(() {
          _searchText = _searchQuery.text;
        });
        callUSerStatusCheck(1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () async {
          setBackData();
          return Future.value(false);
        },
        child: Container(
          color: Colors.grey[100],
          child: Scaffold(
//      bottomNavigationBar: addtToCartButton(),
              appBar: buildBar(context),
              body: Column(
                children: [
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                      height: 40.0,
                      margin: EdgeInsets.only(top: 5),
                      width: MediaQuery.of(context).size.width,
                      child: Row(children: <Widget>[
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          flex: 3,
                          child: MaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(
                                    color: selected == 0
                                        ? AppColours.appTheme
                                        : AppColours.blacklightColour)),
                            onPressed: () {
                              setState(() {
                                selected = 0;
                                _list.clear();
                                callUSerStatusCheck(1);
                              });
                            },
                            color: AppColours.whiteColour,
                            textColor: AppColours.appTheme,
                            child: Text(allTranslations.text('all')),
                            padding: EdgeInsets.all(5.0),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          flex: 3,
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
                                _list.clear();
                                callUSerStatusCheck(1);
                              });
                            },
                            color: Colors.white,
                            textColor: Colors.red,
                            child: Text(
                              allTranslations.text(
                                  'pending'), //allTranslations.text('NewOrder')
                            ),
                            padding: EdgeInsets.all(5.0),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          flex: 3,
                          child: MaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(
                                    color: selected == 4
                                        ? AppColours.appTheme
                                        : AppColours.blacklightColour)),
                            onPressed: () {
                              setState(() {
                                selected = 4;
                                _list.clear();
                                callUSerStatusCheck(1);
                              });
                            },
                            color: Colors.white,
                            textColor: Colors.green,
                            child: Text(
                              allTranslations.text(
                                'delivered',
                              ), //allTranslations.text('Dispatchready'),
                            ),
                            padding: EdgeInsets.all(5.0),
                          ),
                        ),
                        Spacer(),
                        // Padding(
                        //   padding: EdgeInsets.all(2.0),
                        //   child: MaterialButton(
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(18.0),
                        //       side: BorderSide(
                        //         color: selected == 3
                        //             ? AppColours.appTheme
                        //             : AppColours.blacklightColour,
                        //       ),
                        //     ),
                        //     onPressed: () {
                        //       setState(() {
                        //         selected = 3;
                        //         callUSerStatusCheck();
                        //       });
                        //     },
                        //     color: Colors.white,
                        //     textColor: Colors.red,
                        //     child: Text(allTranslations.text(
                        //             "cancelled") //allTranslations.text("on_the_way"),
                        //         ),
                        //   ),
                        // ),
                      ])),
                  dataLoad
                      ? dataFound
                          ? RefreshIndicator(
                              key: refreshKey,
                              child: dataShow(),
                              onRefresh: validationCheck,
                            )
                          : RefreshIndicator(
                              key: refreshKey,
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height - 175.0,
                                child: SingleChildScrollView(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  child: Container(
                                    height: MediaQuery.of(context).size.height,
                                    child: Center(
                                        child: Image.asset(
                                            "assets/noproductfound.webp")),
                                  ),
                                ),
                              ),
                              onRefresh: validationCheck,
                            )
                      : Expanded(
                          child: Center(
                            child: Image.asset("assets/storeloadding.gif"),
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
      Detail = myLang!['Detail'];
      Online = myLang!['Online'];
      StorePickup = myLang!['StorePickup'];
      PaymentInfo = myLang!['PaymentInfo'];
      PriceDetails = myLang!['PriceDetails'];
      ListPrice = myLang!['ListPrice'];
      SellingPrice = myLang!['SellingPrice'];
      Total = myLang!['Total'];
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

  void callUSerStatusCheck(int page) async {
    setState(() {
      if (page == 1) dataLoad = false;
    });
    var items = "";
    items = selected.toString();
    Map map = {
      "page_no": "$page",
      "search": _searchText,
      "status": items,
      "time_interval": monthSelected,
      "filter_month": ""
    };

    Map decoded = jsonDecode(await apiRequest(historyUrl, map, context));

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
                  .map<OrderListModel>((json) => OrderListModel.fromJson(json))
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
      Map decoded = jsonDecode(await apiRefreshRequest(context));
      callUSerStatusCheck(1);
    } else {
      _showToast(message);
    }
    setState(() {
      dataLoad = true;
    });
  }

  addMoreOrder(var data) {
    List<OrderListModel> newData = data
        .map<OrderListModel>((json) => OrderListModel.fromJson(json))
        .toList();
    for (int i = 0; i < data.length; i++) {
      _list.add(newData[i]);
    }
  }

  spaceHeight() {
    return SizedBox(height: 10.0);
  }

  listItems(List<OrderListModel> _list, index, selected, context) {
    return itemCheck(_list, index, selected, context);
  }

  orderStatusSet(List<OrderListModel> list, index) {
    //1=new order,2=dispatch ready,3=on the way,4=delivered,5=cancel by user,6=cancel by admin
    var colour = Colors.green;
    var text = "";
    if (list[index].status == "1") {
      colour = Colors.red;
      text = allTranslations.text('pending');
    } else if (list[index].status == "2") {
      colour = Colors.red;
      text = allTranslations.text('pending');
    } else if (list[index].status == "3" || list[index].status == "2") {
      colour = Colors.red;
      text = allTranslations.text('pending');
    } else if (list[index].status == "4") {
      colour = Colors.green;
      text = allTranslations.text("delivered");
    } else if (list[index].status == "5") {
      colour = Colors.red;
      text = allTranslations.text("cancelled_by_user");
    } else if (list[index].status == "6") {
      colour = Colors.red;
      text = allTranslations.text("cancelled_by_admin");
    } else {
      colour = Colors.green;
      text = allTranslations.text("cancelled_by_admin");
    }
    return Text(
      text.toString(),
      maxLines: 1,
      style:
          TextStyle(fontSize: 16.0, color: colour, fontWeight: FontWeight.bold),
    );
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
      List<OrderListModel> list, index, type) async {
    var result;
    result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => OrderPaymentDetail(id: list[index].id)));

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
              /* Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: InkWell(
                        child: statusEnable
                            ? callText()
                            : Container(
                                child: Container(
                                  height: 30.0,
                                  child: callText(),
                                ),
                              ),
                        onTap: () {

                        }),
                  ), */ /*
            statusEnable
                ? Expanded(
              flex: 1,
              child: Container(
                height: 30.0,
                child: VerticalDivider(
                  color: Colors.black,
                ),
              ),
            )
                : SizedBox.shrink(),
            statusEnable
                ? Expanded(
              flex: 2,
              child: GestureDetector(
                child: Text(
                  allTranslations.text('cancel').toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  // _showToast("this process is under developement...");
                  callOrderChange(list, index);
                },
              ),
            )
                : SizedBox.shrink(),*/ /*
                ],
              ),
              Divider(
                color: AppColours.blacklightLineColour,
              ),*/
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
    return Column(
      children: [
        Container(
            height: MediaQuery.of(context).size.height - 175.0,
            child: ListView.builder(
                itemCount: _list.length,
                itemBuilder: (BuildContext context, int index) {
                  return listItems(_list, index, selected, context);
                }))
      ],
    );
  }

  blankDataField() {
    return SizedBox.shrink();
  }

  itemCheck(List<OrderListModel> list, index, selected, context) {
    if (selected.toString() == "0") {
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
    }
  }

  itemsSetStatus(List<OrderListModel> list, index, context) {
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
                          Text(
                            "#" + _list[index].booking_id.toString(),
                            maxLines: 1,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20.0),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          Text(
                            _list[index].currency_sign.toString() +
                                ' ' +
                                _list[index].discounted_amount.toString(),
                            maxLines: 1,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                                color: AppColours.blacklightLineColour),
                            textAlign: TextAlign.right,
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          orderStatusSet(_list, index),
                        ],
                      ),
                    ),
                    Expanded(
                      child: CachedNetworkImage(
                        imageUrl: _list[index].store_logo,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => sizeImageShimmer(
                            context, MediaQuery.of(context).size.width, 80.0),
                        errorWidget: (context, url, error) => Image.asset(
                          "assets/nodata.webp",
                          fit: BoxFit.fill,
                        ),
                        height: 80.0,
                        width: MediaQuery.of(context).size.width,
                      ),
                      flex: 6,
                    )
                  ],
                ),
                SizedBox(
                  height: 20.0,
                ),
                setActionOrder(_list, index),
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

  void monthSelectedData() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
            title: new Text(allTranslations.text('filterMonth')),
            content: SizedBox(
              height: 150,
              child: Column(
                children: [
                  MaterialButton(
                    child: Text(allTranslations.text('CurrentWeek')),
                    color: AppColours.appTheme,
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                      monthSelected = "1";
                      callUSerStatusCheck(1);
                    },
                  ),
                  MaterialButton(
                    child: Text(allTranslations.text('CurrentMonth')),
                    color: AppColours.appTheme,
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                      monthSelected = "2";
                      callUSerStatusCheck(1);
                    },
                  ),
                  MaterialButton(
                    child: Text(allTranslations.text('LastSixMonth')),
                    color: AppColours.appTheme,
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                      monthSelected = "3";
                      callUSerStatusCheck(1);
                    },
                  ),
                ],
              ),
            ));
      },
    );
  }

  AppBar buildBar(BuildContext context) {
    return new AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: appBarTitle,
        actions: <Widget>[
          new IconButton(
            icon: actionIcon,
            onPressed: () {
              setState(() {
                if (this.actionIcon.icon == Icons.search) {
                  this.actionIcon = new Icon(
                    Icons.close,
                    color: AppColours.appTheme,
                  );
                  this.appBarTitle = new TextField(
                    controller: _searchQuery,
                    style: new TextStyle(
                      color: AppColours.appTheme,
                    ),
                    decoration: new InputDecoration(
                        prefixIcon:
                            new Icon(Icons.search, color: AppColours.appTheme),
                        hintText: allTranslations.text('Search'),
                        hintStyle: new TextStyle(color: Colors.black)),
                  );
                  _handleSearchStart();
                } else {
                  _handleSearchEnd();
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              monthSelectedData();
            },
          )
        ]);
  }

  void _handleSearchStart() {
    setState(() {
      // callUSerStatusCheck();
    });
  }

  void _handleSearchEnd() {
    setState(() {
      this.actionIcon = new Icon(
        Icons.search,
        color: AppColours.appTheme,
      );
      this.appBarTitle = Text(
        "All Orders",
        style: TextStyle(color: Colors.black),
      );
      _searchQuery.clear();
    });
  }
}
