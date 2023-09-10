import 'dart:async';

import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/screens/authentication/splash.dart';
import 'package:avauserapp/screens/home/askForPermissionBeacon.dart';
import 'package:avauserapp/screens/profile/Profile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/language/languageSelected.dart';

class SettingApplication extends StatefulWidget {
  @override
  _SettingApplication createState() => _SettingApplication();
}

class _SettingApplication extends State<SettingApplication> {
  var dataLoad = false;
  var STORES = "";
  Map? myLang;
  bool isSwitchedDis = true;
  bool isSwzitchedNotifi = true;
  String? notificationmode;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myLangGet();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(
          allTranslations.text('Setting'),
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
            // notification(),
            resetProfile(),
            changePassword(),
            // beaconEnable(),
            inputLanguage(),
            // transactionPin(),
          ],
        ),
      ),
    );
  }

  Future<void> myLangGet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map myLangData = await langTxt(context);
    setState(() {
      myLang = myLangData;
      STORES = myLang!['STORES'];
      dataLoad = true;
      notificationmode = prefs.getString('notificationmode').toString();
      if (notificationmode == "1") {
        isSwzitchedNotifi = true;
      } else {
        isSwzitchedNotifi = false;
      }
    });
    var check = myLangData['email'];
  }

  spaceHeight() {
    return SizedBox(height: 10.0);
  }

  notification() {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Container(
          child: Card(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Expanded(
                  flex: 9,
                  child: Text(
                    allTranslations.text('NotificationTxt'),
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  )),
              Expanded(
                flex: 2,
                child: Container(
                  child: Switch(
                    value: isSwzitchedNotifi,
                    onChanged: (value) {
                      myNotificationModeUpdate(context);
                      setState(() {
                        isSwzitchedNotifi = value;
                      });
                    },
                    activeTrackColor: Colors.black12,
                    activeColor: Colors.blueAccent,
                  ),
                ),
              )
            ],
          ),
        ),
      )),
    );
  }

  resetProfile() {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: Container(
            child: Card(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
            child: Row(
              children: <Widget>[
                Expanded(
                    flex: 9,
                    child: Text(
                      allTranslations.text('resetProfile'),
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    )),
              ],
            ),
          ),
        )),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileDetail()),
        );
      },
    );
  }

  changePassword() {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Container(
          child: Card(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
          child: Row(
            children: <Widget>[
              Expanded(
                  flex: 9,
                  child: Text(
                    allTranslations.text('changePassword'),
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  )),
            ],
          ),
        ),
      )),
    );
  }

  inputLanguage() {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: GestureDetector(
        child: Container(
            child: Card(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
            child: Row(
              children: <Widget>[
                Expanded(
                    flex: 9,
                    child: Text(
                      allTranslations.text('inputLanguage'),
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    )),
              ],
            ),
          ),
        )),
        onTap: () {
          _changeLanguage();
        },
      ),
    );
  }

  transactionPin() {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Container(
          child: Card(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
          child: Row(
            children: <Widget>[
              Expanded(
                  flex: 9,
                  child: Text(
                    allTranslations.text('TransactionPin'),
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  )),
            ],
          ),
        ),
      )),
    );
  }

  beaconEnable() {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: Container(
            child: Card(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
            child: Row(
              children: <Widget>[
                Expanded(
                    flex: 9,
                    child: Text(
                      allTranslations.text('BeaconEnable'),
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    )),
              ],
            ),
          ),
        )),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BeaconPermission()),
        );
      },
    );
  }

  Future<bool> _changeLanguage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(allTranslations.text('Are_you_sure')),
          content: Text(allTranslations.text('ChangeAppMessage')),
          actions: <Widget>[
            MaterialButton(
              elevation: 0.0,
              child: Text(
                'French',
                style: TextStyle(color: AppColours.appTheme),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
                saveLanguage('fr');
              },
            ),
            MaterialButton(
              elevation: 0.0,
              child: Text(
                'English',
                style: TextStyle(color: AppColours.appTheme),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
                saveLanguage('en');
              },
            )
          ],
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0)),
        );
      },
    );
    return Future.value(false);
  }

  void saveLanguage(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("language", language);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SplashScreen()));
  }

  Future<void> myNotificationModeUpdate(BuildContext context) async {
/*    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map decoded = jsonDecode(
        await getApiDataRequest('notificationModeUrl', context));
    String status = decoded['status'];
    String message = decoded['message'];
    if (status == success_status) {
    String mode = decoded['mode'];
    prefs.setString('notificationmode', mode);
    } else if (status == unauthorized_status) {
    await checkLoginStatus(context);
    } else if (status == "408") {
    Map decoded = jsonDecode(await apiRefreshRequest(context));
    myNotificationModeUpdate(context);
    } else {
    showToast(message);
    }*/
  }
}
