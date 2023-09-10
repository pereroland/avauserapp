import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/shimmerEffects/sizeImageShimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/language/languageSelected.dart';
import '../../components/models/OrderModel.dart';
import 'package:avauserapp/components/longLog.dart';

class OrderList extends StatefulWidget {
  @override
  _OrderList createState() => _OrderList();
}

class _OrderList extends State<OrderList> {
  var dataLoad = false;
  var Detail = "";
  var Online = "";
  var StorePickup = "";
  var PaymentInfo = "";
  var PriceDetails = "";
  var ListPrice = "";
  var SellingPrice = "";
  var Total = "";
  late Map myLang;
  int? selectedRadio;
  List<OrderModel> _list = [];
  var dataFound = false;

  var refreshKey = GlobalKey<RefreshIndicatorState>();

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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
//      bottomNavigationBar: addtToCartButton(),
      appBar: AppBar(
        title: Text(
          allTranslations.text('All_Orders'),
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: dataLoad
          ? dataFound
              ? RefreshIndicator(
                  key: refreshKey,
                  child: ListView.builder(
                      itemCount: _list.length,
                      itemBuilder: (BuildContext context, int index) {
                        return listItems(_list, index, context);
                      }),
                  onRefresh: validationCheck,
                )
              : RefreshIndicator(
                  key: refreshKey,
                  child: Container(
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        child: Center(
                            child: Image.asset("assets/noproductfound.webp")),
                      ),
                    ),
                  ),
                  onRefresh: validationCheck,
                )
          : Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
              child: Center(
                child: Image.asset("assets/storeloadding.gif"),
              ),
            ),
    );
  }

  Future<void> myLangGet() async {
    Map myLangData = await langTxt(context);
    setState(() {
      myLang = myLangData;
      Detail = myLang['Detail'];
      Online = myLang['Online'];
      StorePickup = myLang['StorePickup'];
      PaymentInfo = myLang['PaymentInfo'];
      PriceDetails = myLang['PriceDetails'];
      ListPrice = myLang['ListPrice'];
      SellingPrice = myLang['SellingPrice'];
      Total = myLang['Total'];
    });
    var check = myLangData['email'];
    validationCheck();
  }

  Future<void> validationCheck() async {
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck == true) {
      callUSerStatusCheck();
    }
  }

  void callUSerStatusCheck() async {
    Map map = {"page_no": "1", "search": ""};
    Map decoded = jsonDecode(await apiRequest(orderHistoryUrl, map, context));
    String status = decoded['status'];
    String message = decoded['message'];
    if (status == success_status) {
      var data = decoded['record'];
      _list =
          data.map<OrderModel>((json) => OrderModel.fromJson(json)).toList();
      if (_list.length > 0) {
        setState(() {
          dataFound = true;
        });
      } else {
        setState(() {
          dataFound = false;
        });
      }
    } else if (status == unauthorized_status) {
      await checkLoginStatus(context);
    } else if (status == already_login_status) {
    } else if (status == data_not_found_status) {
    } else if (status == "408") {
      Map decoded = jsonDecode(await apiRefreshRequest(context));
      callUSerStatusCheck();
    } else {
      _showToast(message);
    }
    setState(() {
      dataLoad = true;
    });
  }

  // void paymentStatusChange(booking_id, statusPayment) async {
  //   _showToast("Please wait");
  //   Map map = {"booking_id": booking_id, "status": statusPayment};
  //   Map decoded =
  //       jsonDecode(await apiRequest(updatepaymentStatusUrl, map, context));
  //   String status = decoded['status'];
  //   String message = decoded['message'];
  //   if (status == success_status) {
  //     validationCheck();
  //   } else if (status == unauthorized_status) {
  //     await checkLoginStatus(context);
  //   } else if (status == already_login_status) {
  //   } else if (status == data_not_found_status) {
  //   } else if (status == "408") {
  //     Map decoded = jsonDecode(await apiRefreshRequest(context));
  //     paymentStatusChange(booking_id, statusPayment);
  //   } else {
  //     _showToast(message);
  //   }
  //   setState(() {
  //     dataLoad = true;
  //   });
  // }

  spaceHeight() {
    return SizedBox(height: 10.0);
  }

  listItems(_list, index, context) {
//    "booking_id": "5",
//                "store_name": "Store 1 updated",
//                "name": "pc",
//                "imgs": [
//                    "https://alphaxtech.net/ecity/uploads/products/c6af7cdf-2e64-4081-90f3-afe0b85a6f393229549111796693091.jpg"
//                ],
//                "sub_total": "200",
//                "quantity": "2",
//                "added_on": "10-08-2020",
//                "product_name": "pc",
//                "product_quantity": "2"
    return GestureDetector(
      onTap: () {
        /* Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ProductItemAllDetail(product_id: _list[index].id)),
        );*/
      },
      child: Card(
          elevation: 0.0,
          margin: EdgeInsets.fromLTRB(2.0, 10.0, 2.0, 10.0),
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
                            _list[index].name.toString(),
                            maxLines: 1,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20.0),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          Text(
                            _list[index].store_currency_sign.toString() +
                                ' ' +
                                _list[index].sub_total.toString(),
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
                          Text(
                            _list[index].booking_id.toString(),
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 16.0, color: AppColours.blackColour),
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
                        imageUrl: _list[index].imgs[0] != null
                            ? _list[index].imgs[0]
                            : "",
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
                /*   Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Text(
                        _list[index].name.toString(),
                        maxLines: 1,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20.0),
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        _list[index].currency.toString() +
                            ' ' +
                            _list[index].sub_total.toString(),
                        maxLines: 1,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: AppColours.blacklightLineColour),
                        textAlign: TextAlign.right,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  _list[index].description.toString(),
                  maxLines: 2,
                  style: TextStyle(
                      fontSize: 16.0, color: AppColours.blacklightLineColour),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        _list[index].booking_id.toString(),
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 16.0, color: AppColours.blackColour),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        _list[index].added_on.toString(),
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            fontSize: 16.0, color: AppColours.blackColour),
                      ),
                    ),
                  ],
                ),*/
                SizedBox(
                  height: 15.0,
                ),
                setActionOrder(_list, index),
              ],
            ),
          )),

      /* Card(
          child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
        child: Column(
          children: <Widget>[
            Container(
                child: Stack(
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.width / 2,
                      width: MediaQuery.of(context).size.width,
                      child: CachedNetworkImage(
                        imageUrl: _list[index].imgs[0],
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            imageShimmer(context, 40.0),
                        errorWidget: (context, url, error) => Image.asset(
                          "assets/nodata.webp",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                width: MediaQuery.of(context).size.width),
            SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
              child: Align(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _list[index].product_name,
                            style: TextStyle(fontSize: 20.0),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Text(
                            _list[index].store_name,
                            style: TextStyle(
                                fontSize: 15.0,
                                color: AppColours.blacklightLineColour),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Text(
                           "Cash Payment",
                            style: TextStyle(
                                fontSize: 15.0,
                                color: AppColours.greenColour),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                alignment: Alignment.bottomRight,
              ),
            )
          ],
        ),
      )),*/
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

  setActionOrder(list, index) {
    var statusEnable = false;
    if (list[index].order_status == "1" ||
        list[index].order_status == "2" ||
        list[index].order_status == "3") {
      statusEnable = true;
    } else {
      statusEnable = false;
    }
    return statusEnable
        ? Column(
            children: [
              Divider(
                color: AppColours.blacklightLineColour,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                        child: statusEnable
                            ? callText()
                            : Container(
                                child: Container(
                                  height: 30.0,
                                  child: callText(),
                                ),
                              ),
                        onTap: () {
                          var countryCode;
                          if (list[index]
                              .merchant_country_code
                              .toString()
                              .contains("+")) {
                            countryCode =
                                list[index].merchant_country_code.toString();
                          } else {
                            countryCode = "+" +
                                list[index].merchant_country_code.toString();
                          }
                          var callNumber = countryCode +
                              list[index].merchant_phone.toString();

                          if (callNumber.toString().contains("+")) {
                            callNumber =
                                callNumber.toString().replaceAll("+", "");
                          } else {}
                          if (callNumber.toString().contains("+")) {
                            callNumber =
                                callNumber.toString().replaceAll("+", "");
                          }
                          callNumber = "+" + callNumber;
                          launch("tel:" + Uri.encodeComponent('$callNumber'));
                        }),
                  ), /*
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
                : SizedBox.shrink(),*/
                ],
              ),
              Divider(
                color: AppColours.blacklightLineColour,
              ),
            ],
          )
        : SizedBox.shrink();
  }

  void callOrderChange(list, index) async {
    var callUserLoginCheck = await internetConnectionState();
    var urlCancel = cancelOrderUrl + list[index].detail_id;
    if (callUserLoginCheck == true) {
      Map decoded = jsonDecode(await getApiDataRequest(urlCancel, context));
      String status = decoded['status'];
      String message = decoded['message'];
      if (status == success_status) {
        validationCheck();
      } else if (status == unauthorized_status) {
        await checkLoginStatus(context);
      } else if (status == already_login_status) {
      } else if (status == data_not_found_status) {
      } else if (status == "408") {
        Map decoded = jsonDecode(await apiRefreshRequest(context));
        callUSerStatusCheck();
      } else {
        _showToast(message);
      }
      setState(() {
        dataLoad = true;
      });
    }
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

  orderStatusSet(list, index) {
    //1=new order,2=dispatch ready,3=on the way,4=delivered,5=cancel by user,6=cancel by admin
    var colour = Colors.green;
    var text = "";
    if (list[index].order_status == "1") {
      colour = Colors.red;
      text = allTranslations.text("new_order");
    } else if (list[index].order_status == "2") {
      colour = Colors.green;
      text = allTranslations.text("dispatch_ready");
    } else if (list[index].order_status == "3") {
      colour = Colors.green;
      text = allTranslations.text("on_the_way");
    } else if (list[index].order_status == "4") {
      colour = Colors.green;
      text = allTranslations.text("delivered");
    } else if (list[index].order_status == "5") {
      colour = Colors.red;
      text = 'cancel by user';
    } else if (list[index].order_status == "6") {
      colour = Colors.red;
      text = 'cancel by admin';
    } else {
      colour = Colors.green;
      text = 'cancel by admin';
    }
    return Text(
      text.toString(),
      maxLines: 1,
      style:
          TextStyle(fontSize: 16.0, color: colour, fontWeight: FontWeight.bold),
    );
  }
}
