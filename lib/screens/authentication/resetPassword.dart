import 'dart:convert';

import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/screens/authentication/login.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../constants.dart' as Constants;

class ResetPage extends StatefulWidget {
  ResetPage({Key? key, this.user_id, this.user_type}) : super(key: key);
  var user_id;
  var user_type;

  ResetPageState createState() => ResetPageState();
}

class ResetPageState extends State<ResetPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();
  var loading = false;

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
                allTranslations.text('Reset_Password'),
                style: const TextStyle(
                    fontSize: 30.0,
                    fontFamily: 'Montaga',
                    color: Constants.PrimaryColor),
              ),
              const SizedBox(height: 40),
              TextFormField(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(0),
                  enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  labelText: allTranslations.text('newpassword'),
                  labelStyle: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 15,
                      fontFamily: 'Montserrat'),
                ),
                validator: (val) {
                  if (val != null) if (val.isEmpty)
                    return allTranslations.text('Please_Enter_Confirm_Password');
                  return null;
                },
                controller: _pass,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(0),
                  enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  labelText: allTranslations.text('confirmpassword'),
                  labelStyle: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 15,
                      fontFamily: 'Montserrat'),
                ),
                validator: (val) {
                  if (val != null) {
                    if (val.isEmpty)
                      return allTranslations
                          .text('Please_Enter_Confirm_Password');
                    if (val != _pass.text)
                      return allTranslations
                          .text('Password_and_confirm_password_feild_mismatch');
                    return null;
                  } else {
                    return allTranslations
                        .text('Please_Enter_Confirm_Password');
                  }
                },
                controller: _confirmPass,
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
                              if (!loading) validationCheck();
                            },
                            color: Constants.PrimaryColor,
                            textColor: Colors.white,
                            child: loading
                                ? const CircularProgressIndicator(
                              valueColor:
                              AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            )
                                : Text(allTranslations.text('Reset'),
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

  Future<void> validationCheck() async {
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck == true) {
      callUserResetPassword();
    }
  }

  void callUserResetPassword() async {
    setState(() {
      loading = true;
    });
    Map map = {
      "user_id": widget.user_id,
      "password": _pass.text,
      "con_password": _confirmPass.text,
    };
    Map decoded = jsonDecode(
        await apiAuthentificationRequest(resetPasswordUrl, map, context));
    String status = decoded['status'];
    String message = decoded['message'];

    if (status == success_status) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginRoute()),
              (route) => false);
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // prefs.setString('userLogin', "true");
      // Navigator.pushReplacement(context,
      //     MaterialPageRoute(builder: (context) => TabBarController(0)));
    } else if (status == already_login_status) {
      _showToast(message);
    } else {
      _showToast(message);
    }
    setState(() {
      loading = false;
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
