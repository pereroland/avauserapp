import 'dart:async';
import 'dart:io';

import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/dataLoad/WalletIdsCheck.dart';
import 'package:avauserapp/components/dataLoad/myWallettModeLoad.dart';
import 'package:avauserapp/components/dataLoad/paymentModeLoad.dart';
import 'package:avauserapp/components/keyboardSIze.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/navigation/navigationBankData.dart';
import 'package:avauserapp/components/widget/appbar.dart';
import 'package:avauserapp/components/widget/button.dart';
import 'package:avauserapp/components/widget/dottedBorder.dart';
import 'package:avauserapp/components/widget/imagePicker.dart';
import 'package:avauserapp/components/widget/pinSetWidget.dart';
import 'package:avauserapp/components/widget/rowListTile.dart';
import 'package:avauserapp/components/widget/text.dart';
import 'package:avauserapp/components/widget/textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';

import 'DetailPageData.dart';

class WalletSetUp extends StatefulWidget {
  final bool showAppbar;

  const WalletSetUp({required this.showAppbar});
  @override
  _WalletSetUpState createState() => _WalletSetUpState();
}

class _WalletSetUpState extends State<WalletSetUp> {
  var walletId = false;
  var selectIDProof = false;
  var selectPinCode = false;
  File? croppedFile;
  File? firstCropped;
  File? secondCropped;
  final formKey = GlobalKey<FormState>();
  String currentFirstPinText = "";
  String currentSecondPinText = "";
  String currentConfirmText = "";
  var wallet_ID = "";
  var loadding = true;
  var currencyLoaded = false;
  TextEditingController walletIdController = TextEditingController();
  TextEditingController idNumberController = TextEditingController();
  var recordId;
  var currencyId;
  Map mapCard = Map();
  List<Map> cinetpayCurrencyMap = [];
  var cinetpayCurrencyFirstValue;
  var cinetpayCurrencyFirstValueId;

  //National Id, passport, driver license
  List<Map> _myJson = [
    {"id": 1, "name": "National Id"},
    {"id": 2, "name": "passport"},
    {"id": 3, "name": "driver license"}
  ];
  String tag_add_hint = "";
  String tag = "National Id";
  var imageSelect = "front";

