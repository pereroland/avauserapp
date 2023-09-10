import 'dart:convert';

import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ApplyCupon extends StatefulWidget {
  ApplyCupon({Key? key, this.listCupon}) : super(key: key);
  var listCupon;

  @override
  _ApplyCuponState createState() => _ApplyCuponState();
}

class _ApplyCuponState extends State<ApplyCupon> {
  var offerCancel = true;
  TextEditingController offerTextController = TextEditingController();
  var applyOffer = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          allTranslations.text('COUPONS'),
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /*  Padding(
              padding: EdgeInsets.all(5.0),
              child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColours.blacklightLineColour,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: TextFormField(
                            controller: offerTextController,
                            cursorColor: Colors.black,
                            onChanged: (text) {
                              if (text.trim().toString() == '') {
                                setState(() {
                                  offerCancel = true;
                                });
                              } else {
                                setState(() {
                                  offerCancel = false;
                                });
                              }
                            },
                            decoration: new InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.only(
                                    left: 15, bottom: 11, top: 11, right: 15),
                                hintText: 'Enter Coupon'),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: MaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                side: BorderSide(
                                    color: offerCancel
                                        ? AppColours.redColour
                                        : AppColours.appTheme)),
                            color: Colors.white,
                            textColor: offerCancel
                                ? AppColours.redColour
                                : AppColours.appTheme,
                            padding: EdgeInsets.all(8.0),
                            onPressed: () {
                              offerActionSet();
                            },
                            child: offerCancel
                                ? Text(
                                    "Cancel".toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 14.0,
                                    ),
                                  )
                                : Text(
                                    "Apply".toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 14.0,
                                    ),
                                  ),
                          ),
                        )
                      ],
                    ),
                  )),
            ),*/
            ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.listCupon.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return listItems(widget.listCupon, index, context);
                }),
          ],
        ),
        scrollDirection: Axis.vertical,
      ),
    );
  }

/*  offerActionSet() {
    if (offerCancel)
      setState(() {
        applyOffer = true;
      });
    else
      applyCuponCall();
  }*/

  Future<void> applyCuponCall(listCupon, int index) async {
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck == true) {
      Map map = {"offer_id": listCupon[index].offerId, "status": 'true'};
      Map decoded = jsonDecode(await apiRequestMainPage(applyCoupanUrl, map));
      String status = decoded['status'];
      String message = decoded['message'];
      if (status == success_status) {
        var record = decoded['record'];
        Navigator.pop(context, record);
      } else if (status == unauthorized_status) {
        await checkLoginStatus(context);
      } else if (status == already_login_status) {
      } else if (status == data_not_found_status) {
        _showToast(message);
      } else if (status == expire_token_status) {
        Map decoded = jsonDecode(await apiRefreshRequest(context));
        applyCuponCall(listCupon, index);
      } else {
        _showToast(message);
      }
    }
  }

  Widget listItems(listCupon, int index, BuildContext context) {
    return Container(
      height: 100,
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Container(
            color: AppColours.whiteColour,
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(listCupon[index].code),
                        priceSet(listCupon, index),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: BorderSide(color: AppColours.appTheme)),
                      color: Colors.white,
                      textColor: AppColours.appTheme,
                      padding: EdgeInsets.all(8.0),
                      onPressed: () {
                        applyCuponCall(listCupon, index);
                      },
                      child: Text(
                        allTranslations.text('Apply').toUpperCase(),
                        style: TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }

  priceSet(_list, index) {
    if (_list[index].amount_unit.toString() == '1') {
      return Text(
        _list[index].offer_amount.toString() + " % Off",
        style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: AppColours.appTheme),
        textAlign: TextAlign.start,
      );
    } else {
      return Text(
        _list[index].amount_currency.toString() +
            " " +
            _list[index].offer_amount.toString() +
            " off",
        style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: AppColours.appTheme),
        textAlign: TextAlign.start,
      );
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
}
