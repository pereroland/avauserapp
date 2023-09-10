import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/contactfetch.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/shimmerEffects/imageloadshimmer.dart';
import 'package:avauserapp/components/widget/button.dart';
import 'package:avauserapp/components/widget/text.dart';
import 'package:avauserapp/components/widget/textfield.dart';
import 'package:avauserapp/main.dart';
import 'package:avauserapp/screens/home/baseTabClass.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateClan extends StatefulWidget {
  CreateClan({Key? key, required this.listSelected}) : super(key: key);
  List<ContactListJson> listSelected = [];

  @override
  _CreateClanState createState() => _CreateClanState();
}

class _CreateClanState extends State<CreateClan> {
  var imageSelect = false;
  File? _image;
  final ImagePicker picker = ImagePicker();
  TextEditingController groupNameController = TextEditingController();
  TextEditingController groupDecriptionController = TextEditingController();
  var eventCreate = false;
  String userIds = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: buttonBottom(context),
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            allTranslations.text('CreateNewClan'),
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          leading: BackButton(
            color: Colors.black,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                  height: size.height / 4,
                  color: '#453885'.parse(),
                  child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: InkWell(
                                  child: imageSelect
                                      ? CircleAvatar(
                                          radius: 57,
                                          backgroundColor: Color(0xff476cfb),
                                          child: ClipOval(
                                            child: new SizedBox(
                                              width: 100.0,
                                              height: 70.0,
                                              child: _image != null
                                                  ? Image.file(
                                                      _image!,
                                                      fit: BoxFit.fill,
                                                    )
                                                  : Image.network(
                                                      "Any Url from the internet to display image",
                                                      fit: BoxFit.fill,
                                                    ),
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          Icons.account_circle,
                                          color: AppColours.whiteColour,
                                          size: 60.0,
                                        ),
                                  onTap: () {
                                    openDialog(context);
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 20.0,
                              ),
                              Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      normalTextfield(
                                          hintText: allTranslations
                                              .text('typeGroupNamehere'),
                                          controller: groupNameController,
                                          keyboardType: TextInputType.name,
                                          borderColour: Colors.transparent,
                                          textColour: Colors.white,
                                          hintColour: Colors.white),
                                      normalTextfield(
                                          hintText: allTranslations
                                              .text('partyDiscussionBilling'),
                                          controller: groupDecriptionController,
                                          keyboardType: TextInputType.name,
                                          borderColour: Colors.transparent,
                                          textColour: Colors.white,
                                          hintColour: Colors.white)
                                    ],
                                  )),
                            ],
                          ),
                          Divider(
                            color: AppColours.whiteColour,
                          ),
                        ],
                      ))),
            ),
            Padding(
              padding: EdgeInsets.only(top: size.height / 4.7),
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(40),
                      topLeft: Radius.circular(40),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        headerText(
                            text: allTranslations.text('participants') +
                                " : " +
                                widget.listSelected.length
                                    .convertToZeroAdd()
                                    .toString(),
                            size: 20.0),
                        ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: widget.listSelected.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListData(
                                  widget.listSelected, index, context);
                            })
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget ListData(
      List<ContactListJson> contactslist, int index, BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: AppColours.transparentColour, width: 2.0),
          ),
          elevation: 2,
          child: new Container(
            padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColours.appTheme,
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                  ),
                ),
                Expanded(
                  flex: 26,
                  child: Container(
                    color: AppColours.whiteColour,
                    child: Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                                flex: 2,
                                child: new CircleAvatar(
                                  radius: 28,
                                  backgroundColor: AppColours.whiteColour,
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: contactslist[index].profile,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          imageShimmer(context, 48.0),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        "Images/userimage.png",
                                        fit: BoxFit.fill,
                                      ),
                                      width: 42,
                                      height: 42,
                                    ),
                                  ),
                                )),
                            Expanded(
                                flex: 12,
                                child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        15.0, 10.0, 5.0, 10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          contactslist[index].name,
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          contactslist[index].number,
                                          style: TextStyle(
                                            fontSize: 14.0,
                                          ),
                                        ),
                                        /* Text(
                                          contactslist[index].in_app,
                                          style: TextStyle(
                                            fontSize: 14.0,
                                          ),
                                        )*/
                                      ],
                                    ))),
                            SizedBox(
                              width: 5.0,
                            ),
                          ],
                        )),
                  ),
                )
              ],
            ),
            decoration: new BoxDecoration(
              color: AppColours.appTheme,
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
      onLongPress: () {},
    );
  }

  buttonBottom(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: SizedBox(
          height: 50,
          width: MediaQuery.of(context).size.width,
          child: fullColouredBtn(
              radiusButtton: 15.0,
              text: allTranslations.text('createclan'),
              onPressed: () {
                checkDataValidation(context);
              })),
    );
  }

  void openDialog(context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Center(child: Text(allTranslations.text('ChooseAction'))),
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
                            getImage(context, "camera");
                          },
                          color: AppColours.appTheme,
                          textColor: AppColours.whiteColour,
                          disabledColor: Colors.grey,
                          disabledTextColor: AppColours.blackColour,
                          padding: EdgeInsets.all(8.0),
                          splashColor: AppColours.appTheme,
                        ),
                        MaterialButton(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0)),
                          child: Text(allTranslations.text('galleryTxt')),
                          onPressed: () {
                            getImage(context, "gallery");
                          },
                          color: AppColours.appTheme,
                          textColor: AppColours.whiteColour,
                          disabledColor: Colors.grey,
                          disabledTextColor: AppColours.blackColour,
                          padding: EdgeInsets.all(8.0),
                          splashColor: AppColours.appTheme,
                        )
                      ]),
                  SizedBox(
                    width: double.infinity,
                    // height: double.infinity,
                    child: OutlinedButton(
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(
                              BorderSide(color: AppColours.appTheme)),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)))),
                      child: Text(allTranslations.text('cancel')),
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

  Future getImage(BuildContext context, String imageType) async {
    var pickedFile;
    if (imageType == "camera") {
      pickedFile = await picker.pickImage(source: ImageSource.camera);
      Navigator.pop(context);
    } else {
      pickedFile = await picker.pickImage(source: ImageSource.gallery);
      Navigator.pop(context);
    }
    setState(() {
      imageSelect = true;
      _image = File(pickedFile.path);
    });
  }

  void createClanApiData(context) async {
    showToast("Please wait...");
    List<String> data = [];
    for (int i = 0; i < widget.listSelected.length; i++) {
      String id = widget.listSelected[i].id.toString();
      data.add(id);
    }
    userIds = data.join(', ');

    disableEnableLoad(true);
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authtoken = prefs.getString('authtoken') ?? "";
      // String userId = prefs.getString('id')??"";

      Map<String, String> headers = {"authtoken": authtoken};

      var uri = Uri.parse(createClanUrl);
      var request = new http.MultipartRequest("POST", uri);
      request.headers.addAll(headers);
      if (_image != null) {
        var stream =
            new http.ByteStream(DelegatingStream.typed(_image!.openRead()));
        var length = await _image!.length();
        var multipartFileIdentityFront = new http.MultipartFile(
            'image', stream, length,
            filename: basename(_image!.path));
        request.files.add(multipartFileIdentityFront);
      } else {}
      request.fields['Accept-Language'] = allTranslations.locale.toString();
      request.fields['title'] = groupNameController.text;
      request.fields['description'] = groupDecriptionController.text;
      request.fields['user_ids'] = userIds;
      var response = await request.send();
      response.stream.transform(utf8.decoder).listen((value) async {
        Map data = jsonDecode(await value);
        String status = data['status'];
        String message = data['message'];
        if (status == "200") {
          navigatorKey.currentState?.pushReplacement(
              MaterialPageRoute(builder: (_) => TabBarController(4)));
        } else if (status == unauthorized_status) {
          await checkLoginStatus(context);
        } else if (status == data_not_found_status) {
        } else if (status == already_login_status) {
        } else if (status == "408") {
          Map decoded = jsonDecode(await apiRefreshRequest(context));
          createClanApiData(context);
        } else {
          showToast(message);
        }
      });
      disableEnableLoad(false);
    } else {
      disableEnableLoad(false);
    }
  }

  void disableEnableLoad(bool bool) {
    setState(() {
      eventCreate = bool;
    });
  }

  void checkDataValidation(context) {
    if (groupNameController.text.toString().trim().toString() == "") {
      showToast(allTranslations.text('PleaseEnterGroupName'));
    } else if (groupNameController.text.toString().trim().toString() == "") {
      showToast(allTranslations.text('PleaseEnterGroupDescription'));
    } else {
      createClanApiData(context);
    }
  }
}

extension on String {
  parse() {
    var hexColor = this.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }
}

extension on int {
  String convertToZeroAdd() {
    if (this > 10) {
      return this.toString();
    } else {
      return "0" + this.toString();
    }
  }
}
