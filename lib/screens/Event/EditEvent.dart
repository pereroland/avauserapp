import 'dart:convert';
import 'dart:io';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/contactfetch.dart';
import 'package:avauserapp/components/credential.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/models/linkEventModel.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/resource/resource.dart';
import 'package:avauserapp/components/shimmerEffects/imageloadshimmer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:place_picker/place_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class EditEvent extends StatefulWidget {
  List event_type_list;
  var context;
  var data;
  Map myLang;

  EditEvent(this.myLang, this.event_type_list, this.context, this.data);

  @override
  _EditEvent createState() =>
      _EditEvent(myLang, event_type_list, context, data);
}

class _EditEvent extends State<EditEvent> {
  List event_type_list;
  var context;
  var data;
  Map myLang;

  _EditEvent(this.myLang, this.event_type_list, this.context, this.data);

  DateTime selectedSourceDate = DateTime.now();
  TimeOfDay selectedSourceTime = TimeOfDay.now();
  String startTime = "",
      endTime = "",
      date1 = "",
      startDate = "",
      Latitude = "",
      Longitude = "",
      city = "",
      country = "",
      attendeesListCommaId = "",
      imageolddata = "",
      state = "",
      address = "",
      fileName = "",
      AddAFile = "";
  int? hour, minute, hour1, minute1, selectedRadio;
  TextEditingController titleController = new TextEditingController();
  TextEditingController typeController = new TextEditingController();
  TextEditingController typeControllerId = new TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateAndTimeController = TextEditingController();
  TextEditingController endDateAndTimeController = TextEditingController();
  TextEditingController addressController = new TextEditingController();
  bool eventCreate = false;

  File? fileNormalfront;
  File? _image;
  final picker = ImagePicker();
  var event_id;
  Future<File>? imageFile;
  String? base64Image;
  List<ContactListJson> contactslistSelected = [];
  var contactAvailable = false;
  var addressHint = "";
  String _leaveTypeSet = "no data";
  List<DropdownMenuItem<String>>? _dropDownMenuItems;
  var access_option = "2";
  var filePicked = false;
  File? filePickedUser;
  List linkUrlList = [];
  List<linkEvent> eventLink = [];
  List urls = [];

  @override
  void initState() {
    super.initState();
    selectedRadio = 2;
    myLangGet(myLang);
  }

  setSelectedRadio(int? val) {
    setState(() {
      if (val != null) {
        selectedRadio = val;
      }
    });
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = [];

    for (int i = 0; i < widget.event_type_list.length; i++) {
      typeControllerId.text = widget.event_type_list[i]['id'];
      var name = widget.event_type_list[i]['name'];
      items.add(new DropdownMenuItem(value: name, child: new Text(name)));
    }
    return items;
  }

