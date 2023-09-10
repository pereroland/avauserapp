import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/createTransactionId.dart';
import 'package:avauserapp/components/dataLoad/myWallettModeLoad.dart';
import 'package:avauserapp/components/dialog/otpCheck.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/models/ProductCartModel.dart';
import 'package:avauserapp/components/models/offerModel.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/shimmerEffects/imageloadshimmer.dart';
import 'package:avauserapp/components/shimmerEffects/profiledetailshimmer.dart';
import 'package:avauserapp/screens/Item/completePayment.dart';
import 'package:avauserapp/screens/clan/Clan.dart';
import 'package:avauserapp/screens/paymentSetup/AccountSetupUpdate.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'applyCupon.dart';

class PaymentDetail extends StatefulWidget {
  Map campaignData;

  PaymentDetail({required this.campaignData});

  @override
  _PaymentDetail createState() => _PaymentDetail();
}

class _PaymentDetail extends State<PaymentDetail> {
  var dataLoad = false;
  var isShow = false;
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
  int? paymentTypeRadio;
  bool isSwitchedDis = true;
  bool isSwitchedIndividual = false;
  bool isSwitchedGroupClan = true;
  var dataFound = false;
  List<ProductCartModel> _list = [];
  List<OfferModel> _offerList = [];
  List selectColor = [];
  var store_info, payment_detail;
  var loading = false;
  var itemChangeLoadding = false;
  var applyOfferEnable = false;
  var result;
  var walletEnable = false;
  var mainPrice;
  var authToken;
  bool isAuthToken = false;

  @override
  void initState() {
    super.initState();
    paymentTypeRadio = 1;
    selectedRadio = 1;
    _list.clear();
    shopSelectedRadio = 1;
    getDetail();
  }

  setSelectedRadio(int? val) {
    setState(() {
      selectedRadio = val!;
      if (selectedRadio == 1) {
      } else {}
    });
  }

