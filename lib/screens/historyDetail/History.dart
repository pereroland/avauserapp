import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/resource/resource.dart';
import 'package:avauserapp/components/resource/space.dart';
import 'package:avauserapp/components/shimmerEffects/fullScreenLoadShimmer.dart';
import 'package:avauserapp/components/shimmerEffects/imageloadshimmer.dart';
import 'package:avauserapp/components/shimmerEffects/sizeImageShimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../components/language/languageSelected.dart';
import 'package:avauserapp/components/longLog.dart';

class HistoryDetail extends StatefulWidget {
  @override
  _HistoryDetail createState() => _HistoryDetail();
}

class _HistoryDetail extends State<HistoryDetail> {
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
    return new Scaffold(
//      bottomNavigationBar: addtToCartButton(),
      appBar: AppBar(
        title: Text(
          "History",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ItemDetail(),
          ],
        ),
      ),
    );
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
      dataLoad = true;
    });
    var check = myLangData['email'];
  }

  ItemDetail() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          listItems(),
          listItems(),
        ],
      ),
    );
  }

  spaceHeight() {
    return SizedBox(height: 10.0);
  }

  listItems() {
    return Card(
        child: Padding(
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "London steps women black",
                  style: TextStyle(fontSize: 20.0),
                ),
                spaceHeight(),
                spaceHeight(),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Icon(
                        Icons.brightness_1,
                        color: Colors.green,
                        size: 15.0,
                      ),
                    ),
                    Expanded(
                      flex: 8,
                      child: Text(
                        allTranslations.text('ItemsBuy'),
                        style: TextStyle(color: Colors.black38, fontSize: 14.0),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: CachedNetworkImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1483985988355-763728e1935b?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60',
              fit: BoxFit.cover,
              placeholder: (context, url) => imageShimmer(context, 40.0),
              errorWidget: (context, url, error) => Image.asset(
                "assets/nodata.webp",
                fit: BoxFit.fill,
              ),
              height: 80.0,
              width: 80,
            ),
          )
        ],
      ),
    ));
  }
}
