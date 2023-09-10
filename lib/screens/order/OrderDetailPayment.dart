import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/models/OrderDetailModel.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/shimmerEffects/imageloadshimmer.dart';
import 'package:avauserapp/components/shimmerEffects/profiledetailshimmer.dart';
import 'package:avauserapp/components/shimmerEffects/sizeImageShimmer.dart';
import 'package:avauserapp/components/widget/button.dart';
import 'package:avauserapp/screens/Dispute/DisputeApply.dart';
import 'package:avauserapp/screens/Dispute/DisputeDetail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderPaymentDetail extends StatefulWidget {
  OrderPaymentDetail({Key? key, this.id}) : super(key: key);
  var id;

  @override
  _PaymentDetail createState() => _PaymentDetail();
}

class _PaymentDetail extends State<OrderPaymentDetail> {
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
  int? shopSelectedRadio;
  bool isSwitchedDis = true;
  bool isSwitchedIndividual = false;
  bool isSwitchedGroupClan = true;
  var dataFound = false;
  List<OrderDetailModel> _list = [];
  var store_info, payment_detail;
  var loading = false;
  var itemChangeLoadding = false;
  var applyOfferEnable = false;
  var result;
  var record;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedRadio = 2;
    shopSelectedRadio = 1;
    getDetail();
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
        child: new Scaffold(
//      bottomNavigationBar: addtToCartButton(),
          appBar: AppBar(
            title: Text(
              allTranslations.text('Detail'),
              style: TextStyle(color: Colors.black),
            ),
            iconTheme: IconThemeData(color: Colors.black),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  setBackData();
                }),
            centerTitle: true,
            backgroundColor: Colors.white,
          ),
          body: dataLoad
              ? Stack(
                  children: <Widget>[
                    SingleChildScrollView(
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: ItemDetail(),
                            )
                          ],
                        ),
                      ),
                    ),
                    itemChangeLoadding
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : SizedBox.shrink()
                  ],
                )
              : Container(
                  child: profileDetail(context),
                ),
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
      ),
    );
  }

  ItemDetail() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      child: Container(
        color: AppColours.whiteColour,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: CachedNetworkImage(
                          imageUrl: record['store_logo'] ?? "",
                          fit: BoxFit.cover,
                          placeholder: (context, url) => sizeImageShimmer(
                              context,
                              MediaQuery.of(context).size.width,
                              MediaQuery.of(context).size.height / 5.5),
                          errorWidget: (context, url, error) => Image.asset(
                            "assets/nodata.webp",
                            fit: BoxFit.cover,
                          ),
                          width: double.maxFinite,
                          height: MediaQuery.of(context).size.height / 5.5,
                        )),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        itemCardSpace(),
                        store_info['address_type'] == "1"
                            ? SizedBox.shrink()
                            : storeAddress(),
                        applyOfferEnable ? itemCardSpace() : SizedBox.shrink(),
                        applyOfferEnable ? applyOffers() : SizedBox.shrink(),
                        storeDetail(),
                        itemCardSpace(),
                      ],
                    ),
                  ),
                )
              ],
            ),
            shippingDetailDetail(),
            Container(
              child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _list.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                        padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 10.0),
                        child: listItems(_list, index, context));
                  }),
            ),
            itemCardSpace(),
            Padding(
                padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 10.0),
                child: paymentDetail()),
            spaceHeight(),
            if (record['status'] == "4")
              Padding(
                  padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 10.0),
                  child: despute()),
          ],
        ),
      ),
    );
  }

  spaceHeight() {
    return SizedBox(height: 10.0);
  }

  listItems(List<OrderDetailModel> _list, index, context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: new BorderRadius.circular(10.0),
        border: Border.all(width: 0.2, color: Colors.black),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        CachedNetworkImage(
                          imageUrl: _list[index].imgs.toString() != "[]"
                              ? _list[index].imgs[0]
                              : "",
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              imageShimmer(context, 80.0),
                          errorWidget: (context, url, error) => Image.asset(
                            "assets/nodata.webp",
                            fit: BoxFit.cover,
                          ),
                          height: MediaQuery.of(context).size.width / 3.5,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ],
                    )),
                Expanded(
                  flex: 8,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          _list[index].product_name,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          _list[index].product_description,
                          maxLines: 2,
                          style: TextStyle(
                              fontSize: 14.0,
                              color: AppColours.blacklightLineColour,
                              letterSpacing: .5),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          payment_detail['currency_sign'].toString() +
                              "  " +
                              _list[index].product_price +
                              ' x ' +
                              _list[index].quantity,
                          style: TextStyle(fontSize: 16.0),
                          textAlign: TextAlign.end,
                        ),
                        priceSet(_list, index),
                        SizedBox(
                          height: 10.0,
                        ),
                        priceItem(_list, index),
                        /* Align(
                          child: SizedBox(
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 9,
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 10.0),
                                    child: priceItem(_list, index),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 10.0),
                                  child: Text(
                                    _list[index].product_price+' x ' + _list[index].quantity,
                                    style: TextStyle(fontSize: 16.0),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          alignment: Alignment.bottomLeft,
                        ),*/
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (_list[index].size != "")
                  Expanded(
                      flex: 2,
                      child: RichText(
                        maxLines: 1,
                        text: TextSpan(children: [
                          TextSpan(
                              text: allTranslations.text("size") + " : ",
                              style: TextStyle(
                                  fontSize: 14.0,
                                  color: AppColours.blacklightLineColour,
                                  letterSpacing: .5)),
                          TextSpan(
                              text: _list[index].size ?? " ",
                              style: TextStyle(
                                  fontSize: 14.0,
                                  color: AppColours.blackColour,
                                  letterSpacing: .5)),
                        ]),
                      )),
                Spacer(
                  flex: 1,
                ),
                if (_list[index].color != "")
                  Expanded(
                      flex: 2,
                      child: RichText(
                        maxLines: 1,
                        text: TextSpan(children: [
                          TextSpan(
                              text: allTranslations.text("Color") + " : ",
                              style: TextStyle(
                                  fontSize: 14.0,
                                  color: AppColours.blacklightLineColour,
                                  letterSpacing: .5)),
                          TextSpan(
                              text: _list[index].color ?? "",
                              style: TextStyle(
                                  fontSize: 14.0,
                                  color: AppColours.blackColour,
                                  letterSpacing: .5)),
                        ]),
                      )),
              ],
            ),
            statusManage(_list, index),
          ],
        ),
      ),
    );
  }

  void callOrderChange(List<OrderDetailModel> list, index) async {
    var callUserLoginCheck = await internetConnectionState();
    var urlCancel = cancelOrderUrl + list[index].id;
    if (callUserLoginCheck == true) {
      Map decoded = jsonDecode(await getApiDataRequest(urlCancel, context));
      String status = decoded['status'];
      String message = decoded['message'];
      if (status == success_status) {
        getDetail();
      } else if (status == unauthorized_status) {
        await checkLoginStatus(context);
      } else if (status == already_login_status) {
      } else if (status == data_not_found_status) {
      } else if (status == "408") {
        Map decoded = jsonDecode(await apiRefreshRequest(context));
        getDetail();
      } else {
        _showToast(message);
      }
      setState(() {
        dataLoad = true;
      });
    }
  }

  void _onLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new CircularProgressIndicator();
      },
    );
  }

  storeAddress() {
    return Container(
        color: AppColours.whiteColour,
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Padding(
              padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    allTranslations.text('Store_Address'),
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),
                  ),
                  spaceHeight(),
                  Text(
                    store_info['customer_address'].toString(),
                    style: TextStyle(
                        height: 1.5,
                        color: AppColours.blacklightLineColour,
                        letterSpacing: .5),
                  )
                ],
              )),
        ));
  }

  applyOffers() {
    return GestureDetector(
      child: Container(
          color: AppColours.whiteColour,
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.all(10.0),
            child: Text(
              allTranslations.text('Apply_Offer'),
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold),
            ),
          )),
      onTap: () {
        // offerApply(context);
      },
    );
  }

  paymentInfo() {
    return Container(
        color: AppColours.whiteColour,
        child: Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                allTranslations.text('PaymentInfo'),
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Image.asset(
                      "assets/PaymentCards/Visa.webp",
                      width: 100,
                      height: 40.0,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(""),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text("4242 4242 424 111"),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      allTranslations.text('Change'),
                      style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                    ),
                  )
                ],
              )
            ],
          ),
        ));
  }

  storeDetail() {
    return Container(
        color: AppColours.whiteColour,
        child: Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                      flex: 6,
                      child: Text(
                        allTranslations.text('storeName'),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18.0),
                      )),
                  Expanded(
                    flex: 3,
                    child: Text(
                      record['store_name'].toString(),
                      style: TextStyle(fontSize: 18.0),
                      textAlign: TextAlign.end,
                    ),
                  )
                ],
              ),
              spaceHeight(),
              spaceHeight(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                      flex: 6,
                      child: Text(
                        "#" + payment_detail['booking_id'].toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColours.appTheme),
                      )),
                  Expanded(
                    flex: 3,
                    child: orderStatusSet(record['status']),
                  )
                ],
              ),
              /* payment_detail['total_discount'].toString() != "0"
                  ? spaceHeight()
                  : SizedBox.shrink(),
              payment_detail['total_discount'].toString() != "0"
                  ? discountSet()
                  : SizedBox.shrink(),*/
              /*  spaceHeight(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                      flex: 6,
                      child: Text(
                        allTranslations.text('Total'),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                  Expanded(
                    flex: 3,
                    child: Text(
                        payment_detail['currency'].toString() +
                            " " +
                            payment_detail['discounted_amount'].toString(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.end),
                  )
                ],
              ),*/
            ],
          ),
        ));
  }

  paymentDetail() {
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(10.0),
          border: Border.all(width: 0.2, color: Colors.black),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                allTranslations.text('PaymentInfo'),
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              spaceHeight(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                      flex: 6,
                      child: Text(
                        allTranslations.text('Total'),
                      )),
                  Expanded(
                    flex: 3,
                    child: Text(
                      payment_detail['currency_sign'].toString() +
                          "  " +
                          payment_detail['discounted_amount'].toString(),
                      style: TextStyle(),
                      textAlign: TextAlign.end,
                    ),
                  )
                ],
              ),
              /* payment_detail['total_discount'].toString() != "0"
                  ? spaceHeight()
                  : SizedBox.shrink(),
              payment_detail['total_discount'].toString() != "0"
                  ? discountSet()
                  : SizedBox.shrink(),*/
              /*  spaceHeight(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                      flex: 6,
                      child: Text(
                        allTranslations.text('Total'),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                  Expanded(
                    flex: 3,
                    child: Text(
                        payment_detail['currency'].toString() +
                            " " +
                            payment_detail['discounted_amount'].toString(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.end),
                  )
                ],
              ),*/
            ],
          ),
        ));
  }

  despute() {
    return SizedBox(
      height: 50.0,
      width: MediaQuery.of(context).size.width,
      child: trasparentColouredBtn(
          text: allTranslations.text('dispute'),
          radiusButtton: 20.0,
          onPressed: () async {
            record["dispute_id"] == ""
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DisputeCreate(
                              order_id: record['id'],
                            )))
                : Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DisputeDetail(
                              disputeId: record['dispute_id'],
                            )));
          }),
    );
  }

  void getDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var offerApply = "false";
    if (result.toString() == 'null') {
      offerApply = "false";
      var applyCupon = prefs.getString('applyCupon');
      if (applyCupon.toString() == 'true') {
        offerApply = "true";
      }
    } else {
      offerApply = "true";
    }
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck == true) {
      var urlData = detailUrl + widget.id;
      Map decoded = jsonDecode(await getApiDataRequest(urlData, context));
      String status = decoded['status'];
      String message = decoded['message'];
      if (status == success_status) {
        record = decoded['record'];
        callData(record);
      } else if (status == unauthorized_status) {
        await checkLoginStatus(context);
      } else if (status == already_login_status) {
        _showToast(message);
      } else if (status == data_not_found_status) {
        _showToast(message);
        Navigator.pop(context);
        Navigator.pop(context);
      } else if (status == expire_token_status) {
        Map decoded = jsonDecode(await apiRefreshRequest(context));
        getDetail();
      } else {
        _showToast(message);
      }
      setState(() {
        dataLoad = true;
        itemChangeLoadding = false;
      });
    }
  }

  itemCardSpace() {
    return SizedBox(
      height: 10.0,
    );
  }

  priceSet(List<OrderDetailModel> _list, index) {
    var itemQty =
        double.parse(_list[index].quantity.toString().replaceAll(",", ""));
    var itemPrice =
        double.parse(_list[index].product_price.toString().replaceAll(",", ""));
    var totalPrice = itemQty * itemPrice;
    double pi = totalPrice;
    var val = pi.toStringAsFixed(2);
    bool check = false;
    try {
      var val = _list[index].applied_offer['amount_unit'];
      check = true;
    } catch (_) {
      check = false;
    }
    if (_list[index].applied_offer != "[]" &&
        _list[index].applied_offer != "" &&
        check) {
      if (_list[index].applied_offer['amount_unit'].toString() == '1') {
        return Row(
          children: [
            Expanded(
              flex: 9,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                child: Text(
                  payment_detail['currency_sign'].toString() +
                      "  " +
                      val.toString(),
                  style: TextStyle(
                      fontSize: 16.0, decoration: TextDecoration.lineThrough),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            Expanded(
              flex: 9,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                child: Text(
                  _list[index].applied_offer['offer_amount'].toString() +
                      " % Off",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: AppColours.appTheme),
                  textAlign: TextAlign.end,
                ),
              ),
            ),
          ],
        );
      } else {
        return Row(
          children: [
            Expanded(
              flex: 9,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                child: Text(
                  payment_detail['currency_sign'].toString() +
                      "  " +
                      val.toString(),
                  style: TextStyle(
                      fontSize: 16.0, decoration: TextDecoration.lineThrough),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            Expanded(
              flex: 9,
              child: Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                  child: Text(
                    payment_detail['currency_sign'].toString() +
                        "  " +
                        _list[index].applied_offer['offer_amount'].toString() +
                        " off",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: AppColours.appTheme),
                    textAlign: TextAlign.end,
                  )),
            ),
          ],
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }

  void callData(record) {
    store_info = record;
    payment_detail = record;
    var items = record['items'];
    var offers = record['offers'];
    _list = items
        .map<OrderDetailModel>((json) => OrderDetailModel.fromJson(json))
        .toList();
    if (_list.length > 0) {
      setState(() {
        dataFound = true;
      });
    }
  }

  discountSet() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(flex: 6, child: Text(allTranslations.text('Discount'))),
        Expanded(
            flex: 3,
            child: Text(
              payment_detail['currency_sign'].toString() +
                  "  " +
                  payment_detail['discounted_amount'].toString(),
              style: TextStyle(),
              textAlign: TextAlign.end,
            )),
      ],
    );
  }

  priceItem(List<OrderDetailModel> _list, index) {
    var itemQty =
        double.parse(_list[index].quantity.toString().replaceAll(",", ""));
    var itemPrice =
        double.parse(_list[index].offer_price.toString().replaceAll(",", ""));
    var totalPrice = 1.0 * itemPrice;
    double pi = totalPrice;
    var val = pi.toStringAsFixed(2);
    return Text(
      payment_detail['currency_sign'].toString() + "  " + val.toString(),
      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      textAlign: TextAlign.start,
    );
  }

  statusManage(List<OrderDetailModel> list, index) {
    var orderStatus = record['status'];
    var text;
    var clickEnable = false;
    if (orderStatus == "1" || orderStatus == "2" || orderStatus == "3") {
      if (list[index].status == "2") {
        text = allTranslations.text('orderCanceled');
        clickEnable = false;
        return Column(
          children: [
            Divider(
              color: AppColours.blackColour,
              thickness: 0.2,
            ),
            GestureDetector(
              onTap: () {
                if (clickEnable) callOrderChange(_list, index);
              },
              child: SizedBox(
                  height: 30.0,
                  child: Align(
                    child: Text(
                      text,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    alignment: Alignment.center,
                  )),
            )
          ],
        );
      } else {
        text = allTranslations.text('Remove');
        clickEnable = true;
        return Container();
      }
    } else {
      if (list[index].status == "2") {
        text = allTranslations.text('orderCanceled');
        clickEnable = false;
        return Column(
          children: [
            Divider(
              color: AppColours.blacklightColour,
            ),
            GestureDetector(
              onTap: () {
                clickEnable ? callOrderChange(_list, index) : {};
              },
              child: SizedBox(
                  height: 30.0,
                  child: Align(
                    child: Text(
                      text,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    alignment: Alignment.center,
                  )),
            )
          ],
        );
      } else {
        return SizedBox.shrink();
      }
    }
  }

  void setBackData() {
    Navigator.pop(context, "data");
  }

  orderStatusSet(record) {
    //1=new order,2=dispatch ready,3=on the way,4=delivered,5=cancel by user,6=cancel by admin
    var colour = Colors.green;
    var text = "";
    if (record == "1") {
      colour = Colors.red;
      text = allTranslations.text("new_order");
    } else if (record == "2") {
      colour = Colors.green;
      text = allTranslations.text("dispatch_ready");
    } else if (record == "3") {
      colour = Colors.green;
      text = allTranslations.text("on_the_way");
    } else if (record == "4") {
      colour = Colors.green;
      text = allTranslations.text("delivered");
    } else if (record == "5") {
      colour = Colors.red;
      text = allTranslations.text("cancelled_by_user");
    } else if (record == "6") {
      colour = Colors.red;
      text = allTranslations.text("cancelled_by_admin");
    } else {
      colour = Colors.green;
      text = allTranslations.text("cancelled_by_admin");
    }
    return Text(
      text.toString(),
      maxLines: 1,
      textAlign: TextAlign.end,
      style:
          TextStyle(fontSize: 16.0, color: colour, fontWeight: FontWeight.bold),
    );
  }

  shippingDetailDetail() {
    return Padding(
        padding: EdgeInsets.all(5.0),
        child: new Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              borderRadius: new BorderRadius.circular(10.0),
              border: Border.all(width: 0.2, color: Colors.black),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  allTranslations.text('ShippingAddress'),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                spaceHeight(),
                addressSet(record),
              ],
            )));
  }

  addressSet(paymentRecord) {
    var address;
    if (paymentRecord['address_type'] == "1") {
      address = "Store Pickup";
    } else {
      address = paymentRecord['customer_address'];
    }
    return Text(address);
  }
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