  @override
  void initState() {
    super.initState();
    getDetailPrevious();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: loadding ? SizedBox.shrink() : bottonButton(),
      appBar: widget.showAppbar
          ? appBarWidget(
              text: 'Wallet Setup',
              textColour: Colors.black,
              backgroundColour: Colors.white,
              onTap: () {
                Navigator.pop(context);
              })
          : null,
      body: loadding
          ? Container(
              height: size.height,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Image.asset('assets/PaymentCards/payment_image.webp'),
                ),
              ),
            )
          : Scaffold(
              body: Container(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        walletIdSet(size),
                        SizedBox(
                          height: 20.0,
                        ),
                        walletIdProof(size),
                        SizedBox(
                          height: 20.0,
                        ),
                        walletPinProof(size),
                        keyBoardSize(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  walletIdSet(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        walletRow(
            keyName: allTranslations.text("WalletId"),
            icon: Icon(walletId ? Icons.arrow_drop_up : Icons.arrow_drop_down),
            onTap: () {
              setState(() {
                if (walletId) {
                  walletId = false;
                } else {
                  walletId = true;
                }
              });
            }),
        walletId
            ? Padding(
                padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                child: normalTextfield(
                    hintText: wallet_ID == "" ? 'Enter Wallet Id' : wallet_ID,
                    controller: walletIdController,
                    readOnly: wallet_ID == "" ? false : true,
                    keyboardType: TextInputType.emailAddress,
                    borderColour: Colors.black45),
              )
            : SizedBox.shrink(),
      ],
    );
  }

  walletIdProof(Size size) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      walletRow(
          keyName: allTranslations.text("select_id_proof"),
          icon:
              Icon(selectIDProof ? Icons.arrow_drop_up : Icons.arrow_drop_down),
          onTap: () {
            setState(() {
              if (selectIDProof) {
                selectIDProof = false;
              } else {
                selectIDProof = true;
              }
            });
          }),
      selectIDProof
          ? Padding(
              padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton<String>(
                  isExpanded: true,
                  items: _myJson.map((Map map) {
                    return new DropdownMenuItem<String>(
                      value: map["name"].toString(),
                      child: new Text(
                        map["name"],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      if (value != null) tag = value;
                    });
                  },
                  hint: Text(tag_add_hint),
                  value: tag,
                ),
              ),
            )
          : SizedBox.shrink(),
      selectIDProof
          ? Padding(
              padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
              child: normalTextfield(
                  controller: idNumberController,
                  hintText: allTranslations.text('EnteranIdreferencenumber'),
                  keyboardType: TextInputType.emailAddress,
                  borderColour: Colors.black45),
            )
          : SizedBox.shrink(),
      selectIDProof
          ? Padding(
              padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0.0),
              child: Row(
                children: [
                  Expanded(
                    child: dottedBorder(
                        size: size,
                        text: allTranslations.text('SelectIdsFrontImage'),
                        ImageFile: firstCropped,
                        ontap: () {
                          imageSelect = "front";
                          pickFrontImage();
                        }),
                    flex: 1,
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                  Expanded(
                    child: dottedBorder(
                        size: size,
                        text: allTranslations.text('SelectIdsBackImage'),
                        ImageFile: secondCropped,
                        ontap: () {
                          imageSelect = "back";
                          pickFrontImage();
                        }),
                    flex: 1,
                  ),
                ],
              ),
            )
          : SizedBox.shrink(),
    ]);
  }

  walletPinProof(Size size) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      walletRow(
          keyName: allTranslations.text("SelectPinCode"),
          icon:
              Icon(selectPinCode ? Icons.arrow_drop_up : Icons.arrow_drop_down),
          onTap: () {
            setState(() {
              if (selectPinCode) {
                selectPinCode = false;
              } else {
                selectPinCode = true;
              }
            });
          }),
      selectPinCode ? enterPinSelectField(size) : SizedBox.shrink(),
      SizedBox(
        height: 15.0,
      ),
      selectCurrency(),
    ]);
  }

  Future<void> pickFrontImage() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Center(child: Text(allTranslations.text("ChooseAction"))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        MaterialButton(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0)),
                          child: Text(allTranslations.text('cameraTxt')),
                          onPressed: () async {
                            Navigator.pop(context);
                            File? pickedImage =
                                await imagePick(context, "Camera");
                            if (pickedImage != null) {
                              _cropImage(pickedImage);
                            }
                          },
                          color: AppColours.appTheme,
                          textColor: Colors.white,
                          disabledColor: Colors.grey,
                          disabledTextColor: AppColours.appTheme,
                          padding: EdgeInsets.all(8.0),
                          splashColor: AppColours.appTheme,
                        ),
                        MaterialButton(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0)),
                          child: Text(allTranslations.text('galleryTxt')),
                          onPressed: () async {
                            Navigator.pop(context);
                            File? pickedImage =
                                await imagePick(context, "Gallery");
                            if (pickedImage != null) {
                              _cropImage(pickedImage);
                            }
                          },
                          color: AppColours.appTheme,
                          textColor: Colors.white,
                          disabledColor: Colors.grey,
                          disabledTextColor: AppColours.appTheme,
                          padding: EdgeInsets.all(8.0),
                          splashColor: AppColours.appTheme,
                        )
                      ]),
                  new SizedBox(
                    width: double.infinity,
                    // height: double.infinity,
                    child: new OutlinedButton(
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(
                            BorderSide(color: AppColours.appTheme),
                          ),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(10.0)))),
                      child: new Text(allTranslations.text('cancel')),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10.0)));
        });
  }

  Future<Null> _cropImage(File pickedImage) async {
    CroppedFile? croppedFileLcoal = await ImageCropper().cropImage(
      sourcePath: pickedImage.path,
      aspectRatioPresets: Platform.isAndroid
          ? <CropAspectRatioPreset>[
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ]
          : <CropAspectRatioPreset>[
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio5x3,
              CropAspectRatioPreset.ratio5x4,
              CropAspectRatioPreset.ratio7x5,
              CropAspectRatioPreset.ratio16x9
            ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        )
      ],
    );
    if (mounted)
      setState(() {
        if (croppedFileLcoal != null) {
          if (imageSelect == "front") {
            firstCropped = File(croppedFileLcoal.path);
          } else {
            secondCropped = File(croppedFileLcoal.path);
          }
        }
      });
  }

  bottonButton() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: SizedBox(
        height: 50.0,
        child: fullColouredBtn(
            text: allTranslations.text('Addpaymentmode'),
            radiusButtton: 35.0,
            onPressed: () {
              checkDetail();
              /* Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WalletSetUp()),
              );*/
            }),
      ),
    );
  }

  enterPinSelectField(size) {
    return Padding(
      padding: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: Form(
        key: formKey,
        child: Padding(
            padding: const EdgeInsets.symmetric(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headerText(
                    text: allTranslations.text("enter_four_digit_pin"),
                    size: 16.0,
                    color: Colors.black45,
                    fontWeight: FontWeight.w200),
                SizedBox(
                  height: 10.0,
                ),
                pinSetWidget(
                    context: context,
                    onChanged: (value) {
                      setState(() {
                        currentFirstPinText = value;
                      });
                    }),
                SizedBox(
                  height: 30.0,
                ),
                headerText(
                    text: allTranslations.text("confirm_four_digit_pin"),
                    size: 16.0,
                    color: Colors.black45,
                    fontWeight: FontWeight.w200),
                SizedBox(
                  height: 10.0,
                ),
                pinSetWidget(
                    context: context,
                    onChanged: (value) {
                      setState(() {
                        currentSecondPinText = value;
                      });
                    }),
              ],
            )),
      ),
    );
  }

  Future<void> getDetailPrevious() async {
    Map detail = await myWalletModeLoad(context) ?? {};
    if (detail['status'] == "200") {
      List list = detail['record'];
      var data = list[0];

      var walletId = data['id'];
      var wallet_owner_id = data['wallet_owner_id'];
      wallet_ID = data['wallet_ID'];
      var ID_proof_type = data['ID_proof_type'].toString();
      var ID_number = data['ID_number'];
      if (mounted)
        setState(() {
          walletIdController.text = wallet_ID;
          recordId = walletId;
          currencyId = data['currency'];
          cinetpayCurrencyFirstValue = currencyId;
          cinetpayCurrencyFirstValueId = data['id'];
        });
      if (ID_proof_type == "null" || ID_proof_type == "") {
        setState(() {
          currencyLoad();
        });
      } else {
        // loadding = false;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DetailPageData()),
        );
      }
    } else {
      if (mounted)
        setState(() {
          currencyLoad();
        });
    }
  }

  Future<void> checkDetail() async {
    var lengthWallet = walletIdController.text.toString().length;
    if (lengthWallet < 2) {
      showToast(allTranslations.text("walllet_lenght_greter_then_2"));
    } else if (lengthWallet > 18) {
      showToast(allTranslations.text("walllet_lenght_greter_then_2"));
    } else if (idNumberController.text.toString().trim().toString() == "") {
      showToast(allTranslations.text("please_enter_id_proof"));
    } else if (firstCropped.toString() == "" ||
        firstCropped.toString() == "null") {
      showToast(allTranslations.text("please_upload_front_image"));
    } else if (secondCropped.toString() == "" ||
        secondCropped.toString() == "null") {
      showToast(allTranslations.text("please_upload_back_image"));
    } else if (currentFirstPinText.toString().length < 3) {
      showToast(allTranslations.text("please_enter_pin"));
    } else if (currentSecondPinText.toString().length < 3) {
      showToast(allTranslations.text("please_enter_confirm_pin"));
    } else if (currentFirstPinText.toString() !=
        currentSecondPinText.toString()) {
      showToast(allTranslations.text("confirm_pin_and_pin_same"));
    } else {
      if (recordId.toString() == 'null' || recordId.toString() == '') {
        var walletIdCheck = await checkWalletIdLoad(
            context,
            walletIdController.text.toString(),
            cinetpayCurrencyFirstValue,
            cinetpayCurrencyFirstValueId);
        if (walletIdCheck!.isEmpty) {
          return;
        }
        if (walletIdCheck['status'] == "200") {
          recordId = walletIdCheck['record'];

          walletDataSet(context);
        } else {
          showToast(walletIdCheck['message']);
        }
      } else {
        walletDataSet(context);
      }
    }
  }

  void walletDataSet(context) {
    var walletData = {
      "id": recordId,
      "currency_name": cinetpayCurrencyFirstValue,
      "wallet_id": walletIdController.text,
      "ID_proof_type": tag,
      "ID_number": idNumberController.text,
      "ID_image_front": firstCropped,
      "ID_image_back": secondCropped,
      "auth_pin_code": currentFirstPinText
    };
    getArrayList(context: context, walletData: walletData);
  }

  Future<void> currencyLoad() async {
    Map categoryListMap = await dropDownDataWalletLoad(context) ?? {};
    var successMessage = categoryListMap['status'].toString();
    if (successMessage == '200') {
      if (mounted)
        setState(() {
          var record = categoryListMap['record'];
          List cinetpayCurrency = record['cinetpayCurrency'];
          for (int i = 0; i < cinetpayCurrency.length; i++) {
            if (i == 0) {
              cinetpayCurrencyFirstValueId = cinetpayCurrency[i]['id'];
              cinetpayCurrencyFirstValue = cinetpayCurrency[i]['currency_name'];
            }
            var map = {
              "id": cinetpayCurrency[i]['id'],
              "name": cinetpayCurrency[i]['currency_name']
            };
            cinetpayCurrencyMap.add(map);
          }
          loadding = false;
          currencyLoaded = true;
        });
    }
  }

  currencyLoadWidget() {
    return Padding(
      padding: EdgeInsets.fromLTRB(15.0, 25.0, 15.0, 5.0),
      child: recordId.toString() == 'null' || recordId.toString() == ''
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allTranslations.text('SelectCurrency'),
                  style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    items: cinetpayCurrencyMap.map((Map map) {
                      return new DropdownMenuItem<String>(
                        value: map["name"].toString(),
                        child: new Text(map["name"],
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        cinetpayCurrencyFirstValue = value;
                        for (var dataitem in cinetpayCurrencyMap) {
                          if (dataitem['name'] == cinetpayCurrencyFirstValue) {
                            cinetpayCurrencyFirstValueId = dataitem['id'];
                          }
                        }
                      });
                    },
                    hint: Text(
                      tag_add_hint,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    value: cinetpayCurrencyFirstValue,
                  ),
                )
              ],
            )
          : Text(
              allTranslations.text('Currency') + " :- " + currencyId,
              style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
    );
  }

  selectCurrency() {
    return currencyLoaded ? currencyLoadWidget() : SizedBox.shrink();
  }
}
