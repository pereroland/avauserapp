import 'dart:convert';
import 'dart:io';

import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/email_validator.dart';
import 'package:avauserapp/components/fingerprint/classesAuth.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/storeData.dart';
import 'package:avauserapp/screens/authentication/myhomepage.dart';
import 'package:avauserapp/screens/home/askForPermissionBeacon.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:avauserapp/constants.dart' as Constants;
import 'package:avauserapp/screens/home/baseTabClass.dart';
import 'forgot.dart';

class LoginRoute extends StatefulWidget {
  const LoginRoute({Key? key}) : super(key: key);

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<LoginRoute> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Map? myLang;
  var loading = false;
  bool _passwordVisible = false;

  // final LocalAuthentication auth = LocalAuthentication();
  var fingerPrintTxt = "Login with Fingerprint";
  var IconSet = "assets/fingerprint.png";
  bool supportsAuthenticated = false;
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    dataCheck();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: MaterialButton(
          color: Colors.transparent,
          elevation: 0.0,
          textColor: Colors.black,
          onPressed: () {
            Navigator.push(
              context,
              //MaterialPageRoute(builder: (context) => RegisterPage()),
              MaterialPageRoute(builder: (context) => MyHomePage()),
            );
          },
          child: Text(allTranslations.text('Not_a_member_Sign_up'),
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Montaga',
              )),
        ),
      ),
      body: Center(
        //child: ConstrainedBox(
        //constraints: BoxConstraints(),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: Text(
                  allTranslations.text('Login'),
                  style: const TextStyle(fontSize: 35.0, fontFamily: 'Montaga'),
                ),
              ),
              const SizedBox(height: 40),
              emailField(),
              const SizedBox(height: 20),
              passwordField(),
              const SizedBox(height: 10),
              rememberAndForgotPasswordField(),
              const SizedBox(height: 40),
              LoginBtn(),
              const SizedBox(height: 10),
              orTxt(),
              const SizedBox(height: 10),
              facebookLoginBtn(),
              const SizedBox(height: 10),
              supportsAuthenticated
                  ? loginWithFingerprintBtnTx()
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
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

  emailField() {
    return Container(
      margin: const EdgeInsets.only(left: 30.0, right: 30.0),
      child: TextFormField(
        controller: emailController,
        maxLines: 1,
        minLines: 1,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(0),
          enabledBorder:
          const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          labelText: allTranslations.text('Email_id_Mobile_Number'),
          labelStyle: const TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 15,
              fontFamily: 'Montserrat'),
        ),
      ),
    );
  }

  passwordField() {
    return Container(
      margin: const EdgeInsets.only(left: 30.0, right: 30.0),
      child: TextFormField(
        controller: passwordController,
        maxLines: 1,
        minLines: 1,
        obscureText: !_passwordVisible,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(0),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            labelText: allTranslations.text('password'),
            labelStyle: const TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 15,
              fontFamily: 'Montserrat',
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: Theme.of(context).primaryColorDark,
              ),
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            )),
      ),
    );
  }

  rememberAndForgotPasswordField() {
    return Container(
      margin: const EdgeInsets.only(left: 25.0, right: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              CheckboxWidget(),
              Text(allTranslations.text('rememberMe'),
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
          MaterialButton(
            textColor: Colors.black,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ForgotRoute()),
              );
            },
            child: Text(allTranslations.text('forgotpasswordQuestion'),
                style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  LoginBtn() {
    return Container(
      margin: const EdgeInsets.only(left: 25.0, right: 25.0),
      width: MediaQuery.of(context).size.width,
      height: 50,
      // child: Center(
      child: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(color: Constants.PrimaryColor)),
        onPressed: () {
          if (!loading) checkValidateApi();
        },
        color: Constants.PrimaryColor,
        textColor: Colors.white,
        child: loading
            ? const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        )
            : Text(allTranslations.text('Login'),
            style: const TextStyle(fontSize: 20, fontFamily: 'Montaga')),
      ),
      //  ),
    );
  }

  checkValidateApi() async {
    bool validated = await checkValidation();
    if (validated != false) {
      permissionCheckUser('');
    }
  }

  orTxt() {
    return Center(
      child: Text(
        allTranslations.text('or'),
        style: const TextStyle(fontSize: 20, fontFamily: 'Montaga'),
      ),
    );
  }

  facebookLoginBtn() {
    return Container(
      margin: const EdgeInsets.only(left: 25.0, right: 25.0),
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(color: Colors.blue)),
        onPressed: () {},
        color: Colors.blue,
        textColor: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const ImageIcon(
              AssetImage("assets/facebook.png"),
              color: Colors.white,
            ),
            Container(
              width: 1,
              height: 30,
              color: const Color(0xFFE5E5E5),
            ),
            Text(allTranslations.text('Connect_with_Facebook'),
                style: const TextStyle(fontSize: 20, fontFamily: 'Montaga')),
          ],
        ),
      ),
    );
  }

  loginWithFingerprintBtnTx() {
    return Container(
      margin: const EdgeInsets.only(left: 25.0, right: 25.0),
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: MaterialButton(
        textColor: Colors.blue,
        onPressed: () async {
          try {
            final result = await authenticated();
            if (result.toString() == "null" || !result) {
              fingerPrintCheck(emailController.text, passwordController.text);
            } else {
              permissionCheckUser('');
            }
          } catch (error) {
            _showToast(error.toString());
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const ImageIcon(
              AssetImage("assets/fingerprint.png"),
              color: Colors.blue,
            ),
            const SizedBox(width: 10),
            Text(allTranslations.text('Login_with_Fingerprint'),
                style: const TextStyle(fontSize: 20, fontFamily: 'Montaga')),
          ],
        ),
      ),
    );
  }

  void permissionCheckUser(statusData) {
    apiCalling(statusData);
  }

  Future<void> apiCalling(statusData) async {
    saveEmailPass(isChecked);
    setState(() {
      loading = true;
    });
    var osType = "", device_name = "", model = "";
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      osType = "Android";
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      device_name = androidInfo.model.toString();
      model = androidInfo.model.toString();
    } else if (Platform.isIOS) {
      osType = "iOS";
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      device_name = iosInfo.utsname.machine;
      model = iosInfo.model.toString();
    } else {
      osType = Platform.operatingSystem;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fcmToken = "";
    fcmToken = prefs.getString('fcm_token');
    String udid = await FlutterUdid.udid;
    final String currentTimeZone =
    await FlutterNativeTimezone.getLocalTimezone();
    if (fcmToken == null || fcmToken == '') {
      fcmToken = await FirebaseMessaging.instance.getToken();
      setState(() {
        prefs.setString('fcm_token', fcmToken!);
      });
    }
    Map map = {
      "email_or_phone": emailController.text.trim(),
      "password": passwordController.text.trim(),
      "fcm_token": fcmToken,
      "os_type": osType,
      "device_name": device_name,
      "time_zone": currentTimeZone,
      "device_id": udid,
      "device_model": model,
    };
    try {
      await FirebaseMessaging.instance.requestPermission();
      Map decoded =
      jsonDecode(await apiAuthentificationRequest(signinUrl, map, context));
      String status = decoded['status'];
      String message = decoded['message'];
      if (status == success_status) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('userLogin', "true");
        var record = decoded['record'];
        var id = record['id'];
        var full_name = record['full_name'];
        var email = record['email'];
        var city = record['city'];
        var phone = record['phone'];
        var gender = record['gender'];
        var dob = record['dob'];
        var country = record['country'];
        var state = record['state'];
        var user_type = record['user_type'];
        var status = record['status'];
        var language = record['language'];
        var time_zone = record['time_zone'];
        var country_code = record['country_code'];
        var email_verify = record['email_verify'];
        var admin_verify = record['admin_verify'];
        var image = record['profile'];
        prefs.setString('id', id);
        SharedPrefUtils.setString('id', id);
        prefs.setString('full_name', full_name);
        prefs.setString('country_code', country_code);
        prefs.setString('email', email);
        prefs.setString('phone', phone);
        prefs.setString('gender', gender);
        prefs.setString('dob', dob);
        prefs.setString('country', country);
        prefs.setString('state', state);
        prefs.setString('user_type', user_type);
        prefs.setString('status', status);
        prefs.setString('language', language);
        prefs.setString('time_zone', time_zone);
        prefs.setString('email_verify', email_verify);
        prefs.setString('admin_verify', admin_verify);
        prefs.setString('image', image);
        prefs.setString('city', city);
        if (statusData == "save") {
          statusBiometricSave(statusData, BeaconPermission);
        } else {
          openToNavigateLogin();
        }
      } else if (status == already_login_status) {
        _showToast(message);
      } else if (status == data_not_found_status) {
        _showToast(message);
      } else {
        _showToast(message);
      }
      setState(() {
        loading = false;
      });
    } catch (_) {
      setState(() {
        _showToast("Exception $_");
        loading = false;
      });
    }
  }

  Future<bool> fingerPrintCheck(email, password) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            allTranslations.text('Are_you_sure'),
          ),
          content: Text(
            allTranslations.text('fingerprint_and_face_Id'),
          ),
          actions: <Widget>[
            MaterialButton(
              elevation: 0.0,
              child: Text(
                allTranslations.text('yes'),
                style: const TextStyle(color: AppColours.appTheme),
              ),
              onPressed: () async {
                Navigator.of(context).pop(false);
                bool validated = await checkValidation();
                if (validated != false) {
                  permissionCheckUser("save");
                }
              },
            ),
            MaterialButton(
              elevation: 0.0,
              child: Text(
                allTranslations.text('no'),
                style: const TextStyle(color: AppColours.appTheme),
              ),
              onPressed: () async {
                Navigator.of(context).pop(false);
              },
            )
          ],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)),
        );
      },
    );
    return Future.value(false);
  }

  Future<bool> checkValidation() async {
    var email = emailController.text.trim();
    var callUserLoginCheck = await internetConnectionState();
    final bool emailValid = EmailValidator.validate(email);
    if (callUserLoginCheck == true) {
      if (emailController.text == "") {
        _showToast(allTranslations.text("please_enter_email"));
      } else if (emailValid == false) {
        _showToast(allTranslations.text("please_enter_vaild_email"));
      } else if (passwordController.text.trim() == "") {
        _showToast(allTranslations.text("please_enter_password"));
      } else {
        return true;
      }
    }
    return false;
  }

  Future<void> statusBiometricSave(statusData, controller) async {
    try {
      Map mapCredential = {
        "email": emailController.text.trim().toString(),
        "passowrd": passwordController.text.trim().toString()
      };
      var data = json.encode(mapCredential);
      bool response = await authenticated();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (response) prefs.setString('biometric', "Enable");
      openToNavigateLogin();
    } catch (error) {
      _showToast(error.toString());
    }
  }

  Future<void> dataCheck() async {
    var data = await checkForm();
    setState(() {
      if (Platform.isIOS) {
        fingerPrintTxt = "Login with Fingerprint or Face ID";
        IconSet = "assets/fingerprint.png";
      }
    });
    setState(() {
      supportsAuthenticated = data;
    });
    checkAuthSave();
  }

  Future<void> checkAuthSave() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var authSaved = prefs.getString('authSave');
    if (authSaved.toString() == 'true') {
      setState(() {
        emailController.text = prefs.getString('email') ?? "";
        passwordController.text = prefs.getString('pass') ?? "";
        isChecked = true;
      });
    }
  }

  Future<void> saveEmailPass(bool bool) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (bool == true) {
      prefs.setString('authSave', bool.toString());
      prefs.setString('email', emailController.text.toString());
      prefs.setString('pass', passwordController.text.toString());
    } else {
      prefs.setString('authSave', 'false');
    }
  }

  CheckboxWidget() {
    return Transform.scale(
      scale: 1,
      child: Checkbox(
        value: isChecked,
        onChanged: (value) {
          if (value != null) toggleCheckBox(value);
        },
        activeColor: Colors.black,
        checkColor: Colors.white,
        tristate: false,
      ),
    );
  }

  void toggleCheckBox(bool value) {
    if (isChecked == false) {
      setState(() {
        isChecked = true;
      });
    } else {
      setState(() {
        isChecked = false;
      });
    }
  }

  Future<void> openToNavigateLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userInteract = prefs.getString('user_interact');
    if (userInteract == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BeaconPermission()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TabBarController(0)),
      );
    }
  }
}
