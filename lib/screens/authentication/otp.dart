import 'dart:async';
import 'dart:convert';

import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/screens/authentication/resetPassword.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OtpRoute extends StatefulWidget {
  OtpRoute({Key? key, this.user_id, this.user_type}) : super(key: key);
  var user_id;
  var user_type;

  OTPPageState createState() => OTPPageState();
}

class OTPPageState extends State<OtpRoute> {
  var currentText = "";
  TextEditingController textEditingController = TextEditingController();

  TextEditingController controller1 = new TextEditingController();
  TextEditingController controller2 = new TextEditingController();
  TextEditingController controller3 = new TextEditingController();
  TextEditingController controller4 = new TextEditingController();
  TextEditingController controller5 = new TextEditingController();
  TextEditingController controller6 = new TextEditingController();
  TextEditingController currController = new TextEditingController();
  Timer? _timer;
  int _start = 20;
  var reSendShow = true;
  String timeShow = "";

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
    controller1.dispose();
    controller2.dispose();
    controller3.dispose();
    controller4.dispose();
    controller5.dispose();
    controller6.dispose();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) => setState(
            () {
          if (_start < 1) {
            timer.cancel();
            setState(() {
              reSendShow = true;
              _start = 20;
            });
          } else {
            _start = _start - 1;
            if (_start < 10) {
              timeShow = "00 : " + "0" + _start.toString();
            } else {
              timeShow = "00 : " + _start.toString();
            }
          }
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    currController = controller1;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [
      Padding(
        padding: EdgeInsets.only(left: 0.0, right: 2.0),
        child: new Container(
          color: Colors.transparent,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 2.0, left: 2.0),
        child: new Container(
            alignment: Alignment.center,
            decoration: new BoxDecoration(
                color: AppColours.whiteColour,
                border: new Border.all(
                  width: 1.0,
                  color: AppColours.whiteColour,
                ),
                borderRadius: new BorderRadius.circular(4.0)),
            child: new TextField(
              inputFormatters: [
//                LengthLimitingTextInputFormatter(1),
              ],
              enabled: false,
              controller: controller1,
              autofocus: false,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24.0, color: AppColours.blackColour),
            )),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 2.0, left: 2.0),
        child: new Container(
          alignment: Alignment.center,
          decoration: new BoxDecoration(
              color: AppColours.whiteColour,
              border: new Border.all(width: 1.0, color: AppColours.whiteColour),
              borderRadius: new BorderRadius.circular(4.0)),
          child: new TextField(
            inputFormatters: [
//              LengthLimitingTextInputFormatter(1),
            ],
            controller: controller2,
            autofocus: false,
            enabled: false,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24.0, color: AppColours.blackColour),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 2.0, left: 2.0),
        child: new Container(
          alignment: Alignment.center,
          decoration: new BoxDecoration(
              color: AppColours.whiteColour,
              border: new Border.all(width: 1.0, color: AppColours.whiteColour),
              borderRadius: new BorderRadius.circular(4.0)),
          child: new TextField(
            inputFormatters: [
//              LengthLimitingTextInputFormatter(1),
            ],
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            controller: controller3,
            textAlign: TextAlign.center,
            autofocus: false,
            enabled: false,
            style: TextStyle(fontSize: 24.0, color: AppColours.blackColour),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 2.0, left: 2.0),
        child: new Container(
          alignment: Alignment.center,
          decoration: new BoxDecoration(
              color: AppColours.whiteColour,
              border: new Border.all(width: 1.0, color: AppColours.whiteColour),
              borderRadius: new BorderRadius.circular(4.0)),
          child: new TextField(
            inputFormatters: [
//              LengthLimitingTextInputFormatter(1),
            ],
            textAlign: TextAlign.center,
            controller: controller4,
            autofocus: false,
            enabled: false,
            style: TextStyle(fontSize: 24.0, color: AppColours.blackColour),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 2.0, left: 2.0),
        child: new Container(
          alignment: Alignment.center,
          decoration: new BoxDecoration(
              color: AppColours.whiteColour,
              border: new Border.all(width: 1.0, color: AppColours.whiteColour),
              borderRadius: new BorderRadius.circular(4.0)),
          child: new TextField(
            inputFormatters: [
//              LengthLimitingTextInputFormatter(1),
            ],
            textAlign: TextAlign.center,
            controller: controller5,
            autofocus: false,
            enabled: false,
            style: TextStyle(fontSize: 24.0, color: AppColours.blackColour),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 2.0, left: 2.0),
        child: new Container(
          alignment: Alignment.center,
          decoration: new BoxDecoration(
              color: AppColours.whiteColour,
              border: new Border.all(width: 1.0, color: AppColours.whiteColour),
              borderRadius: new BorderRadius.circular(4.0)),
          child: new TextField(
            inputFormatters: [
//              LengthLimitingTextInputFormatter(1),
            ],
            textAlign: TextAlign.center,
            controller: controller6,
            autofocus: false,
            enabled: false,
            style: TextStyle(fontSize: 24.0, color: AppColours.blackColour),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 2.0, right: 0.0),
        child: new Container(
          color: Colors.transparent,
        ),
      ),
    ];

    return new Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          allTranslations.text('enterotp'),
          style: TextStyle(color: AppColours.blackColour),
        ),
        centerTitle: true,
        backgroundColor: AppColours.whiteColour,
      ),
      backgroundColor: Color(0xFFeaeaea),
      body: Container(
        color: AppColours.whiteColour,
        child: Column(
          children: <Widget>[
//            MaterialButton(
//              onPressed: () {
//                startTimer();
//                setState(() {
//                  reSendShow=false;
//
//                });
//              },
//              child: Text("start"),
//            ),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child:
                    /*Image(
                      image: AssetImage('Assets/images/otp-icon.png'),
                      height: 120.0,
                      width: 120.0,
                    ),*/
                    Icon(
                      Icons.lock,
                      size: 120.0,
                      color: AppColours.blackColour,
                    ),
                  ),
                  /* Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
                    child: Text(
                      confirmmessage,
                      style: TextStyle(fontSize: 18.0, color: AppColours.blackColour),
                    ),
                  ),*/
                  reSendShow
                      ? Padding(
                    padding:
                    const EdgeInsets.fromLTRB(12.0, 36.0, 12.0, 8.0),
                    child: GestureDetector(
                        onTap: () {
                          resendOtp();
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              allTranslations.text('didtgetcode'),
                              style: TextStyle(
                                fontSize: 18.0,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 2.0),
                            ),
                            Text(
                              allTranslations.text('Renvoyer'),
                              style: TextStyle(
                                  fontSize: 18.0,
                                  color: AppColours.appTheme,
                                  decoration: TextDecoration.underline),
                            ),
                          ],
                        )),
                  )
                      : Padding(
                    padding:
                    const EdgeInsets.fromLTRB(12.0, 36.0, 12.0, 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "verification code expire in",
                          style: TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5.0),
                        ),
                        Text(
                          timeShow,
                          style: TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              flex: 90,
            ),
            Flexible(
              child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    GridView.count(
                        crossAxisCount: 8,
                        mainAxisSpacing: 10.0,
                        shrinkWrap: true,
                        primary: false,
                        scrollDirection: Axis.vertical,
                        children: List<Container>.generate(
                            8,
                                (int index) =>
                                Container(child: widgetList[index]))),
                  ]),
              flex: 20,
            ),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Container(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, top: 16.0, right: 8.0, bottom: 0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          MaterialButton(
                            color: AppColours.whiteColour,
                            onPressed: () {
                              inputTextToField("1");
                            },
                            child: Text("1",
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 22.0),
                          ),
                          MaterialButton(
                            color: AppColours.whiteColour,
                            onPressed: () {
                              inputTextToField("2");
                            },
                            child: Text("2",
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 22.0),
                          ),
                          MaterialButton(
                            color: AppColours.whiteColour,
                            onPressed: () {
                              inputTextToField("3");
                            },
                            child: Text("3",
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                    ),
                  ),
                  new Container(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, top: 4.0, right: 8.0, bottom: 0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          MaterialButton(
                            color: AppColours.whiteColour,
                            onPressed: () {
                              inputTextToField("4");
                            },
                            child: Text("4",
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 22.0),
                          ),
                          MaterialButton(
                            color: AppColours.whiteColour,
                            onPressed: () {
                              inputTextToField("5");
                            },
                            child: Text("5",
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 22.0),
                          ),
                          MaterialButton(
                            color: AppColours.whiteColour,
                            onPressed: () {
                              inputTextToField("6");
                            },
                            child: Text("6",
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                    ),
                  ),
                  new Container(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, top: 4.0, right: 8.0, bottom: 0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          MaterialButton(
                            color: AppColours.whiteColour,
                            onPressed: () {
                              inputTextToField("7");
                            },
                            child: Text("7",
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 22.0),
                          ),
                          MaterialButton(
                            color: AppColours.whiteColour,
                            onPressed: () {
                              inputTextToField("8");
                            },
                            child: Text("8",
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 22.0),
                          ),
                          MaterialButton(
                            color: AppColours.whiteColour,
                            onPressed: () {
                              inputTextToField("9");
                            },
                            child: Text("9",
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                    ),
                  ),
                  new Container(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, top: 4.0, right: 8.0, bottom: 0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          MaterialButton(
                              color: AppColours.whiteColour,
                              onPressed: () {
                                deleteText();
                              },
                              child: Image.asset('assets/delete.webp',
                                  width: 25.0, height: 25.0)),
                          Padding(
                            padding: EdgeInsets.only(left: 22.0),
                          ),
                          MaterialButton(
                            color: AppColours.whiteColour,
                            onPressed: () {
                              inputTextToField("0");
                            },
                            child: Text("0",
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 22.0),
                          ),
                          MaterialButton(
                              color: AppColours.whiteColour,
                              onPressed: () {
                                matchOtp();
                              },
                              child: Text(allTranslations.text('Done'))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              flex: 90,
            ),
          ],
        ),
      ),
    );
  }

  void inputTextToField(String str) {
    //Edit first textField
    if (currController == controller1) {
      controller1.text = str;
      currController = controller2;
    }

    //Edit second textField
    else if (currController == controller2) {
      controller2.text = str;
      currController = controller3;
    }

    //Edit third textField
    else if (currController == controller3) {
      controller3.text = str;
      currController = controller4;
    }

    //Edit fourth textField
    else if (currController == controller4) {
      controller4.text = str;
      currController = controller5;
    }

    //Edit fifth textField
    else if (currController == controller5) {
      controller5.text = str;
      currController = controller6;
    }

    //Edit sixth textField
    else if (currController == controller6) {
      controller6.text = str;
      currController = controller6;
    }
  }

  void deleteText() {
    if (currController.text.length == 0) {
    } else {
      currController.text = "";
      currController = controller5;
      return;
    }

    if (currController == controller1) {
      controller1.text = "";
    } else if (currController == controller2) {
      controller1.text = "";
      currController = controller1;
    } else if (currController == controller3) {
      controller2.text = "";
      currController = controller2;
    } else if (currController == controller4) {
      controller3.text = "";
      currController = controller3;
    } else if (currController == controller5) {
      controller4.text = "";
      currController = controller4;
    } else if (currController == controller6) {
      controller5.text = "";
      currController = controller5;
    }
  }