  setPaymentTypeSelectedRadio(int? val) {
    setState(() {
      paymentTypeRadio = val!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            allTranslations.text('Detail'),
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context)),
        ),
        body: dataLoad
            ? Stack(
                children: <Widget>[
                  SingleChildScrollView(
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: ItemDetail(context),
                          )
                        ],
                      ),
                    ),
                  ),
                  itemChangeLoadding
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColours.blackColour),
                          ),
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
    );
  }

  Future<bool> _shoppingType() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            allTranslations.text('Select_Shopping_Type'),
            style: TextStyle(color: AppColours.appTheme),
          ),
          content: Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Container(
                      child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        children: <Widget>[
                          Radio(
                            value: 1,
                            groupValue: shopSelectedRadio,
                            onChanged: (int? val) {
                              setSelectedRadio(val);
                            },
                          ),
                          Expanded(
                              flex: 9,
                              child: Text(
                                allTranslations.text('Individual_Purchase'),
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              )),
                        ],
                      ),
                    ),
                  )),
                ),
                Padding(
                    padding: EdgeInsets.all(2.0),
                    child: GestureDetector(
                      child: Container(
                          child: Card(
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Row(
                            children: <Widget>[
                              Radio(
                                value: 2,
                                groupValue: shopSelectedRadio,
                                onChanged: (int? val) {
                                  setSelectedRadio(val);
                                },
                              ),
                              Expanded(
                                  flex: 9,
                                  child: Text(
                                    allTranslations.text('Group_Purchase'),
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ],
                          ),
                        ),
                      )),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ClanDetail()),
                        );
                      },
                    )),
              ],
            ),
          ),
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0)),
        );
      },
    );
    return Future.value(false);
  }

  ItemDetail(context) {
    SizedBox sizedBox = SizedBox(
      height: 10.0,
    );
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _list.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                        padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                        child: listItems(_list, index, context));
                  }),
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sizedBox,
                  storeAddress(),
                  sizedBox,
                  applyOfferEnable ? applyOffers() : SizedBox.shrink(),
                  sizedBox,
                  individualShopping(),
                  sizedBox,
                  shoppingType(),
                  sizedBox,
                  selectedRadio == 1 ? paymentInfo() : SizedBox.shrink(),
                  sizedBox,
                  cashTokens(),
                  sizedBox,
                  paymentDetail(),
                  sizedBox,
                  sizedBox,
                  addtToCartButton(context),
                  sizedBox,
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  addtToCartButton(context) {
    return Hero(
        tag: 'registration',
        child: Row(
          children: <Widget>[
            Expanded(
              child: ButtonTheme(
                minWidth: 200.0,
                height: 50.0,
                buttonColor: AppColours.appTheme,
                child: MaterialButton(
                  elevation: 16.0,
                  color: AppColours.appTheme,
                  shape: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColours.appTheme),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  onPressed: () {
                    if (!loading && !itemChangeLoadding) checkoutBtn(context);
                  },
                  child: loading
                      ? CircularProgressIndicator(
                          valueColor:
                              new AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          allTranslations.text('Checkout'),
                          style: TextStyle(fontSize: 16.0, color: Colors.white),
                        ),
                ),
              ),
            ),
          ],
        ));
  }

  listItems(_list, index, context) {
    return Container(
      color: AppColours.whiteColour,
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
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
                        imageUrl: _list[index].imgs[0].toString(),
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            imageShimmer(context, 100.0),
                        errorWidget: (context, url, error) => Image.asset(
                          "assets/nodata.webp",
                          fit: BoxFit.cover,
                        ),
                        height: MediaQuery.of(context).size.width / 2.5,
                        width: MediaQuery.of(context).size.width,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _list[index].name,
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(_list[index].description,
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 14.0,
                                  color: AppColours.blacklightLineColour,
                                  letterSpacing: .5)),
                          priceSet(_list, index),
                          Align(
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
                                  Expanded(
                                    flex: 3,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      color: AppColours.appTheme,
                                      onPressed: () {
                                        // var qtyCheck=int.parse(_list[index].qty.toString());
                                        if (!itemChangeLoadding)
                                          addReamoveCartItem(
                                            _list[index],
                                            "-1",
                                            index,
                                          );
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      _list[index].qty,
                                      style: TextStyle(fontSize: 16.0),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: IconButton(
                                      alignment: Alignment.centerLeft,
                                      icon: Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      color: AppColours.appTheme,
                                      onPressed: () {
                                        // var qtyCheck=int.parse(_list[index].qty.toString());
                                        if (!itemChangeLoadding)
                                          addReamoveCartItem(
                                            _list[index],
                                            '+1',
                                            index,
                                          );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            alignment: Alignment.bottomLeft,
                          ),
                          if (selectColor.isNotEmpty || selectColor.length != 0)
                            if (selectColor[index]['selected_size'].length !=
                                0) ...[
                              Text(
                                allTranslations.text('size') +
                                    ': ' +
                                    selectColor[index]['selected_size'][0]
                                        ['option_name'],
                                style: TextStyle(fontSize: 16.0),
                                textAlign: TextAlign.center,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    // _list[index].size[0]['option_name'],
                                    allTranslations.text('Color') + ': ',
                                    style: TextStyle(fontSize: 16.0),
                                    textAlign: TextAlign.center,
                                  ),
                                  Icon(
                                    Icons.circle,
                                    size: 23,
                                    color: Color(
                                      int.parse(
                                        "0xff" +
                                            selectColor[index]['selected_color']
                                                    [0]['option_value']
                                                .toString()
                                                .replaceAll("#", ""),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ]
                        ]),
                  ),
                ),
              ],
            ),
            Divider(
              color: AppColours.blacklightColour,
            ),
            GestureDetector(
              onTap: () {
                if (!itemChangeLoadding)
                  removeCart(_list[index].cart_id.toString());
              },
              child: SizedBox(
                  height: 30.0,
                  child: Align(
                    child: Text(
                      allTranslations.text('Remove'),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    alignment: Alignment.center,
                  )),
            ),
          ],
        ),
      ),
    );
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
    SizedBox sizedBox = SizedBox(
      height: 10.0,
    );
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
                  sizedBox,
                  Text(
                    store_info['store_address'],
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
        offerApply(context);
      },
    );
  }

  individualShopping() {
    return Container(
        color: AppColours.whiteColour,
        child: GestureDetector(
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.all(10.0),
            child: Text(
              allTranslations.text('Individual_Shopping'),
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          onTap: () {
            _shoppingType();
          },
        ));
  }

  shoppingType() {
    return Container(
        color: AppColours.whiteColour,
        child: Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Radio(
                      value: 1,
                      groupValue: selectedRadio,
                      onChanged: (int? val) {
                        if (!itemChangeLoadding) setSelectedRadio(val);
                      },
                    ),
                    Text(
                      allTranslations.text('Online'),
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Radio(
                      value: 2,
                      groupValue: selectedRadio,
                      onChanged: (int? val) {
                        if (!itemChangeLoadding) setSelectedRadio(val);
                      },
                    ),
                    Text(
                      allTranslations.text('StorePickup'),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
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
                allTranslations.text('PaymentType'),
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              Row(
                children: <Widget>[
                  walletEnable
                      ? Expanded(
                          flex: 1,
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              Radio(
                                value: 1,
                                groupValue: paymentTypeRadio,
                                onChanged: (int? val) {
                                  if (!itemChangeLoadding)
                                    setPaymentTypeSelectedRadio(val);
                                },
                              ),
                              Text(
                                allTranslations.text('Wallet'),
                              )
                            ],
                          ),
                        )
                      : SizedBox.shrink(),
                  Expanded(
                    flex: 1,
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Radio(
                          value: 2,
                          groupValue: paymentTypeRadio,
                          onChanged: (int? val) {
                            if (!itemChangeLoadding)
                              setPaymentTypeSelectedRadio(val);
                          },
                        ),
                        Text(
                          allTranslations.text('CardorPhone'),
                        )
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }

  cashTokens() {
    SizedBox sizedBox = SizedBox(
      height: 10.0,
    );
    return payment_detail['tokenmsg']['is_valid_for_token'] == 1
        ? Container(
            color: AppColours.whiteColour,
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/MicrosoftTeams-image.png',
                        height: 25,
                      ),
                      SizedBox(width: 8),
                      Text(
                        allTranslations.text('tokenHead'),
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  sizedBox,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          payment_detail['tokenmsg']['message'],
                          maxLines: 3,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isShow = !isShow;
                          });
                        },
                        icon: Icon(
                          Icons.info,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        : SizedBox.shrink();
  }

  paymentDetail() {
    SizedBox sizedBox = SizedBox(
      height: 10.0,
    );
    return Container(
        color: AppColours.whiteColour,
        child: Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                allTranslations.text('PriceDetails'),
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              sizedBox,
              discountCheck(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: Text(
                      allTranslations.text('Total'),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      _list[0].currency.toString() +
                          " " +
                          payment_detail['total_discounted_price'].toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  )
                ],
              ),
            ],
          ),
        ));
  }

  void getDetail() async {
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck == true) {
      Map decoded = jsonDecode(await getApiDataRequest(loadCartUrl, context));
      String status = decoded['status'];
      String message = decoded['message'];
      if (status == success_status) {
        var record = decoded['record'];
        callData(record);
      } else if (status == unauthorized_status) {
        await checkLoginStatus(context);
      } else if (status == already_login_status) {
        _showToast(message);
      } else if (status == data_not_found_status) {
        _showToast(message);
        setCartItem('null');
        Navigator.pop(context);
      } else if (status == expire_token_status) {
        jsonDecode(await apiRefreshRequest(context));
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

  void paymentStoreCheckShop() async {
    setState(() {
      loading = true;
    });
    var amount = mainPrice.toString();
    var callUserLoginCheck = await internetConnectionState();
    var cpmId = selectDatePick(context, "ORDER");

    if (callUserLoginCheck == true) {
      Map map = {"cart_total": amount};
      Map decoded = jsonDecode(await apiRequestMainPage(stockCheckUrl, map));
      String status = decoded['status'];
      String message = decoded['message'];
      if (status == success_status) {
        var record = decoded['record'];

        var result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccountSetUpUpdate(
              payment_mode: "phone",
              paymentFor: "2",
              // order for 2
              referenceId: "0",
              merchantId: store_info['merchant_id'].toString(),
              cpm_trans_id: cpmId,
              amount: amount,
              record: record,
              storeId: _list[0].store_id.toString(),
            ),
          ),
        );
      } else if (status == unauthorized_status) {
        await checkLoginStatus(context);
      } else if (status == already_login_status) {
        _showToast(message);
      } else if (status == expire_token_status) {
        jsonDecode(await apiRefreshRequest(context));
        paymentStoreCheckShop();
      } else {
        _showToast(message);
      }
      setState(() {
        loading = false;
      });
    }
  }

  void walletpaymentStoreCheckShop() async {
    setState(() {
      loading = true;
    });
    var amount = mainPrice.toString();
    var callUserLoginCheck = await internetConnectionState();
    var cpmId = selectDatePick(context, "ORDER");

    if (callUserLoginCheck == true) {
      Map map = {
        "group_id": "",
        "clan_userId": "",
        "camp_id": widget.campaignData.toString() != "{}" &&
                widget.campaignData.isNotEmpty
            ? widget.campaignData["products"][0]["campaign_id"]
            : "",
        "cart_total": amount,
        "txn_id": cpmId
      };
      Map decoded =
          jsonDecode(await apiRequestMainPage(confirmWithWalletUrl, map));
      String status = decoded['status'];
      String message = decoded['message'];
      if (status == success_status) {
        getApiDataRequest(emptyCartUrl, context);
        submitCashTokenData();
        var record = decoded['record'];
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => CompletePayment(paymentRecord: record)),
        );
      } else if (status == unauthorized_status) {
        await checkLoginStatus(context);
      } else if (status == already_login_status) {
        _showToast(message);
      } else if (status == expire_token_status) {
        jsonDecode(await apiRefreshRequest(context));
        paymentStoreCheckShop();
      } else {
        _showToast(message);
      }
      setState(() {
        loading = false;
      });
    }
  }

  void paymentShop() async {
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck == true) {
      if (mounted)
        setState(() {
          loading = true;
        });
      Map map = {
        "group_id": "",
        "camp_id": widget.campaignData.toString() != "{}" &&
                widget.campaignData.isNotEmpty
            ? widget.campaignData["products"][0]["campaign_id"]
            : "",
        "clan_userId": "",
        "cart_total": mainPrice.toString().replaceAll(",", "")
      };
      Map decoded = jsonDecode(await apiRequestMainPage(addOrderUrl, map));
      String status = decoded['status'];
      String message = decoded['message'];
      if (status == success_status) {
        submitCashTokenData();
        var record = decoded['record'];
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => CompletePayment(paymentRecord: record)),
        );
      } else if (status == unauthorized_status) {
        await checkLoginStatus(context);
      } else if (status == already_login_status) {
        _showToast(message);
      } else if (status == expire_token_status) {
        jsonDecode(await apiRefreshRequest(context));
        paymentShop();
      } else {
        _showToast(message);
      }
      if (mounted)
        setState(() {
          loading = false;
        });
    }
  }

  void removeCart(productId) async {
    var callUserLoginCheck = await internetConnectionState();
    var apiRemoveData = removeItemUrl + productId;
    if (callUserLoginCheck == true) {
      setState(() {
        itemChangeLoadding = true;
      });
      Map decoded = jsonDecode(await getApiDataRequest(apiRemoveData, context));
      String status = decoded['status'];
      String message = decoded['message'];
      if (status == success_status) {
        getDetail();
      } else if (status == unauthorized_status) {
        await checkLoginStatus(context);
        setState(() {
          itemChangeLoadding = false;
        });
      } else if (status == already_login_status) {
        _showToast(message);
        setState(() {
          itemChangeLoadding = false;
        });
      } else if (status == data_not_found_status) {
        _showToast(message);
        Navigator.pop(context);
        Navigator.pop(context);
      } else if (status == expire_token_status) {
        Map decoded = jsonDecode(await apiRefreshRequest(context));
        removeCart(productId);
      } else {
        _showToast(message);
        setState(() {
          itemChangeLoadding = false;
        });
      }
    }
  }

  void addReamoveCartItem(product, String qty, i) async {
    var selectedSize = selectColor.length != 0
        ? selectColor[i]['selected_size'].isNotEmpty
            ? selectColor[i]['selected_size'][0]['id']
            : ""
        : "";
    var selectedColor = selectColor.length != 0
        ? selectColor[i]['selected_color'].isNotEmpty
            ? selectColor[i]['selected_color'][0]['id']
            : ""
        : "";
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck == true) {
      setState(() {
        itemChangeLoadding = true;
      });
      Map map = {
        "action": '',
        "product_id": product.product_id.toString(),
        "quantity": qty.toString(),
        "selected_size": selectedSize,
        "selected_color": selectedColor
      };
      Map decoded = jsonDecode(await apiRequest(addtoCartUrl, map, context));
      String status = decoded['status'];
      String message = decoded['message'];
      if (status == success_status) {
        getDetail();
      } else if (status == unauthorized_status) {
        await checkLoginStatus(context);
        setState(() {
          itemChangeLoadding = false;
        });
      } else if (status == already_login_status) {
        setState(() {
          itemChangeLoadding = false;
        });
      } else if (status == "408") {
        jsonDecode(await apiRefreshRequest(context));
        addReamoveCartItem(product.product_id.toString(), qty, i);
      } else {
        _showToast(message);
        setState(() {
          itemChangeLoadding = false;
        });
      }
    }
  }

  priceSet(_list, index) {
    var offerApplyed = _list[index].applyed_offer.toString();

    var itemQty = double.parse(_list[index].qty.toString().replaceAll(",", ""));
    var itemPrice =
        double.parse(_list[index].price.toString().replaceAll(",", ""));
    var totalPrice = itemQty * itemPrice;
    double pi = totalPrice;
    var val = pi.toStringAsFixed(2);
    if (offerApplyed != "[]") {
      if (_list[index].applyed_offer['amount_unit'].toString() == '1') {
        return Row(
          children: [
            Expanded(
              flex: 9,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                child: Text(
                  _list[index].currency.toString() + " " + val.toString(),
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
                  _list[index].applyed_offer['offer_amount'].toString() +
                      " % Off",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: AppColours.appTheme),
                  textAlign: TextAlign.center,
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
                  _list[index].currency.toString() + " " + val.toString(),
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
                    _list[index].applyed_offer['amount_currency'].toString() +
                        " " +
                        _list[index].applyed_offer['offer_amount'].toString() +
                        " off",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: AppColours.appTheme),
                    textAlign: TextAlign.start,
                  )),
            ),
          ],
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }

  void offerApply(context) async {
    result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ApplyCupon(listCupon: _offerList)),
    );
    if (result == null) {
    } else {
      callData(result);
    }
  }

  void callData(record) {
    if (record['authfortoken'] != "0" && record.toString() != "null") {
      setState(() {
        isAuthToken = true;
        authToken = record['authfortoken']['access_token'];
      });
    } else {
      setState(() {
        isAuthToken = false;
      });
    }
    setCartItem(record['cart']['total_items'].toString());
    store_info = record['store_info'];
    // authToken
    payment_detail = record['cart'];
    var items = record['cart']['item'];
    var offers = record['offers'];
    _list = items
        .map<ProductCartModel>((json) => ProductCartModel.fromJson(json))
        .toList();
    selectColor = items;
    // selectSize = items;
    walletCheck(record['paymentWithWallet']);
    if (offers.toString() == 'null') {
    } else {
      _offerList =
          offers.map<OfferModel>((json) => OfferModel.fromJson(json)).toList();
      if (_offerList.length > 0) {
        setState(() {
          applyOfferEnable = true;
        });
      }
    }

    if (_list.length > 0) {
      setState(() {
        dataFound = true;
        mainPrice = payment_detail['total_discounted_price'].toString();
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
              _list[0].currency.toString() +
                  " " +
                  payment_detail['total_discount'].toString(),
              style: TextStyle(),
              textAlign: TextAlign.end,
            )),
      ],
    );
  }

  priceItem(_list, index) {
    var itemQty = double.parse(_list[index].qty.toString().replaceAll(",", ""));
    var itemPrice =
        double.parse(_list[index].offfer_price.toString().replaceAll(",", ""));
    var totalPrice = itemQty * itemPrice;
    double pi = totalPrice;
    var val = pi.toStringAsFixed(2);
    return Text(
      _list[index].currency.toString() + " " + val.toString(),
      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      textAlign: TextAlign.start,
    );
  }

  Future<void> setCartItem(totalItems) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (totalItems.toString() == 'null') {
      prefs.setString('cart_qty', '0');
    } else {
      prefs.setString('cart_qty', totalItems.toString());
    }
  }

  checkoutBtn(context) async {
    if (selectedRadio == 1) {
      if (paymentTypeRadio == 1) {
        walletPayment();
      } else {
        paymentStoreCheckShop();
      }
    } else {
      paymentShop();
    }
  }

  // this function is for submit cashtoken value and user detail.
  void submitCashTokenData() async {
    if (isAuthToken) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var userId = prefs.getString('id');
      var mobile = prefs.getString('phone');
      var name = prefs.getString('full_name');
      Random random = new Random();
      int randomNumber = random.nextInt(1000);
      var params = {
        "commodity": "cashtoken",
        "batchId": "batch$randomNumber",
        "profile": 'default',
        "recipients": [
          {
            "recipient": "$mobile",
            "value": 2,
            "giftId": "gift$userId",
          }
        ]
      };
      try {
        var response = await http.post(
          Uri.parse('https://api-sandbox.cashtoken.africa/v2/gifting/submit'),
          body: json.encode(params),
          headers: {
            'Content-Type': 'application/json',
            'X-Country-Id': 'NG',
            "Accept-Language": allTranslations.locale.toString(),
            'Authorization': 'Bearer $authToken',
          },
        );
        if (response.statusCode == 200) {}
      } catch (e) {}
    }
  }

  discountCheck() {
    SizedBox sizedBox = SizedBox(
      height: 10.0,
    );
    var discount = payment_detail['total_discount'].toString();
    if (discount == "0.00" || discount == "0") {
      return SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
                flex: 6,
                child: Text(
                  allTranslations.text('ListPrice'),
                )),
            Expanded(
              flex: 3,
              child: Text(
                _list[0].currency.toString() +
                    " " +
                    payment_detail['cart_total'].toString(),
                style: TextStyle(decoration: TextDecoration.lineThrough),
                textAlign: TextAlign.end,
              ),
            )
          ],
        ),
        if (discount != "0")
          Column(
            children: [sizedBox, discountSet()],
          ),
        sizedBox,
      ],
    );
  }

  void walletPayment() async {
    if (mounted)
      setState(() {
        loading = true;
      });
    Map detail = await myWalletModeLoad(context) ?? {};
    if (mounted)
      setState(() {
        loading = false;
      });
    var walletBalance = "";
    if (detail['status'] == "200") {
      var authPinCode = detail['record'][0]['auth_pin_code'];
      walletBalance = detail['record'][0]['wallet_balance'].toString();
      var result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => otpDialog(pin: authPinCode),
        ),
      );
      if (result.toString() != "null") {
        if (selectedRadio == 1) {
          if (paymentTypeRadio == 1) {
            if (walletBalance == "" || walletBalance == "null") {
              _showToast(allTranslations.text("please_setup_your_wallet"));
            } else {
              var walletBalanceData = double.parse(walletBalance);
              var cardTotal =
                  double.parse(mainPrice.toString().replaceAll(",", ""));
              if (cardTotal > walletBalanceData) {
                _showToast(allTranslations.text("insufficient_amount"));
              } else {
                walletpaymentStoreCheckShop();
              }
            }
          } else {
            paymentStoreCheckShop();
          }
        } else {
          paymentShop();
        }
      }
    }
  }

  void walletCheck(paymentWithWallet) {
    if (mounted)
      setState(() {
        if (paymentWithWallet.toString() == "true") {
          walletEnable = true;
          paymentTypeRadio = 1;
        } else {
          walletEnable = false;
          paymentTypeRadio = 2;
        }
      });
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