  void changedDropDownItem(String? selectedCity) {
    if (selectedCity != null) {
      setState(() {
        _leaveTypeSet = selectedCity;
        typeController.text = selectedCity;
        for (int i = 0; i < event_type_list.length; i++) {
          if (event_type_list[i]['name'] == selectedCity) {
            typeControllerId.text = event_type_list[i]['id'];
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: AppColours.appTheme,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Text(
            allTranslations.text('editEvent'),
            style: TextStyle(color: AppColours.appTheme, fontSize: 16.0),
          ),
          centerTitle: true,
          backgroundColor: AppColours.whiteColour,
        ),
        body: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: Resource.space.huge,
                      ),
                      titleFiled(),
                      Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
                          child: Text(
                            allTranslations.text('SelectCategory'),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      typeFiled(),
                      descriptionFiled(),
                      dateAndTimeFiled(context),
                      endDateAndTimeFiled(context),
                      addressFiled(context),
                      filePick(context),
                      linkPick(context),

//                  selectAttendees(context),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            allTranslations.text('addAImage'),
                            style: TextStyle(color: AppColours.blackColour),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: showImage(context),
                        ),
                      ),
                      SizedBox(
                        height: Resource.space.xMedium,
                      ),
                      evetType(),
                      SizedBox(
                        height: Resource.space.xMedium,
                      ),
                      saveBtn(context),
                      SizedBox(
                        height: Resource.space.xMedium,
                      ),
                    ],
                  ),
                ),
              ]),
        ));
  }

  evetType() {
    return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
              child: Text(
                allTranslations.text('EventType'),
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Radio(
                        value: 1,
                        groupValue: selectedRadio,
                        onChanged: (int? val) {
                          access_option = "1";
                          setSelectedRadio(val);
                        },
                      ),
                      Text(allTranslations.text('Public'))
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Radio(
                        value: 2,
                        groupValue: selectedRadio,
                        onChanged: (int? val) {
                          access_option = "2";
                          setSelectedRadio(val);
                        },
                      ),
                      Text(allTranslations.text('Private'))
                    ],
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  titleFiled() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
      child: new Container(
        child: TextFormField(
          controller: titleController,
          keyboardType: TextInputType.text,
          //This will obscure text dynamically
          decoration: InputDecoration(
            labelText: allTranslations.text('title'),
            hintText: allTranslations.text('title'),
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

  typeFiled() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
      child: new Container(
        width: double.infinity,
        height: 45.0,
        child: OutlinedButton(
          style: ButtonStyle(
            side: MaterialStateProperty.all(BorderSide(color: Colors.black26)),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          child: Container(
            width: double.infinity,
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton(
                  value: _leaveTypeSet,
                  items: _dropDownMenuItems,
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

  descriptionFiled() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
      child: new Container(
        child: TextFormField(
          maxLines: 5,

          controller: descriptionController,
          keyboardType: TextInputType.text,
          //This will obscure text dynamically
          decoration: InputDecoration(
            alignLabelWithHint: true,
            labelText: allTranslations.text('description'),
            hintText: allTranslations.text('descriptionAboutEvent'),
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

  dateAndTimeFiled(context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
      child: new Container(
        child: TextFormField(
          readOnly: true,
          controller: dateAndTimeController,
          keyboardType: TextInputType.text,
          //This will obscure text dynamically
          onTap: () {
            selectStartDate(context, dateAndTimeController, "1");
          },
          decoration: InputDecoration(
            labelText: allTranslations.text('StartDateTime'),
            hintText: allTranslations.text('StartDateTime'),
            fillColor: Colors.white,
            prefixIcon: Icon(Icons.date_range),
            border: new OutlineInputBorder(
              borderRadius: new BorderRadius.circular(10.0),
              borderSide: new BorderSide(),
            ),
          ),
        ),
      ),
    );
  }

  endDateAndTimeFiled(context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
      child: new Container(
        child: TextFormField(
          readOnly: true,
          controller: endDateAndTimeController,
          keyboardType: TextInputType.text,
          //This will obscure text dynamically
          onTap: () {
            selectStartDate(context, endDateAndTimeController, "2");
          },
          decoration: InputDecoration(
            labelText: allTranslations.text('EndDateTime'),
            hintText: allTranslations.text('EndDateTime'),
            fillColor: Colors.white,
            prefixIcon: Icon(Icons.date_range),
            border: new OutlineInputBorder(
              borderRadius: new BorderRadius.circular(10.0),
              borderSide: new BorderSide(),
            ),
          ),
        ),
      ),
    );
  }

  attendencebox(context) {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 0.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
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
                                flex: 12,
                                child: Text(allTranslations.text('attendees'))),
                            Expanded(
                                flex: 4,
                                child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        15.0, 10.0, 5.0, 10.0),
                                    child: SizedBox(
                                      width: 200.0,
                                      height: 200.0,
                                      child: FloatingActionButton(
                                        heroTag: "editEvent",
                                        onPressed: () {
                                          attendenceAdd(context);
                                        },
                                        child: Icon(Icons.add),
                                        backgroundColor: AppColours.appTheme,
                                      ),
                                    ))),
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
      onTap: () {
        attendenceAdd(context);
      },
    );
  }

  saveBtn(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(22.0, 10.0, 22.0, 12.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: ButtonTheme(
              minWidth: 200.0,
              height: 50.0,
              buttonColor: AppColours.appTheme,
              child: MaterialButton(
                color: AppColours.appTheme,
                elevation: 8.0,
                shape: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColours.appTheme),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                onPressed: () async {
                  if (!eventCreate) checkValidation(context);
                },
                child: eventCreate
                    ? CircularProgressIndicator(
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text(
                        allTranslations.text('editEvent'),
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> myLangGet(myLang) async {
    setState(() {
      _dropDownMenuItems = getDropDownMenuItems();
      _leaveTypeSet = _dropDownMenuItems?[0].value ?? "";
      typeController.text = _leaveTypeSet;
      event_id = data['id'];
      titleController.text = data['title'];
      typeController.text = data['type'];
      dateAndTimeController.text = data['start_date_time'];
      endDateAndTimeController.text = data['end_date_time'];
      startTime = data['start_date_time'];
      endTime = data['end_date_time'];
      address = data['address'];
      country = data['country'];
      state = data['state'];
      city = data['city'];
      linkUrlList = data['urls'] as List;
      Latitude = data['latitude'];
      Longitude = data['longitude'];
      addressController.text = data['address'];
      descriptionController.text = data['description'];
      fileName = data['documents'];
      if (fileName == "") {
      } else {
        fileName = fileName.toString();
        filePicked = true;
      }

      if (data['imgs'].toString().toString().length > 2) {
        imageolddata = data['imgs'][0];
      }
      access_option = data['access_option'];
      if (access_option == "1" || access_option == 1) {
        access_option = "1";
        selectedRadio = 1;
      } else {
        access_option = "2";
        selectedRadio = 2;
      }
      eventLink = linkUrlList
          .map<linkEvent>((json) => linkEvent.fromJson(json))
          .toList();
    });
    selectCategory();
  }

  Upload(BuildContext context) async {
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authtoken = prefs.getString('authtoken') ?? "";
      Map<String, String> headers = {"authtoken": authtoken};
      var uri = Uri.parse(editEventUrl);
      var request = new http.MultipartRequest("POST", uri);
      request.headers.addAll(headers);
      if (_image != null) {
        var stream =
            http.ByteStream(DelegatingStream.typed(_image!.openRead()));
        var length = await _image!.length();
        var multipartFileIdentityFront = http.MultipartFile(
            'imgs[]', stream, length,
            filename: basename(_image!.path));
        request.files.add(multipartFileIdentityFront);
      }
      if (filePickedUser == null) {
//      _showToast(context, please_add_image);
      } else {
        var stream = new http.ByteStream(filePickedUser!.openRead());
        var length = await filePickedUser!.length();
        var multipartFileIdentityFront = new http.MultipartFile(
            'documents', stream, length,
            filename: basename(filePickedUser!.path));
        request.files.add(multipartFileIdentityFront);
      }
/*id:1
title:qewrty
type:2
description:dtesting
start_date_time:21-11-2021 03:51 PM
end_date_time:23-11-2021 02:51 PM
location:India
country:
state:
city:Bhopal
latitude:
longitude:
total_seats:8
category:5
access_option:1
urls:"[↵{"name":"Link-1","url":"http://test.com"},↵{"name":"Link-2","url":"http://test.com"}↵]"*/
      request.fields['id'] = event_id;
      request.fields['title'] = titleController.text;
      request.fields['type'] = typeController.text;
      request.fields['start_date_time'] = dateAndTimeController.text;
      request.fields['end_date_time'] = endDateAndTimeController.text;
      request.fields['location'] = address;
      request.fields['country'] = country;
      request.fields['state'] = state;
      request.fields['Accept-Language'] =
          jsonEncode(allTranslations.locale.toString());
      request.fields['city'] = city;
      request.fields['latitude'] = Latitude;
      request.fields['longitude'] = Longitude;
      request.fields['total_seats'] = "1000";
      request.fields['category'] = typeControllerId.text;
      request.fields['description'] = descriptionController.text;
      request.fields['access_option'] = access_option;
      request.fields['urls'] = json.encode(linkUrlList);
      var response = await request.send();
      response.stream.transform(utf8.decoder).listen((value) async {
        Map data = jsonDecode(value);
        String status = data['status'];
        String message = data['message'];
        if (status == "200") {
          _showToast(context, message);
          Navigator.pop(context, "data");
          _calendarEnable();
        } else if (status == unauthorized_status) {
          await checkLoginStatus(context);
        } else if (status == data_not_found_status) {
        } else if (status == already_login_status) {
          _showToast(context, message);
        } else if (status == "408") {
          jsonDecode(await apiRefreshRequest(context));
          Upload(context);
        } else {
          _showToast(context, message);
        }
      });
      disableEnableLoad(false);
    } else {
      disableEnableLoad(false);
    }
  }

  void _showToast(BuildContext context, String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Widget showImage(context) {
    if (_image == null) {
      return Stack(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              child: new Container(
                width: 64,
                height: 64,
                child: CachedNetworkImage(
                  imageUrl: imageolddata,
                  fit: BoxFit.fill,
                  placeholder: (context, url) => imageShimmer(context, 48.0),
                  errorWidget: (context, url, error) => Image.asset(
                    "Images/userimage.png",
                    fit: BoxFit.cover,
                  ),
                  width: 64,
                  height: 64,
                ),
                padding: const EdgeInsets.all(2.0),
              )),
          Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0.0, 0.0),
              child: Container(
                height: 28.0,
                width: 28.0,
                child: FloatingActionButton(
                  onPressed: () {
                    openDialog(context);
                  },
                  child: Icon(Icons.add),
                  backgroundColor: AppColours.appTheme,
                ),
              ))
        ],
      );
    } else {
      return Stack(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              child: new Container(
                width: 64,
                height: 64,
                child: _image != null
                    ? Image.file(
                        _image!,
                      )
                    : SizedBox.shrink(),
                padding: const EdgeInsets.all(2.0),
              )),
          Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0.0, 0.0),
              child: Container(
                height: 28.0,
                width: 28.0,
                child: FloatingActionButton(
                  onPressed: () {
                    openDialog(context);
                  },
                  child: Icon(Icons.add),
                  backgroundColor: AppColours.appTheme,
                ),
              ))
        ],
      );
    }

    /* return FutureBuilder<File>(
      future: imageFile,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          base64Image = base64Encode(snapshot.data.readAsBytesSync());
          fileNormalfront = snapshot.data;
          return Stack(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  child: new Container(
                    width: 64,
                    height: 64,
                    child: Image.file(
                      snapshot.data,
                    ),
                    padding: const EdgeInsets.all(2.0),
                  )),
              Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0.0, 0.0),
                  child: Container(
                    height: 28.0,
                    width: 28.0,
                    child: FloatingActionButton(
                      onPressed: () {
                        openDialog(context);
                      },
                      child: Icon(Icons.add),
                      backgroundColor: AppColours.appTheme,
                    ),
                  ))
            ],
          );
        } else if (snapshot.error != null) {
          return const Text(
            'Error Picking Image',
            textAlign: TextAlign.center,
          );
        } else {
          return Stack(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  child: new Container(
                    width: 64,
                    height: 64,
                    child: CachedNetworkImage(
                      imageUrl: imageolddata,
                      fit: BoxFit.fill,
                      placeholder: (context, url) =>
                          imageShimmer(context, 48.0),
                      errorWidget: (context, url, error) => Image.asset(
                        "Images/userimage.png",
                        fit: BoxFit.cover,
                      ),
                      width: 64,
                      height: 64,
                    ),
                    padding: const EdgeInsets.all(2.0),
                  )),
              Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0.0, 0.0),
                  child: Container(
                    height: 28.0,
                    width: 28.0,
                    child: FloatingActionButton(
                      onPressed: () {
                        openDialog(context);
                      },
                      child: Icon(Icons.add),
                      backgroundColor: AppColours.appTheme,
                    ),
                  ))
            ],
          );
        }
      },
    );*/
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Text(allTranslations.text('cameraTxt')),
                      onPressed: () async {
                        getImage(context, allTranslations.text('cameraTxt'));
                      },
                      color: AppColours.appTheme,
                      textColor: AppColours.whiteColour,
                      disabledColor: Colors.grey,
                      disabledTextColor: AppColours.blackColour,
                      padding: EdgeInsets.all(8.0),
                      splashColor: AppColours.appTheme,
                    ),
                    MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Text(allTranslations.text('galleryTxt')),
                      onPressed: () {
                        getImage(context, allTranslations.text('galleryTxt'));
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
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      side: MaterialStateProperty.all(
                          BorderSide(color: AppColours.appTheme))),
                  child: Text(allTranslations.text('cancel')),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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
      _image = File(pickedFile.path);
    });
  }

  Future<void> checkValidation(context) async {
    if (titleController.text == "") {
      _showToast(context, allTranslations.text('please_select_title'));
    } else if (typeController.text == "") {
      _showToast(context, allTranslations.text('please_enter_type'));
    } else if (descriptionController.text == "") {
      _showToast(context, allTranslations.text('please_enter_description'));
    } else if (dateAndTimeController.text == "") {
      _showToast(context, allTranslations.text('please_select_dateAndTime'));
    } else if (endDateAndTimeController.text == "") {
      _showToast(context, allTranslations.text('please_select_dateAndTime'));
    } else if (startTime == "") {
      _showToast(context, allTranslations.text('please_select_dateAndTime'));
    } else if (endTime == "") {
      _showToast(context, allTranslations.text('please_select_dateAndTime'));
    } else if (addressController.text == "") {
      _showToast(context, allTranslations.text('pleaseAddAddress'));
    } else {
      try {
        DateTime tempDateStart = new DateFormat("dd-MM-yyyy hh:mm a")
            .parse(dateAndTimeController.text.toString());
        DateTime tempDateEnd = new DateFormat("dd-MM-yyyy hh:mm a")
            .parse(endDateAndTimeController.text.toString());
        final difference = tempDateEnd.difference(tempDateStart).inMinutes;
        if (int.parse(difference.toString()) <= 0) {
          _showToast(
              context,
              allTranslations
                  .text('EndDateTimemustbeGreaterthanStartDateTime'));
        } else {
          disableEnableLoad(true);
          Upload(context);
        }
      } on Exception catch (_) {
        disableEnableLoad(false);
        _showToast(context, allTranslations.text('please_select_dateAndTime'));
      }
    }
  }

  Future<Null> selectStartDate(
      BuildContext context, typeController, type) async {
    var now = new DateTime.now();
    setState(() {
      timeSet(selectedSourceTime, typeController, type);
      startDate = (selectedSourceDate.day).toString() +
          "-" +
          selectedSourceDate.month.toString() +
          "-" +
          selectedSourceDate.year.toString();
      typeController.text = startDate;
      _selectStartTime(context, typeController, type);
    });
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedSourceDate,
        firstDate: DateTime(now.year, now.month, now.day),
        lastDate: DateTime(5000));
    if (picked != null && picked != selectedSourceDate)
      setState(() {
        selectedSourceDate = picked;
        startDate = selectedSourceDate.day.toString() +
            "-" +
            selectedSourceDate.month.toString() +
            "-" +
            selectedSourceDate.year.toString();
        typeController.text = startDate;

        date1 = picked.toString();
      });
  }

  void timeSet(picked, typeController, type) {
    int total;
    String? data;

    if (picked.period.toString().contains("pm")) {
      data = "PM";
    } else if (picked.period.toString().contains("am")) {
      data = "AM";
    }
    int Time;
    Time = int.parse(picked.hour.toString());

    if (Time > 12) {
      total = Time - 12;
    } else if (Time == 12) {
      total = Time;
    } else {
      total = Time;
    }
    setState(() {
      selectedSourceTime = picked;
      String hourData;
      String minData;
      if (total < 10) {
        hourData = "0" + total.toString();
      } else {
        hourData = total.toString();
      }
      if (picked.minute < 10) {
        minData = "0" + picked.minute.toString();
      } else {
        minData = picked.minute.toString();
      }
//        timestart = hourData + ":" + minData;
      if (type == "1") {
        hour = Time;
        minute = int.parse(picked.minute.toString());
        startTime = hourData + ":" + minData + " " + data!;
        typeController.text = startDate + " " + startTime;
      } else {
        hour1 = Time;
        minute1 = int.parse(picked.minute.toString());
        endTime = hourData + ":" + minData + " " + data!;
        typeController.text = startDate + " " + endTime;
      }
    });
  }

  Future<void> _selectStartTime(
      BuildContext context, typeController, type) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      timeSet(picked, typeController, type);
    }
  }

  void attendenceAdd(context) async {
    /*  Navigator.push(
        context, MaterialPageRoute(builder: (context) => EcardContacts()));
*/
    /* var result = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (BuildContext context) => new EcardContacts(context),
          fullscreenDialog: true,
        ));
    if (result == null) {
    } else {
      setState(() {
        contactslistSelected = result;
        contactAvailable = true;
        setIdAttendees(contactslistSelected);
      });
    }*/
  }

  EcardContactSeletedList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: contactslistSelected.length,
            itemBuilder: (BuildContext context, int index) {
              return ListData(contactslistSelected, index, context);
            })
      ],
    );
  }

  Widget ListData(
      List<ContactListJson> contactslist, int index, BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
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
                                          contactslist[index].user_type,
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

  selectAttendees(BuildContext context) {
    return Column(
      children: <Widget>[
        contactAvailable ? EcardContactSeletedList() : SizedBox.shrink(),
        attendencebox(context),
      ],
    );
  }

  addressFiled(context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
      child: new Container(
        child: TextFormField(
          readOnly: true,
          onTap: () {
            addressSearch(context);
          },
          controller: addressController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          //This will obscure text dynamically
          // This will obscure text dynamically
          decoration: InputDecoration(
            labelText: allTranslations.text("address"),
            hintText: allTranslations.text("address"),
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

  Future<void> addressSearch(BuildContext context) async {
    LocationResult result = await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => PlacePicker(googlePlaceKey)));
    Map decoded = await AddressFilter(result);
    setState(() {
      if (result != null) {
        Latitude = result.latLng!.latitude.toString();
        Longitude = result.latLng!.longitude.toString();
      }
      city = decoded['city'].toString();
      country = decoded['country'].toString();
      state = decoded['state'].toString();
      address = decoded['Address'].toString();
      addressController.text = address;
    });

/*    LocationResult result = await showLocationPicker(context, googlePlaceKey);

*/ /*    Prediction p = await PlacesAutocomplete.show(
        context: context,
        apiKey: Strings.kGoogleApiKey,
        mode: Mode.fullscreen,
        // Mode.fullscreen
        language: "en",
        components: []);
   */ /*
    Map decoded = await AddressFindLocation(result.address);
    setState(() {
      Latitude = result.latLng.latitude.toString();
      Longitude = result.latLng.longitude.toString();
      city = decoded['city'].toString();
      country = decoded['country'].toString();
      state = decoded['state'].toString();
      address = decoded['Address'].toString();
      addressController.text = address;
    });*/
  }

  Future<bool> _calendarEnable() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(allTranslations.text('Are_you_sure')),
          content:
              Text(allTranslations.text('DoyouwanttoAddThisEventinCalendar')),
          actions: <Widget>[
            MaterialButton(
              elevation: 0.0,
              child: Text(
                allTranslations.text('no'),
                style: TextStyle(color: AppColours.appTheme),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            MaterialButton(
              elevation: 0.0,
              child: Text(
                allTranslations.text('yes'),
                style: TextStyle(color: AppColours.appTheme),
              ),
              onPressed: () {
                Navigator.pop(context);
                EventCalendarAdd();
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

  EventCalendarAdd() async {
    var dateTime = dateAndTimeController.text.toString().split(" ").toList();
    var dateData = dateTime[0].split("-").toList();
    // var timeData = dateTime[0].split(" ").toList();
    var date = int.parse(dateData[0].toString());
    var month = int.parse(dateData[1].toString());
    var year = int.parse(dateData[2].toString());
    var dateTime1 =
        endDateAndTimeController.text.toString().split(" ").toList();
    var dateData1 = dateTime1[0].split("-").toList();
    // var timeData1 = dateTime1[0].split(" ").toList();
    var date1 = int.parse(dateData1[0].toString());
    var month1 = int.parse(dateData1[1].toString());
    var year1 = int.parse(dateData1[2].toString());
    int idx1 = dateAndTimeController.text.toString().indexOf(" ");
    List parts1 = [
      dateAndTimeController.text.toString().substring(0, idx1).trim(),
      dateAndTimeController.text.toString().substring(idx1 + 1).trim()
    ];
    var time1 = parts1[1].toString().split(" ");
    var time11 = time1[0].toString().split(":");
    hour = int.parse(time11[0].toString());
    minute = int.parse(time11[1].toString());
    int idx2 = endDateAndTimeController.text.toString().indexOf(" ");
    List parts2 = [
      endDateAndTimeController.text.toString().substring(0, idx2).trim(),
      endDateAndTimeController.text.toString().substring(idx2 + 1).trim()
    ];
    var time2 = parts2[1].toString().split(" ");
    var time22 = time2[0].toString().split(":");
    hour1 = int.parse(time22[0].toString());
    minute1 = int.parse(time22[1].toString());
    final Event event = Event(
      title: titleController.text,
      description: descriptionController.text,
      location: addressController.text,
      startDate: DateTime(year, month, date, hour!, minute!),
      endDate: DateTime(year1, month1, date1, hour1!, minute1!),
    );
    Add2Calendar.addEvent2Cal(event);
  }

  filePick(context) {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 0.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 2,
          child: new Container(
            height: 62,
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
                            filePicked
                                ? Expanded(flex: 12, child: Text(fileName))
                                : Expanded(
                                    flex: 12,
                                    child:
                                        Text(allTranslations.text('AddAFile'))),
                            Expanded(
                                flex: 4,
                                child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        15.0, 10.0, 5.0, 10.0),
                                    child: SizedBox(
                                      width: 200.0,
                                      height: 200.0,
                                      child: FloatingActionButton(
                                        heroTag: "filePick",
                                        onPressed: () {
                                          pickFile();
                                        },
                                        child: Icon(Icons.attach_file),
                                        backgroundColor: AppColours.appTheme,
                                      ),
                                    ))),
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
      onTap: () {
        attendenceAdd(context);
      },
    );
  }

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        filePickedUser = File(result.files.single.path!);
      }
      int sizeInBytes = filePickedUser!.lengthSync();
      double sizeInMb = sizeInBytes / (1024 * 1024);
      if (sizeInMb > 10) {
        _showToast(context, allTranslations.text('fileSizeCheck'));
      } else {
        setState(() {
          fileName = filePickedUser.toString();
          filePicked = true;
        });
      }
    } catch (e) {}
  }

  linkPick(context) {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 0.0),
        child: Container(
          padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 26,
                child: Container(
                  child: Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(flex: 12, child: listLink()),
                          Expanded(
                              flex: 4,
                              child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      15.0, 10.0, 5.0, 10.0),
                                  child: SizedBox(
                                    width: 40.0,
                                    height: 40.0,
                                    child: FloatingActionButton(
                                      heroTag: "",
                                      onPressed: () {
                                        addLinkDialog();
                                      },
                                      child: Icon(Icons.link),
                                      backgroundColor: AppColours.appTheme,
                                    ),
                                  ))),
                        ],
                      )),
                ),
              )
            ],
          ),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.all(Radius.circular(15))),
        ),
      ),
      onTap: () {
        attendenceAdd(context);
      },
    );
  }

  void addLinkDialog() {
    TextEditingController linkNamecontroller = TextEditingController();
    TextEditingController linkUrlcontroller = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(allTranslations.text('Insertlink')),
          content: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      validator: (value) {
                        if (value != null) {
                          if (value.isEmpty) {
                            return allTranslations
                                .text('PleaseenterTexttodisplay');
                          }
                        }
                        return null;
                      },
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      controller: linkNamecontroller,
                      //This will obscure text dynamically
                      decoration: InputDecoration(
                        hintText: allTranslations.text('TextTodisplay'),
                        fillColor: Colors.white,
                      ),
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null) {
                          return allTranslations.text('PleaseenterLinkUrl');
                        } else if (value.isEmpty) {
                          return allTranslations.text('PleaseenterLinkUrl');
                        } else {
                          bool linkValid = RegExp(
                                  r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+')
                              .hasMatch(linkUrlcontroller.text.toString());

                          if (linkValid == true) {
                            if (linkUrlcontroller.text
                                    .toString()
                                    .contains("https://") ||
                                linkUrlcontroller.text
                                    .toString()
                                    .contains("http://")) {
                              return null;
                            } else {
                              return allTranslations
                                  .text('PleaseentervalidLinkUrl');
                            }
                          } else {
                            return allTranslations
                                .text('PleaseentervalidLinkUrl');
                          }
                        }
                      },
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      controller: linkUrlcontroller,
                      //This will obscure text dynamically
                      decoration: InputDecoration(
                        hintText: allTranslations.text('LinkUrl'),
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                )),
          ),
          actions: <Widget>[
            MaterialButton(
              child: Text(
                'Add',
                style: TextStyle(color: AppColours.appTheme),
              ),
              onPressed: () {
//                    Navigator.pop(context);
                if (_formKey.currentState!.validate()) {
                  linkSave(linkNamecontroller, linkUrlcontroller);
                }
              },
            )
          ],
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0)),
        );
      },
    );
  }

  listLink() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 5.0),
          child: Text(
            allTranslations.text('AddALink'),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: eventLink.length,
            itemBuilder: (BuildContext context, int index) {
              return linkList(eventLink, index, context);
            })
      ],
    );
  }

  void linkSave(TextEditingController linkName, TextEditingController linkUrl) {
    var linkData = {
      "name": linkName.text.toString(),
      "url": linkUrl.text.toString(),
    };
    linkUrlList.add(linkData);
    setState(() {
      eventLink = linkUrlList
          .map<linkEvent>((json) => linkEvent.fromJson(json))
          .toList();
    });
    Navigator.pop(context);
  }

  linkList(List<linkEvent> eventLink, int index, BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: GestureDetector(
                child: Text(eventLink[index].name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 5,
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold)),
                onTap: () {
                  _launchURL(eventLink[index].url);
                },
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  removeLink(index);
                });
              },
              icon: Icon(
                Icons.delete,
              ),
            )
          ],
        ));
  }

  _launchURL(linkUrl) async {
    if (Platform.isAndroid) {
      await launch(linkUrl);
    } else if (Platform.isIOS) {
      await launch(linkUrl);
    } else {
      throw 'Could not launch $linkUrl';
    }
  }

  void removeLink(index) {
    linkUrlList = [];
    eventLink.removeAt(index);
    if (eventLink.length > 0) {
      for (int i = 0; i < eventLink.length; i++) {
        var data = {
          "name": eventLink[i].name.toString(),
          "url": eventLink[i].url.toString(),
        };
        linkUrlList.add(data);
      }
    }
  }

  void disableEnableLoad(bool bool) {
    setState(() {
      eventCreate = bool;
    });
  }

  void selectCategory() {
    setState(() {
      for (int i = 0; i < event_type_list.length; i++) {
        if (event_type_list[i]['id'] == data['category'].toString()) {
          typeControllerId.text = event_type_list[i]['id'];
          _leaveTypeSet = event_type_list[i]['name'];
          typeController.text = event_type_list[i]['name'];
        }
      }
    });
  }
}
