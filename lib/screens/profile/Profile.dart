import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:avauserapp/components/Location/CurrentLocation.dart';
import 'package:avauserapp/components/Location/addressFinder.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/credential.dart';
import 'package:avauserapp/components/keyboardSIze.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/shimmerEffects/imageloadshimmer.dart';
import 'package:avauserapp/main.dart';
import 'package:avauserapp/screens/home/baseTabClass.dart';
import 'package:avauserapp/screens/setting/tagsAdding.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:place_picker/place_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileDetail extends StatefulWidget {
  @override
  _ProfileDetail createState() => _ProfileDetail();
}

class _ProfileDetail extends State<ProfileDetail> {
  var dataLoad = false;
  var STORES = "";
  Map? myLang;
  final picker = ImagePicker();
  bool isSwitchedDis = true;
  bool isSwitchedNot = true;
  File? _image;
  var all_notification = false,
      banking_notification = false,
      security_notification = false,
      shop_notification = false,
      events_notification = false,
      testers_notification = false,
      fashions_notification = false,
      food_notification = false,
      medicines_notification = false,
      discovery_mode = false,
      added_on = false,
      updated_on = false;
  var profilePic =
      'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTSLmktkJrArXh_zZVovazl5mb3lna9HXqPo7XvvviCSQAuru5C&usqp=CAU';
  TextEditingController fullNameController = TextEditingController();
  List tagesSelected = [];
  List<String> id = [];

  // TextEditingController LastNameController = TextEditingController();
  TextEditingController emailIdController = TextEditingController();
  TextEditingController countrycodeController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();
  TextEditingController cityNameController = TextEditingController();
  TextEditingController countryNameController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  var tags = "";

  String attendeesListCommaId = "";
  String? countrycode;
  var countryChange = false;
  var codeShow = false;
  List Gender = ["Male", "Female"];
  late List<DropdownMenuItem<String>> dropDownMenuItemsGender;
  String gender = "Male";
  List user_setting = [];
  var selectedTagList = [];
  var Latitude = "",
      Longitude = "",
      address = "",
      city = "",
      state = "",
      country = "";

  @override
  void initState() {
    super.initState();
    // addressGet();
    getProfileDetail(navigatorKey.currentContext!);
  }

  List<DropdownMenuItem<String>> getDropDownMenuItemsGender() {
    List<DropdownMenuItem<String>> items = [];
    for (String gender in Gender) {
      items.add(new DropdownMenuItem(value: gender, child: new Text(gender)));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      bottomNavigationBar: addtToCartButton(context),
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            spaceHeight(),

            Container(
              width: 120.0,
              height: 120.0,
              child: Stack(
                children: [
                  SizedBox(
                    width: 120.0,
                    height: 120.0,
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: _image == null
                          ? CachedNetworkImage(
                              imageUrl: profilePic,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  imageShimmer(context, 40.0),
                              errorWidget: (context, url, error) => Image.asset(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTSLmktkJrArXh_zZVovazl5mb3lna9HXqPo7XvvviCSQAuru5C&usqp=CAU',
                                fit: BoxFit.fill,
                                width: 40.0,
                                height: 40.0,
                              ),
                            )
                          : Image.file(
                              _image!,
                              width: 40.0,
                              height: 40.0,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Align(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: FloatingActionButton(
                        onPressed: () {
                          openDialog(context);
                        },
                        child: Icon(Icons.add_circle_outline),
                        backgroundColor: AppColours.appTheme,
                      ),
                    ),
                    alignment: Alignment.bottomRight,
                  )
                ],
              ),
            ),
            fullNameFiled(),
            // lastNameFiled(),
            emailAddressFiled(),
            mobileNumberFiled(),
            dobFiled(context),
            selectGenderFiled(),
            AddressCityFinder(context),
            selectCountryFiled(),
            taggsSet(context),
            keyBoardSize(),
            /*  notificationSwitch(),
            bankingSwitch(),
            securitySwitch(),
            shopSwitch(),
            eventSwitch(),
            testerSwitch(),
            fashionsSwitch(),
            foodSwitch(),
            medicinesSwitch()*/
          ],
        ),
      ),
    );
  }

  fullNameFiled() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 40.0, 10.0, 10.0),
      child: new Container(
        height: 50.0,
        child: TextFormField(
          controller: fullNameController,
          keyboardType: TextInputType.text,
          //This will obscure text dynamically
          decoration: InputDecoration(
            hintText: allTranslations.text('Full_Name'),
            labelText: allTranslations.text('Full_Name') + "*",
            fillColor: Colors.white,
            border: new OutlineInputBorder(
              borderRadius: new BorderRadius.circular(10.0),
              borderSide: new BorderSide(),
            ),
          ),
        ),
      ),
    );
  }

