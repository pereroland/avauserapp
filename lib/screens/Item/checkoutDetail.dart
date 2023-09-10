import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/shimmerEffects/sizeImageShimmer.dart';
import 'package:flutter/material.dart';

import '../../components/language/languageSelected.dart';
import 'detailPayment.dart';

class CheckoutDetail extends StatefulWidget {
  @override
  _CheckoutDetail createState() => _CheckoutDetail();
}

class _CheckoutDetail extends State<CheckoutDetail> {
  var dataLoad = false;
  var STORES = "";
  Map? myLang;

  @override
  void initState() {
    super.initState();
    myLangGet();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      bottomNavigationBar: addtToCartButton(),
      appBar: AppBar(
        title: Text(
          allTranslations.text('Checkout'),
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CachedNetworkImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1483985988355-763728e1935b?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60',
              fit: BoxFit.contain,
              placeholder: (context, url) => sizeImageShimmer(
                  context, MediaQuery.of(context).size.width, 340.0),
              errorWidget: (context, url, error) => Image.asset(
                "assets/nodata.webp",
                fit: BoxFit.fill,
              ),
              height: 340.0,
              width: MediaQuery.of(context).size.width,
            ),
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
      STORES = myLang!['STORES'];
      dataLoad = true;
    });
    var check = myLangData['email'];
  }

  itemNameAndPrice() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 5,
          child: Text(
            "sunglasses",
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            "\$ 30",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
        )
      ],
    );
  }

  ItemDetail() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          itemNameAndPrice(),
          spaceHeight(),
          Text(
              "Flutter is Google’s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.Fast DevelopmentPaint your app to life in milliseconds with Stateful Hot Reload. Use a rich set of fully-customizable widgets to build native interfaces in minutes."),
          spaceHeight(),
          shareBox(),
          spaceHeight(),
        ],
      ),
    );
  }

  spaceHeight() {
    return SizedBox(height: 30.0);
  }

  shareBox() {
    return Padding(
        padding: EdgeInsets.all(0.0),
        child: new Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                borderRadius: new BorderRadius.circular(10.0),
                border: Border.all(width: 0.5, color: Colors.black)),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(allTranslations.text('Likedthisproduct')),
                      Text(allTranslations.text('Sharewithyourfriend')),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    allTranslations.text('Share'),
                    style: TextStyle(color: Colors.blue),
                  ),
                )
              ],
            )));
  }

  addtToCartButton() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Hero(
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
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PaymentDetail(
                                  campaignData: {},
                                )),
                      );
                    },
                    child: Text(
                      allTranslations.text('AddToCart'),
                      style: TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
