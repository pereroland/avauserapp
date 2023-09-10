import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/shimmerEffects/sizeImageShimmer.dart';
import 'package:avauserapp/screens/home/baseTabClass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../components/language/languageSelected.dart';

class CompletePayment extends StatefulWidget {
  CompletePayment({Key? key, this.paymentRecord}) : super(key: key);
  var paymentRecord;

  @override
  _CompletePayment createState() => _CompletePayment();
}

class _CompletePayment extends State<CompletePayment> {
  var dataLoad = false;
  Map? myLang;
  int? selectedRadio;

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
    return WillPopScope(
        onWillPop: () async {
          setBackData();
          return Future.value(false);
        },
        child: new Scaffold(
          bottomNavigationBar: shopContinue(),
          appBar: AppBar(
            elevation: 0.0,
            iconTheme: IconThemeData(color: Colors.black),
            centerTitle: true,
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  setBackData();
                }),
            backgroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ItemDetail(),
              ],
            ),
          ),
        ));
  }

  Future<void> myLangGet() async {
    Map myLangData = await langTxt(context);
    setState(() {
      myLang = myLangData;
      dataLoad = true;
    });
    var check = myLangData['email'];
  }

  ItemDetail() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          successText(),
          spaceHeight(),
          Image.asset(
            "assets/orderconfirm.webp",
            height: MediaQuery.of(context).size.height / 3,
          ),
          spaceHeight(),
          spaceHeight(),
          summaryDetail(),
          spaceHeight(),
          spaceHeight(),
          shippingDetailDetail(),
          spaceHeight(),
          spaceHeight(),
          // itemList(),
          // spaceHeight(),
          // spaceHeight(),
          paymentDetail(),
          spaceHeight(),
          spaceHeight(),
        ],
      ),
    );
  }

  spaceHeight() {
    return SizedBox(height: 10.0);
  }

  applyOffers() {
    return Card(
        child: Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(10.0),
      child: Text(
        allTranslations.text('Applyoffer'),
        style: TextStyle(
            color: Colors.blue, fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
    ));
  }

  successText() {
    return Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Text(
              allTranslations.text('Congratulations'),
              style: TextStyle(fontSize: 21.0),
            ),
            spaceHeight(),
            Text(
              allTranslations.text("YourOrderHasBeenSuccessfullyPlaced"),
              style: TextStyle(fontSize: 18.0),
            )
          ],
        ));
  }

  summaryDetail() {
    return Padding(
        padding: EdgeInsets.all(0.0),
        child: new Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              borderRadius: new BorderRadius.circular(10.0),
              border: Border.all(width: 0.5, color: Colors.black),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  allTranslations.text('SUMMARY'),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                spaceHeight(),
                spaceHeight(),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Text(
                        allTranslations.text('Order') + " # : ",
                        style: TextStyle(),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        widget.paymentRecord['booking_id'].toString(),
                        style: TextStyle(),
                      ),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Text(
                        allTranslations.text('added_on') + " : ",
                        style: TextStyle(),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        widget.paymentRecord['added_on'].toString(),
                        style: TextStyle(),
                      ),
                    )
                  ],
                ),
                spaceHeight(),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Text(
                        allTranslations.text('OrderTotal') + " : ",
                        style: TextStyle(),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        widget.paymentRecord['currency_sign'].toString() +
                            " " +
                            widget.paymentRecord['discounted_amount']
                                .toString(),
                        style: TextStyle(),
                      ),
                    )
                  ],
                ),
                spaceHeight(),
              ],
            )));
  }

  shippingDetailDetail() {
    return Padding(
        padding: EdgeInsets.all(0.0),
        child: new Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              borderRadius: new BorderRadius.circular(10.0),
              border: Border.all(width: 0.5, color: Colors.black),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  allTranslations.text('ShippingAddress'),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                spaceHeight(),
                spaceHeight(),
                addressSet(widget.paymentRecord),
              ],
            )));
  }

  itemList() {
    return Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Text(
                    allTranslations.text('ITEMS'),
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    allTranslations.text('QTY'),
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    allTranslations.text('PRICE'),
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
            spaceHeight(),
            Divider(
              thickness: 0.5,
              color: Colors.black,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: CachedNetworkImage(
                      imageUrl:
                          'https://images.unsplash.com/photo-1483985988355-763728e1935b?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60',
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          sizeImageShimmer(context, 20, 20.0),
                      errorWidget: (context, url, error) => Image.asset(
                        "assets/nodata.webp",
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    "1",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    "\$30",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
            Divider(
              thickness: 0.5,
              color: Colors.black,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: CachedNetworkImage(
                      imageUrl:
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTFzogPZ2STZhoWqT10bk2R1cknBOxT5HCDJEs3cTCvt5hF3dLX&usqp=CAU',
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          sizeImageShimmer(context, 20, 20.0),
                      errorWidget: (context, url, error) => Image.asset(
                        "assets/nodata.webp",
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    "1",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    "\$30",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ],
        ));
  }

  paymentDetail() {
    return new Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(10.0),
          border: Border.all(width: 0.5, color: Colors.black),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              allTranslations.text('PriceDetails'),
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            spaceHeight(),
            spaceHeight(),
            itemsShow(widget.paymentRecord['items'] as List),
            spaceHeight(),
            Divider(
              height: 2.0,
              color: AppColours.blacklightLineColour,
            ),
            spaceHeight(),
            /*ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: _list.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                      padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                      child: listItems(_list, index, context));
                }),*/

            checkDiscount(),
            spaceHeight(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: Text(
                      allTranslations.text('Total'),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                Expanded(
                  flex: 1,
                  child: Text(
                      widget.paymentRecord['currency_sign'] +
                          " " +
                          widget.paymentRecord['discounted_amount'],
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.red)),
                )
              ],
            ),
          ],
        ));
  }

  addressSet(paymentRecord) {
    var address;
    if (paymentRecord['address_type'].toString() == "1") {
      address = "Store Pickup";
    } else {
      address = paymentRecord['customer_address'].toString();
    }
    return Text(address);
  }

  shopContinue() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Hero(
          tag: 'continue',
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
                    onPressed: () async {
                      setBackData();
                    },
                    child: Text(
                      allTranslations.text('Continue'),
                      style: TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  void setBackData() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TabBarController(0)),
    );
  }

  itemsShow(paymentRecord) {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: paymentRecord.length,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
              padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
              child: listItems(paymentRecord, index, context));
        });
  }

  listItems(paymentRecord, int index, BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(paymentRecord[index]['quantity'].toString() +
              " x " +
              paymentRecord[index]['product_name'].toString()),
        ),
        Expanded(
          flex: 1,
          child: Text(widget.paymentRecord['currency_sign'].toString() +
              " " +
              paymentRecord[index]['sub_total'].toString()),
        )
      ],
    );
  }

  checkDiscount() {
    var discount = widget.paymentRecord['total_discount'].toString();
    if (discount != 'null') {
      if (discount == "0" || discount == "0.00") {
        return SizedBox.shrink();
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                    flex: 1, child: Text(allTranslations.text('ListPrice'))),
                Expanded(
                  flex: 1,
                  child: Text(
                      widget.paymentRecord['currency_sign'] +
                          " " +
                          widget.paymentRecord['sub_total'],
                      // child: Text(widget.paymentRecord['cart'].toString(),
                      style: TextStyle(decoration: TextDecoration.lineThrough)),
                )
              ],
            ),
            spaceHeight(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: Text(
                      allTranslations.text('Discount'),
                    )),
                Expanded(
                    flex: 1,
                    child: Text(
                        widget.paymentRecord['currency_sign'] +
                            " " +
                            widget.paymentRecord['total_discount'],
                        style: TextStyle())),
              ],
            )
          ],
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }
}
