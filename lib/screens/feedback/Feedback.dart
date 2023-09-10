import 'dart:async';

import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:flutter/material.dart';

import '../../components/language/languageSelected.dart';

class FeedbackRoute extends StatefulWidget {
  @override
  _Feedback createState() => _Feedback();
}

class _Feedback extends State<FeedbackRoute> {
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
          "Feedback",
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
            spaceHeight(),
            spaceHeight(),
            feedbackText(),
            feedbackBox(),
          ],
        ),
      ),
    );
  }

  feedbackBox() {
    return Padding(
        padding: EdgeInsets.all(10.0),
        child: new Container(
            height: 280,
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                borderRadius: new BorderRadius.circular(10.0),
                border: Border.all(width: 0.5, color: Colors.black)),
            child: TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                hintText: allTranslations.text('WriteYourFeedbackHere'),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
              ),
            )));
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

  spaceHeight() {
    return SizedBox(height: 10.0);
  }

  feedbackText() {
    return Padding(
        padding: EdgeInsets.all(10.0),
        child: Text(
          allTranslations.text('PleaseShareYourfeedbackwithus'),
          style: TextStyle(fontSize: 18.0),
        ));
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
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Send",
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
