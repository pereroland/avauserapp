import 'dart:convert';

import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/email_validator.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../constants.dart' as Constants;
import 'otp.dart';

class ForgotRoute extends StatefulWidget {
  ForgotState createState() => ForgotState();
}

class ForgotState extends State<ForgotRoute> {
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30.0, 130.0, 30.0, 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                allTranslations.text('forgotpassword'),
                style: const TextStyle(fontSize: 30.0, fontFamily: 'Montaga'),
              ),
              const SizedBox(height: 30),
              Text(
                allTranslations.text('forgotpasswordMessage'),
                style: const TextStyle(fontSize: 20.0, fontFamily: 'Montserrat'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(0),
                  enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  labelText: allTranslations.text('Email_Address'),
                  labelStyle: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 15,
                      fontFamily: 'Montserrat'),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Padding(
                      padding: const EdgeInsets.only(bottom: 100.0),
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          child: MaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                side:
                                const BorderSide(color: Constants.PrimaryColor)),
                            onPressed: () {
                              checkValidation();
                            },
                            color: Constants.PrimaryColor,
                            textColor: Colors.white,
                            child: Text(allTranslations.text('Proceed'),
                                style: const TextStyle(
                                    fontSize: 20, fontFamily: 'Montaga')),
                          ))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _ackAlert(BuildContext context, userId, userType) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(30, 60, 30, 20),
          content: Text(
            allTranslations.text('otpMatchMessage'),
            style: const TextStyle(fontSize: 18, fontFamily: 'Montserrat'),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text(
                allTranslations.text('OK'),
                style: const TextStyle(fontSize: 20, fontFamily: 'Montserrat'),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          OtpRoute(user_id: userId, user_type: userType)),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> checkValidation() async {
    var email = emailController.text;
    var callUserLoginCheck = await internetConnectionState();
    final bool emailValid = EmailValidator.validate(email);
    if (callUserLoginCheck == true) {
      if (emailController.text == "") {
        _showToast("please enter email");
      } else if (emailValid == false) {
        _showToast("please enter vaild email");
      } else {
        permissionCheckUser();
      }
    }
  }

  void permissionCheckUser() {
    apiCalling();
  }

  Future<void> apiCalling() async {
    Map map = {"email": emailController.text};
    Map decoded = jsonDecode(
        await apiAuthentificationRequest(forgotpasswordUrl, map, context));
    String status = decoded['status'];
    String message = decoded['message'];
    if (status == success_status) {
      var record = decoded['record'];
      var userId = record['user_id'];
      var userType = record['user_type'];
      _ackAlert(context, userId, userType);
    } else if (status == already_login_status) {
      _showToast(message);
    } else if (status == data_not_found_status) {
      _showToast(message);
    } else {
      _showToast(message);
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