/*
  lastNameFiled() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      child: new Container(
        height: 50.0,
        child: TextFormField(
          controller: LastNameController,
          keyboardType: TextInputType.text,
          //This will obscure text dynamically
          decoration: InputDecoration(
            hintText: "Last Name",
            labelText: "Last Name",
            fillColor: Colors.white,
            border: new OutlineInputBorder(
              borderRadius: new BorderRadius.circular(10.0),
              borderSide: new BorderSide(),
            ),
          ),
        ),
      ),
    );
  }
*/

  emailAddressFiled() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      child: new Container(
        height: 50.0,
        child: TextFormField(
          readOnly: true,
          controller: emailIdController,
          keyboardType: TextInputType.emailAddress,
          //This will obscure text dynamically
          decoration: InputDecoration(
            hintText: allTranslations.text('Email_Address'),
            labelText: allTranslations.text('Email_Address') + "*",
            fillColor: Colors.white,
            border: new OutlineInputBorder(
              borderRadius: new BorderRadius.circular(10.0),
              borderSide: new BorderSide(),
            ),
          ),
        ),
      ),
    );
  }

  mobileNumberFiled() {
    return Container(
      height: 60.0,
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black38)),
      child: Row(
        children: <Widget>[
          countrycode != null
              ? Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CountryCodePicker(
                          onChanged: (country) {
                            setState(() {
                              countrycode = country.dialCode.toString();
                              countryChange = true;
                            });
                          },
                          padding: EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 8.0),
                          initialSelection: countrycode,
                          showCountryOnly: false,
                          showOnlyCountryWhenClosed: false,
                          alignLeft: false,
                          showFlag: false),
                    ],
                  ),
                )
              : SizedBox.shrink(),
          Expanded(
            flex: 5,
            child: new Container(
                height: 50.0,
                margin: EdgeInsets.only(right: 10.0, bottom: 10.0),
                child: TextFormField(
                    controller: mobileNumberController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(0),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent)),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      labelStyle: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 15,
                          fontFamily: 'Montserrat'),
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      setState(() {
                        validateMyPhone(value, "phone");
                      });
                    })),
          )
        ],
      ),
    );
    /* Padding(
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      child: new Container(
        height: 50.0,
        child: TextFormField(
          controller: mobileNumberController,
          keyboardType: TextInputType.phone,
          //This will obscure text dynamically
          decoration: InputDecoration(
            hintText: "Mobile Number",
            labelText: "Mobile Number*",
            fillColor: Colors.white,
            border: new OutlineInputBorder(
              borderRadius: new BorderRadius.circular(10.0),
              borderSide: new BorderSide(),
            ),
          ),
        ),
      ),
    );*/
  }

  selectGenderFiled() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        child: OutlinedButton(
          style: ButtonStyle(
              side: MaterialStateProperty.all(
                  BorderSide(color: AppColours.blacklightLineColour)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)))),
          child: Container(
            width: double.infinity,
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton(
                  value: gender,
                  items: dropDownMenuItemsGender,
                  onChanged: changedDropDownItem,
                ),
              ),
            ),
          ),
          onPressed: () {},
        ),
      ),
    );
  }

  AddressCityFinder(context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: new Container(
              child: TextFormField(
                controller: cityNameController,
                keyboardType: TextInputType.text,
                //This will obscure text dynamically
                decoration: InputDecoration(
                  hintText: allTranslations.text('Select_City'),
                  labelText: allTranslations.text('Select_City') + "*",
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(10.0),
                    borderSide: new BorderSide(),
                  ),
                ),
                onTap: () {},
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(Icons.location_on),
              onPressed: () {
                addressSearch(context);
              },
            ),
          )
        ],
      ),
    );
  }

  void changedDropDownItem(String? selectedGender) {
    setState(() {
      if (selectedGender != null) gender = selectedGender;
    });
  }

  taggsSet(context) {
    return Padding(
        padding: EdgeInsets.all(5.0),
        child: GestureDetector(
          onTap: () {
            AddTag(context);
          },
          child: Container(
              child: Card(
            color: Colors.white,
            child: tags == ""
                ? Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            flex: 9,
                            child: Text(
                              "Notification Tag",
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
                            )),
                        Expanded(
                          flex: 1,
                          child: Icon(Icons.add_circle_outline),
                        )
                      ],
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 9,
                          child: selectedTagsData(context),
                        ),
                        Expanded(
                          flex: 1,
                          child: Icon(Icons.add_circle_outline),
                        )
                      ],
                    ),
                  ),
          )),
        ));
  }

  void AddTag(context) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MytagsHomePage(
              TagList: user_setting,
              tagesSelected: tagesSelected,
              id: id,
              selectedTagList: selectedTagList)),
    );

    if (result == null) {
    } else {
      attendeesListCommaId = "";
      List data = result['items'];
      selectedTagList = result['listTags'];
      setState(() {
        tags = data.toString() + " tag added";
      });
    }
  }

  void setIdAttendees(context) {
    if (selectedTagList.length > 0) {
      List<String> result = [];
      for (int i = 0; i < selectedTagList.length; i++) {
        result.add(selectedTagList[i]['id']);
      }
      attendeesListCommaId = result.join(',');
      if (attendeesListCommaId == "") {
        _showToast("Please Add Tags");
      } else {
        setProfileDetail(context);
      }
    } else {
      _showToast("Please Add Tags");
    }
  }

  dobFiled(context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      child: new Container(
        height: 50.0,
        child: TextFormField(
          readOnly: true,
          controller: dateOfBirthController,
          keyboardType: TextInputType.number,
          //This will obscure text dynamically
          decoration: InputDecoration(
            hintText: allTranslations.text('Date_of_Birth'),
            labelText: allTranslations.text('Date_of_Birth') + "*",
            fillColor: Colors.white,
            border: new OutlineInputBorder(
              borderRadius: new BorderRadius.circular(10.0),
              borderSide: new BorderSide(),
            ),
          ),
          onTap: () {
            _selectDate(context);
          },
        ),
      ),
    );
  }

  selectCountryFiled() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      child: new Container(
        height: 50.0,
        child: TextFormField(
          readOnly: true,
          controller: countryNameController,
          keyboardType: TextInputType.number,
          //This will obscure text dynamically
          decoration: InputDecoration(
            hintText: allTranslations.text('Select_Country'),
            labelText: allTranslations.text('Select_Country') + "*",
            fillColor: Colors.white,
            border: new OutlineInputBorder(
              borderRadius: new BorderRadius.circular(10.0),
              borderSide: new BorderSide(),
            ),
          ),
        ),
      ),
    );
  }

  notificationSwitch() {
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
                    "All Notification",
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  )),
              Expanded(
                flex: 2,
                child: Container(
                  child: Switch(
                    value: all_notification,
                    onChanged: (value) {
                      setState(() {
                        setToAllTrue(value);
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

  bankingSwitch() {
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
                    "Banking",
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  )),
              Expanded(
                flex: 2,
                child: Container(
                  child: Switch(
                    value: banking_notification,
                    onChanged: (value) {
                      setState(() {
                        banking_notification = value;
                        setToAllFalse(value);
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

  securitySwitch() {
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
                    "Security",
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  )),
              Expanded(
                flex: 2,
                child: Container(
                  child: Switch(
                    value: security_notification,
                    onChanged: (value) {
                      setState(() {
                        security_notification = value;
                        setToAllFalse(value);
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

  shopSwitch() {
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
                    "Shop",
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  )),
              Expanded(
                flex: 2,
                child: Container(
                  child: Switch(
                    value: shop_notification,
                    onChanged: (value) {
                      setState(() {
                        shop_notification = value;
                        setToAllFalse(value);
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

  eventSwitch() {
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
                    "Event",
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  )),
              Expanded(
                flex: 2,
                child: Container(
                  child: Switch(
                    value: events_notification,
                    onChanged: (value) {
                      setState(() {
                        events_notification = value;
                        setToAllFalse(value);
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

  testerSwitch() {
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
                    "Tester",
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  )),
              Expanded(
                flex: 2,
                child: Container(
                  child: Switch(
                    value: testers_notification,
                    onChanged: (value) {
                      setState(() {
                        testers_notification = value;
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

  fashionsSwitch() {
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
                    "Fashions",
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  )),
              Expanded(
                flex: 2,
                child: Container(
                  child: Switch(
                    value: fashions_notification,
                    onChanged: (value) {
                      setState(() {
                        fashions_notification = value;
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

  foodSwitch() {
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
                    "Food",
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  )),
              Expanded(
                flex: 2,
                child: Container(
                  child: Switch(
                    value: food_notification,
                    onChanged: (value) {
                      setState(() {
                        food_notification = value;
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

  medicinesSwitch() {
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
                    "Medicines",
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  )),
              Expanded(
                flex: 2,
                child: Container(
                  child: Switch(
                    value: medicines_notification,
                    onChanged: (value) {
                      setState(() {
                        medicines_notification = value;
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

  Future<void> _selectDate(context) async {
    var now = new DateTime.now();

    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1),
        lastDate: DateTime(now.year, now.month, now.day));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        dateOfBirthController.text = pad(selectedDate.day).toString() +
            "-" +
            selectedDate.month.toString() +
            "-" +
            selectedDate.year.toString();
      });
  }

  String pad(n) {
    return (n < 10) ? ('0' + n.toString()) : n.toString();
  }

  spaceHeight() {
    return SizedBox(height: 10.0);
  }

  addtToCartButton(BuildContext context) {
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
                    color: AppColours.appTheme,
                    elevation: 16.0,
                    shape: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColours.appTheme),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    onPressed: () async {
                      if (!dataLoad) setIdAttendees(context);
                    },
                    child: dataLoad
                        ? CircularProgressIndicator(
                            valueColor:
                                new AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Text(
                            allTranslations.text('save'),
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  void getProfileDetail(BuildContext context) async {
    dropDownMenuItemsGender = getDropDownMenuItemsGender();
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck == true) {
      Map decoded = jsonDecode(await getApiDataRequest(profileUrl, context));
      String status = decoded['status'];
      String message = decoded['message'];
      if (status == success_status) {
        setState(() {
          var record = decoded['record'];
          user_setting = decoded['user_setting'] as List;
          // firstNameController.text = record['first_name'];
          // LastNameController.text = record['last_name'];
          fullNameController.text = record['full_name'];
          emailIdController.text = record['email'];
          profilePic = record['profile'];
          mobileNumberController.text = record['phone'];
          dateOfBirthController.text = record['dob'];
          countrycode = "+" + record['country_code'];
          countrycodeController.text = countrycode!;
          if (record['gender'] == "Male" || record['gender'] == "Female") {
            gender = record['gender'];
          }
          country = record.containsKey("country") ? record['country'] : "";
          state = record.containsKey("state") ? record['state'] : "";
          city = record.containsKey("city") ? record['city'] : "";
          Latitude = record.containsKey("latitude") ? record['latitude'] : "";
          address = record.containsKey("address") ? record["address"] : "";
          Longitude =
              record.containsKey("longitude") ? record['longitude'] : "";
          countryNameController.text = country;
          cityNameController.text = city;
          var j = 0;
          List data = [];
          for (int i = 0; i < user_setting.length; i++) {
            if (user_setting[i]['status'].toString() == "true") {
              j = j + 1;
              tagesSelected.add(user_setting[i]['name']);
              selectedTagList.add(user_setting[i]);
              id.add(user_setting[i]['id'].toString());
              data.add(user_setting[i]['name']);
            }
          }
          if (j == 0) {
            for (int i = 0; i < user_setting.length; i++) {
              j = j + 1;
              tagesSelected.add(user_setting[i]['name']);
              selectedTagList.add(user_setting[i]);
              id.add(user_setting[i]['id'].toString());
              data.add(user_setting[i]['name']);
              List<String> result = [];
              result.add(user_setting[i]['id']);
              attendeesListCommaId = result.join(',');
            }
          }
          if (j > 0) {
            tags = data.toString() + " tag added";
          }
          if (selectedTagList.length > 0) {
            List<String> result = [];
            for (int i = 0; i < selectedTagList.length; i++) {
              result.add(selectedTagList[i]['id']);
            }
            attendeesListCommaId = result.join(',');
          }
        });
      } else if (status == unauthorized_status) {
        await checkLoginStatus(context);
      } else if (status == already_login_status) {
        _showToast(message);
      } else if (status == data_not_found_status) {
        _showToast(message);
        Navigator.pop(context);
        Navigator.pop(context);
      } else if (status == expire_token_status) {
        Map decoded = jsonDecode(await apiRefreshRequest(context));
        getProfileDetail(context);
      } else {
        _showToast(message);
      }
    }
  }

  void setProfileDetail(context) async {
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck == true) {
      setState(() {
        dataLoad = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authtoken = prefs.getString('authtoken') ?? "";

      Map<String, String> headers = {"authtoken": authtoken};
      var uri = Uri.parse(updateProfileUrl);
      var request = new http.MultipartRequest("POST", uri);
      request.headers.addAll(headers);
      if (_image != null) {
        var stream =
            new http.ByteStream(DelegatingStream.typed(_image!.openRead()));
        var length = await _image!.length();
        var multipartFileIdentityFront = new http.MultipartFile(
            'profile', stream, length,
            filename: basename(_image!.path));
        request.files.add(multipartFileIdentityFront);
      }

      request.fields['full_name'] = fullNameController.text;
      request.fields['email'] = emailIdController.text;
      request.fields['country_code'] = countrycode!;
      request.fields['phone'] = mobileNumberController.text;
      request.fields['gender'] = gender;
      request.fields['dob'] = dateOfBirthController.text;
      request.fields['country'] = country;
      request.fields['state'] = state;
      request.fields['Accept-Language'] =
          jsonEncode(allTranslations.locale.toString());
      request.fields['city'] = cityNameController.text.toString();
      request.fields['latitude'] = Latitude;
      request.fields['longitude'] = Longitude;
      request.fields['language'] = "en";
      request.fields['address'] = address;
      request.fields['all_notification'] = '';
      request.fields['notification_ids'] = attendeesListCommaId.toString();
      request.fields['discovery_mode'] = '1';
      request.fields['tx_pin'] = '';
      var response = await request.send();
      response.stream.transform(utf8.decoder).listen((value) async {
        Map data = jsonDecode(await value);
        String status = data['status'];
        String message = data['message'];
        if (status == success_status) {
          var record = data['record'];
          var image = record['profile'];
          prefs.setString('image', image);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TabBarController(0)),
          );
        } else if (status == unauthorized_status) {
          await checkLoginStatus(context);
        } else if (status == expire_token_status) {
          Map decoded = jsonDecode(await apiRefreshRequest(context));
          setProfileDetail(context);
        } else {
          _showToast(message);
        }
      });
      setState(() {
        dataLoad = false;
      });
    }
  }

  void validateMyPhone(String value, String type) {
    Pattern pattern = r'^\d+(?:\.\d+)?$';
    RegExp regex = new RegExp(pattern.toString());
    if (!regex.hasMatch(value)) {
      setState(() {
        mobileNumberController.text = "";
      });
      _showToast("Please Enter Vaild Phone Number");
    } else {
      return null;
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

  Future<void> addressSearch(context) async {
    LocationResult result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => PlacePicker(googlePlaceKey)));
    Map? decoded = await AddressFindLocation(result);
    setState(() {
      Latitude = decoded!['Latitude'].toString();
      Longitude = decoded['Longitude'].toString();
      city = decoded['city'].toString();
      country = decoded['country'];
      state = decoded['state'].toString();
      address = decoded['shortAddress'].toString();
      cityNameController.text = city;
      countryNameController.text = country;
    });
  }

  Future<void> addressGet() async {
    Map decoded = await getLocation(context) ?? {};
    setState(() {
      Latitude = decoded['Latitude'].toString();
      Longitude = decoded['Longitude'].toString();
      address = decoded['shortAddress'].toString();
      city = decoded['city'].toString();
      state = decoded['state'].toString();
      country = decoded['country'].toString();
      cityNameController.text = city;
      countryNameController.text = country;
    });
  }

  void setToAllTrue(bool value) {
    if (value == true) {
      all_notification = true;
      banking_notification = true;
      security_notification = true;
      shop_notification = true;
      events_notification = true;
      testers_notification = true;
      fashions_notification = true;
      food_notification = true;
      medicines_notification = true;
    } else {
      all_notification = value;
    }
  }

  void setToAllFalse(bool value) {
    if (value == false) {
      all_notification = false;
    }
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
                    child: OutlinedButton(
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(
                              BorderSide(color: AppColours.appTheme)),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)))),
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

  Future getImage(BuildContext context, String imageType) async {
    var pickedFile;
    if (imageType == "camera") {
      pickedFile = await picker.getImage(source: ImageSource.camera);
      Navigator.pop(context);
    } else {
      pickedFile = await picker.getImage(source: ImageSource.gallery);
      Navigator.pop(context);
    }
    setState(() {
      _image = File(pickedFile.path);
    });
  }

  selectedTagsData(context) {
    return dataSet();
  }

  dataSet() {
    if (selectedTagList.length > 0)
      return Padding(
          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Notification Tag",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10.0,
              ),
              Wrap(
                  children: List.generate(selectedTagList.length,
                      (e) => itemsTags(selectedTagList, e))),
            ],
          ));
    else
      return Padding(
        padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
        child: Expanded(
            flex: 9,
            child: Text(
              "Notification Tag",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            )),
      );
  }

  itemsTags(List tagesSelected, int i) {
    return Container(
        margin: EdgeInsets.all(2),
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey[200]!,
            ),
            color: Colors.grey[200],
            borderRadius: BorderRadius.all(Radius.circular(12))),
        child: GestureDetector(
          child: Padding(
              padding: EdgeInsets.fromLTRB(5, 4, 5, 5),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                      color: AppColours.blackColour,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                  text: tagesSelected[i]['name'].toString(),
                  children: [
                    WidgetSpan(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(5.0, 0.0, 2.0, 0.0),
                        child: Icon(
                          Icons.cancel,
                          color: AppColours.appTheme,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          onTap: () {
            setItemList(i);
          },
        ));
  }

  void setItemList(i) {
    setState(() {
      selectedTagList.removeAt(i);
      tagesSelected.removeAt(i);
      if (selectedTagList.length < 1) {
        tags = "";
      }
    });
  }
}