/*  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(0.0, 130.0, 0.0, 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'OTP',
                style: TextStyle(
                    fontSize: 30.0,
                    fontFamily: 'Montaga',
                    color: Constants.PrimaryColor),
              ),
              const SizedBox(height: 30),
              Text(
                'Please enter the 4-digit OTP you received on your registered email address / mobile number.',
                style: TextStyle(
                    fontSize: 20.0,
                    fontFamily: 'Montserrat',
                    color: Constants.PrimaryColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              PinCodeTextField(
                length: 6,
                obsecureText: false,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                    shape: PinCodeFieldShape.underline,
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeFillColor: Colors.transparent,
                    activeColor: Constants.PrimaryColor,
                    inactiveColor: Constants.PrimaryColor),
                animationDuration: Duration(milliseconds: 300),
                backgroundColor: Colors.transparent,
                enableActiveFill: false,

                //errorAnimationController: errorController,
                // controller: textEditingController,
                onCompleted: (v) {

                },
                onChanged: (value) {

                  setState(() {
                    currentText = value;
                  });
                },
                beforeTextPaste: (text) {

                  //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                  //but you can show anything you want here, like your pop up saying wrong paste format or etc
                  return true;
                },
              ),
              Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Padding(
                      padding: EdgeInsets.only(bottom: 100.0),
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          child: MaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                side:
                                    BorderSide(color: Constants.PrimaryColor)),
                            onPressed: () {
                              validationCheck();
                            },
                            color: Constants.PrimaryColor,
                            textColor: Colors.white,
                            child: Text("Confirm",
                                style: TextStyle(
                                    fontSize: 20, fontFamily: 'Montaga')),
                          ))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }*/

  Future<void> validationCheck(typeOtpData) async {
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck == true) {
      callUserOtp(typeOtpData);
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

  void callUserOtp(typeOtpData) async {
    Map map = {"user_id": widget.user_id, "otp": typeOtpData};
    Map decoded = jsonDecode(
        await apiAuthentificationRequest(verifyForgotOtpUrl, map, context));
    String status = decoded['status'];
    String message = decoded['message'];
    _showToast(message);
    if (status == success_status) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ResetPage(
                user_id: widget.user_id, user_type: widget.user_type)),
      );
    } else if (status == already_login_status) {
      _showToast(message);
    } else {
//    _showToast(context, message);
    }
    setState(() {
//    signInClick = false;
    });
  }

  Future<void> resendOtp() async {
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck == true) {
      Map decoded =
      jsonDecode(await getApiDataRequest(resendForgotOtpUrl, context));
      String status = decoded['status'];
      String message = decoded['message'];
      _showToast(message);
      if (status == success_status) {
        //    _showToast(context, message);
      } else if (status == already_login_status) {
        _showToast(message);
      } else {
//    _showToast(context, message);
      }
      setState(() {
//    signInClick = false;
      });
    }
  }

  void matchOtp() {
    String typeOtpData = controller1.text +
        controller2.text +
        controller3.text +
        controller4.text +
        controller5.text +
        controller6.text;

    if (controller1.text == "" &&
        controller2.text == "" &&
        controller3.text == "" &&
        controller4.text == "" &&
        controller5.text == "" &&
        controller6.text == "") {
      _showToast("please enter otp");
    } else {
      validationCheck(typeOtpData);
    }
  }
}
