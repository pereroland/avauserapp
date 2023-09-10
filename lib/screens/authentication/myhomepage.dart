import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/language/allTransactions.dart';
import 'package:avauserapp/components/permission.dart';
import 'package:avauserapp/screens/authentication/login.dart';
import 'package:avauserapp/screens/authentication/registerStepOne.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';


class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/splash.jpg'),
            const SizedBox(height: 10),
            SizedBox(
              width: 300,
              height: 60,
              child: MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: const BorderSide(color: AppColours.appTheme)),
                onPressed: () async {
                  var permission = await requestPermission(
                      "Location", Permission.locationWhenInUse, context);
                  if (permission) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginRoute()),
                    );
                  }
                },
                color: AppColours.appTheme,
                textColor: Colors.white,
                child: Text(allTranslations.text('Login').toUpperCase(),
                    style: const TextStyle(fontSize: 20, fontFamily: 'Montaga')),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 300,
              height: 60,
              child: MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: const BorderSide(color: AppColours.appTheme)),
                color: Colors.white,
                textColor: Colors.black,
                padding: const EdgeInsets.all(8.0),
                onPressed: () async {
                  var permission = await requestPermission(
                      "Location", Permission.location, context);
                  if (permission) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  }
                },
                child: Text(
                  allTranslations.text('Register').toUpperCase(),
                  style: const TextStyle(fontSize: 20.0, fontFamily: 'Montaga'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
