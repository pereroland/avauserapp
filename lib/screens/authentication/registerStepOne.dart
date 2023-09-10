import 'dart:convert';
import 'dart:io' show Platform;

import 'package:country_code_picker/country_code_picker.dart';
import 'package:device_info/device_info.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/email_validator.dart';
import 'package:avauserapp/components/firebaseMessage/FirebaseNotifications.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/Location/CurrentLocation.dart';
import '../home/askForPermissionBeacon.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: MaterialButton(
          textColor: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(allTranslations.text('Already_member_message'),
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Montaga',
              )),
        ),
      ),
      body: Center(
        child: const SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 30.0),
            child: RegisterForm(),
          ),
        ),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _name, _email, _mobile, _password;
  var selectgender = 0;
  var gendarSelected = "Female";
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  String _countrycode = "+225";
  DateTime selectedDate = DateTime.now();
  bool passwordVisible = true;
  String? longitude, latitude;
  var loading = false;

  Future<void> _selectDate(BuildContext context) async {
    var now = new DateTime.now();

    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1),
        lastDate: DateTime(now.year, now.month, now.day));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        _dateOfBirthController.text = pad(selectedDate.day).toString() +
            "-" +
            selectedDate.month.toString() +
            "-" +
            selectedDate.year.toString();
      });
  }

  String pad(n) {
    return (n < 10) ? ('0' + n.toString()) : n.toString();
  }

  String? validateBirthdate(String value) {
    if (value.length == 0)
      return allTranslations.text('EnterBirthDate');
    else
      return null;
  }

  String? validateCity(String value) {
    if (value.length == 0)
      return allTranslations.text('EnterCity');
    else
      return null;
  }

  String? validateCountry(String value) {
    if (value.length == 0)
      return allTranslations.text('EnterCountry');
    else
      return null;
  }

  String? validatePassword(String value) {
    if (value.length <= 5)
      return allTranslations.text('PasswordMustBemoreThan5Charater');
    else
      return null;
  }

  TextEditingController mobileNumberController = TextEditingController();

  void selectRadioState(int? value) {
    setState(() {
      if (value != null) {
        selectgender = value;
      }
      if (value == 0) {
        gendarSelected = "Female";
      } else {
        gendarSelected = "Male";
      }
    });
  }

  String? validateName(String value) {
    if (value.length == 0)
      return allTranslations.text("enter_name");
    else
      return null;
  }

  String? validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern.toString());
    if (!regex.hasMatch(value))
      return allTranslations.text('Please_Enter_Email_Number');
    else
      return null;
  }

  String? validateMobile(String value) {
    if (value.length < 1)
      return allTranslations.text('Please_Enter_Mobile_Number');
    else
      return null;
  }

  void _validateInputs(context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      checkValidation(context);
    }
  }

  Future<void> addressSearch(context) async {
    Map? decoded = await getLocation(context);
    setState(() {
      if (decoded != null) {
        _addressController.text = decoded['shortAddress'].toString();
        latitude = decoded['Latitude'].toString();
        longitude = decoded['Longitude'].toString();
        _countryController.text = decoded['country'].toString();
        _stateController.text = decoded['state'].toString();
        _cityController.text = decoded['city'].toString();
      }
    });
  }

  void apiCallingSecond(String userId) async {
    Map map = {
      "dob": _dateOfBirthController.text,
      "country": _countryController.text,
      "city": _cityController.text,
      "latitude": latitude,
      "longitude": longitude,
      "address": _addressController.text,
      "state": _stateController.text,
      "password": _password,
      "con_password": _confirmPass.text,
      "user_id": userId
    };
    Map decoded = jsonDecode(
        await apiAuthentificationRequest(signupStepTwoUrl, map, context));
    String status = decoded['status'];
    String message = decoded['message'];
    if (status == success_status) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('userLogin', "true");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BeaconPermission()),
      );
    } else if (status == already_login_status) {
      _showToast(message);
    } else if (status == data_not_found_status) {
      _showToast(message);
    } else {
      _showToast(message);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginRoute()),
      );
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    addressSearch(context);
    super.initState();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _confirmPass.dispose();
    _pass.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              allTranslations.text('Signup'),
              style: TextStyle(fontSize: 35.0, fontFamily: 'Montaga'),
            ),
            const SizedBox(height: 40),
            TextFormField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(0),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                labelText: allTranslations.text('Full_Name'),
                labelStyle: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 15,
                    fontFamily: 'Montserrat'),
              ),
              keyboardType: TextInputType.text,
              validator: (d) => validateName(d!),
              onSaved: (String? val) {
                _name = val;
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(0),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                labelText: allTranslations.text('Email_Address'),
                labelStyle: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 15,
                    fontFamily: 'Montserrat'),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (d) => validateEmail(d!),
              onSaved: (String? val) {
                _email = val;
              },
            ),
            SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        CountryCodePicker(
                          onChanged: (CountryCode country) {
                            setState(() {
                              _countrycode = country.dialCode!;
                            });
                          },
                          showFlag: false,
                          initialSelection: _countrycode,
                          showCountryOnly: false,
                          showOnlyCountryWhenClosed: false,
                          alignLeft: false,
                        ),
                        Divider(
                          height: 1.0,
                          thickness: 0.5,
                          color: Colors.black,
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 10.0,
                      ),
                      Container(
                        height: 30.0,
                        child: VerticalDivider(
                          thickness: 0.5,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Divider(
                        height: 1.0,
                        thickness: 0.5,
                        color: Colors.black,
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: TextFormField(
                      controller: mobileNumberController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(0),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        labelText: allTranslations.text('Mobile_Number'),
                        labelStyle: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 15,
                            fontFamily: 'Montserrat'),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (va) => validateMobile(va!),
                      onSaved: (String? val) {
                        if (val != null) _mobile = val;
                      },
                      onChanged: (value) {
                        setState(() {
                          validateMyPhone(value, "phone");
                        });
                      }),
                )
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Radio(
                  value: 0,
                  groupValue: selectgender,
                  onChanged: selectRadioState,
                  activeColor: Colors.black,
                ),
                Text(
                  allTranslations.text('Female'),
                  style: new TextStyle(fontSize: 16.0),
                ),
                new Radio(
                  value: 1,
                  groupValue: selectgender,
                  onChanged: selectRadioState,
                  activeColor: Colors.black,
                ),
                Text(
                  allTranslations.text('Male'),
                  style: new TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextFormField(
              readOnly: true,
              controller: _dateOfBirthController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(0),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                labelText: allTranslations.text('Date_of_Birth'),
                labelStyle: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 15,
                    fontFamily: 'Montserrat'),
              ),
              keyboardType: TextInputType.number,
              validator: (s) => validateBirthdate(s!),
              onTap: () {
                _selectDate(context);
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(0),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                labelText: allTranslations.text('Enter_your_Address'),
                labelStyle: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 15,
                    fontFamily: 'Montserrat'),
              ),
              keyboardType: TextInputType.text,
              validator: (s) => validateCountry(s!),
              onTap: () {
                addressSearch(context);
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _countryController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(0),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                labelText: allTranslations.text('Enter_your_Country'),
                labelStyle: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 15,
                    fontFamily: 'Montserrat'),
              ),
              keyboardType: TextInputType.text,
              validator: (s) => validateCountry(s!),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(0),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                labelText: allTranslations.text('Enter_your_City'),
                labelStyle: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 15,
                    fontFamily: 'Montserrat'),
              ),
              keyboardType: TextInputType.text,
              validator: (s) => validateCity(s!),
            ),
            SizedBox(height: 20),
            TextFormField(
              obscureText: passwordVisible,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(0),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                labelText: allTranslations.text('password'),
                labelStyle: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 15,
                    fontFamily: 'Montserrat'),
                suffixIcon: IconButton(
                  icon: Icon(
                    passwordVisible ? Icons.visibility_off : Icons.visibility,
                    color: AppColours.appTheme,
                  ),
                  onPressed: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                ),
              ),
              keyboardType: TextInputType.text,
              validator: (s) => validatePassword(s!),
              controller: _pass,
              onSaved: (String? val) {
                _password = val;
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              obscureText: passwordVisible,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(0),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                labelText: allTranslations.text('confirmpassword'),
                labelStyle: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 15,
                    fontFamily: 'Montserrat'),
                suffixIcon: IconButton(
                  icon: Icon(
                    passwordVisible ? Icons.visibility_off : Icons.visibility,
                    color: AppColours.appTheme,
                  ),
                  onPressed: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                ),
              ),
              keyboardType: TextInputType.text,
              validator: (val) {
                if (val != null) if (val.isEmpty)
                  return allTranslations.text("confirmpassword");
                if (val != _pass.text)
                  return allTranslations
                      .text("Password_and_confirm_password_feild_mismatch");
                return null;
              },
              controller: _confirmPass,
            ),
            SizedBox(height: 50),
            SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(color: AppColours.appTheme)),
                  onPressed: () {
                    if (!loading) _validateInputs(context);
                  },
                  color: AppColours.appTheme,
                  textColor: Colors.white,
                  child: loading
                      ? CircularProgressIndicator(
                          valueColor:
                              new AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(allTranslations.text('Continue'),
                          style:
                              TextStyle(fontSize: 20, fontFamily: 'Montaga')),
                )),
          ],
        ));
  }

  Future<void> checkValidation(context) async {
    var callUserLoginCheck = await internetConnectionState();
    final bool emailValid = EmailValidator.validate(_email!);
    final String mobile =
        validateMobile(mobileNumberController.text).toString();
    if (callUserLoginCheck == true) {
      if (emailValid == false) {
        _showToast(allTranslations.text("please_enter_vaild_email"));
      } else {
        if (mobile == "null") {
          permissionCheckUser(context);
        } else {
          _showToast(mobile);
        }
      }
    }
  }

  void permissionCheckUser(context) {
    apiCalling(context);
  }

  Future<void> apiCalling(context) async {
    FocusManager.instance.primaryFocus!.unfocus();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String fcmToken = "";
    String udid = await FlutterUdid.udid;
    final String currentTimeZone =
        await FlutterNativeTimezone.getLocalTimezone();
    setState(() {
      loading = true;
    });
    var osType = "", deviceName = "", model = "";
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      osType = "Android";
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceName = androidInfo.model.toString();
      model = androidInfo.model.toString();
    } else if (Platform.isIOS) {
      osType = "iOS";
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceName = iosInfo.utsname.machine;
      model = iosInfo.model.toString();
    } else {
      osType = Platform.operatingSystem;
    }
    if (fcmToken == '') {
      new FirebaseNotifications().setUpFirebase();
      fcmToken = prefs.getString('fcm_token') ?? "";
      if (fcmToken == "")
        fcmToken = await FirebaseMessaging.instance.getToken() ?? "";
      prefs.setString('fcm_token', fcmToken);
      if (mounted) setState(() {});
    }
    Map map = {
      "full_name": _name,
      "email": _email,
      "phone": _mobile,
      "country_code": _countrycode,
      "gender": gendarSelected,
      "device_id": udid,
      "fcm_token": fcmToken,
      "os_type": osType,
      "device_name": deviceName,
      "device_model": model,
      "language": currentTimeZone,
      "time_zone": currentTimeZone,
    };
    Map decoded = jsonDecode(
        await apiAuthentificationRequest(signupStepOneUrl, map, context));
    String status = decoded['status'];
    String message = decoded['message'];
    if (status == success_status) {
      var record = decoded['record'];
      var id = record['id'].toString();
      apiCallingSecond(id);
    } else {
      if (mounted)
        setState(() {
          loading = false;
        });
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

  void validateMyPhone(String value, String type) {
    Pattern pattern = r'^\d+(?:\.\d+)?$';
    RegExp regex = new RegExp(pattern.toString());
    if (!regex.hasMatch(value)) {
      setState(() {
        mobileNumberController.text = "";
      });
      _showToast(allTranslations.text("please_enter_vaild_phone_number"));
    } else {
      return null;
    }
  }
}
