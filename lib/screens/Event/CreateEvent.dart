import 'dart:convert';
import 'dart:io';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/contactManage/ecityContacts.dart';
import 'package:avauserapp/components/contactfetch.dart';
import 'package:avauserapp/components/credential.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/models/linkEventModel.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/permission.dart';
import 'package:avauserapp/components/resource/resource.dart';
import 'package:avauserapp/components/shimmerEffects/imageloadshimmer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:place_picker/place_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:add_2_calendar/add_2_calendar.dart';

class CreateEvent extends StatefulWidget {
  final List categoty_type_list;

  CreateEvent(this.categoty_type_list);

  @override
  _CreateEvent createState() => _CreateEvent();
}

class _CreateEvent extends State<CreateEvent> {
  DateTime selectedSourceDate = DateTime.now();
  TimeOfDay selectedSourceTime = TimeOfDay.now();
  String date1 = "";
  var Longitude = "",
      city = "",
      country = "",
      state = "",
      Latitude = "",
      endTime = "",
      startTime = "",
      startDate = "";
  var address = "";
  TextEditingController titleController = new TextEditingController();
  TextEditingController typeController = new TextEditingController();
  TextEditingController typeControllerId = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  TextEditingController dateAndTimeController = new TextEditingController();
  TextEditingController endDateAndTimeController = new TextEditingController();
  TextEditingController addressController = new TextEditingController();
  File? _image;
  ImagePicker picker = ImagePicker();
  var createEvent = "",
      addAImage = "",
      AddAFile = "",
      camera = "",
      gallery = "",
      cancel = "",
      title = "",
      pleaseAddAddress = "",
      pleaseAddAttendees = "",
      type = "",
      meetingAndEvent = "",
      description = "",
      descriptionAboutEvent = "",
      dateAndTime = "",
      StartDateTime = "",
      EndDateTime = "",
      attendees = "",
      please_select_title = "",
      please_enter_type = "",
      please_enter_description = "",
      please_select_dateAndTime = "",
      EndDateTimemustbeGreaterthanStartDateTime = "",
      please_add_image = "",
      Public = "",
      fileSizeCheck = "",
      AddALink = "",
      Private = "",
      EventType = "";
  var eventCreate = false;
  String attendeesListCommaId = "";
  File? fileNormalfront, filePickedUser;
  Future<File>? imageFile;
  String? base64Image;
  List<ContactListJson> contactslistSelected = [];
  var contactAvailable = false;
  var addressHint = "";
  String _leaveTypeSet = "no data";
  List<DropdownMenuItem<String>> _dropDownMenuItems = [];
  var access_option = "2";
  int? minute1, selectedRadio, hour1, minute, hour;
  var dialogEnable = false;
  var filePicked = false;
  var fileName = "";
  List<linkEvent> eventLink = [];
  List linkUrlList = [];

  @override
  void initState() {
    super.initState();
    selectedRadio = 2;
    _dropDownMenuItems = getDropDownMenuItems();
    _leaveTypeSet = _dropDownMenuItems[0].value!;
  }

  setSelectedRadio(int? val) {
    setState(() {
      selectedRadio = val!;
    });
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = [];
    for (int i = 0; i < widget.categoty_type_list.length; i++) {
      typeControllerId.text = widget.categoty_type_list[i]['id'];
      var name = widget.categoty_type_list[i]['name'];
      items.add(new DropdownMenuItem(value: name, child: new Text(name)));
    }
    return items;
  }

  void changedDropDownItem(String selectedCity) {
    setState(() {
      _leaveTypeSet = selectedCity;
      typeController.text = selectedCity;
      for (int i = 0; i < widget.categoty_type_list.length; i++) {
        if (widget.categoty_type_list[i]['name'] == selectedCity) {
          typeControllerId.text = widget.categoty_type_list[i]['id'];
        }
      }
    });
  }

  Future<bool> _calendarEnable(context) {
    showDialog(
      builder: (context) {
        return AlertDialog(
          title: Text(allTranslations.text('AreyousureQuestionMark')),
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
      context: context,
    );
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () async {
          _onBackPressed(context);
          return Future.value(false);
        },
        child: Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              iconTheme: IconThemeData(color: Colors.black),
              title: Text(
                allTranslations.text('createEvent'),
                style: TextStyle(color: AppColours.appTheme, fontSize: 16.0),
              ),
              centerTitle: true,
              backgroundColor: AppColours.whiteColour,
            ),
            body: SingleChildScrollView(
              child: Column(children: <Widget>[
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
                          child: Text(allTranslations.text('SelectCategory'))),
                      typeFiled(),
                      descriptionFiled(),
                      dateAndTimeFiled(context),
                      endDateAndTimeFiled(context),
                      addressFiled(context),
                      selectAttendees(context),
                      filePick(context),
                      linkPick(context),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            allTranslations.text('addAImage'),
                            style: TextStyle(
                                color: AppColours.blackColour,
                                fontWeight: FontWeight.bold),
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
            )));
  }

  titleFiled() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
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

  typeFiled() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
      child: new Container(
        width: double.infinity,
        height: 45.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black26),
        ),
        child: Container(
          width: double.infinity,
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton(
                value: _leaveTypeSet,
                items: _dropDownMenuItems,
                onChanged: (String? s) {
                  changedDropDownItem(s!);
                },
              ),
            ),
          ),
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
                                        heroTag: "CreateEvent",
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
                        allTranslations.text('createEvent'),
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void disableEnableLoad(bool bool) {
    setState(() {
      eventCreate = bool;
    });
  }

  Upload(BuildContext context) async {
    disableEnableLoad(true);
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authtoken = prefs.getString('authtoken') ?? "";
      Map<String, String> headers = {"authtoken": authtoken};
      var uri = Uri.parse(addEventUrl);
      var request = new http.MultipartRequest("POST", uri);
      request.headers.addAll(headers);
      if (filePickedUser != null) {
        var stream = new http.ByteStream(
            DelegatingStream.typed(filePickedUser!.openRead()));
        var length = await filePickedUser!.length();
        var multipartFileIdentityFront = new http.MultipartFile(
            'documents', stream, length,
            filename: basename(filePickedUser!.path));
        request.files.add(multipartFileIdentityFront);
      }
      if (_image != null) {
        var stream = new http.ByteStream(DelegatingStream(_image!.openRead()));
        var length = await _image!.length();
        var multipartFileIdentityFront = new http.MultipartFile(
            'imgs[]', stream, length,
            filename: basename(_image!.path));
        request.files.add(multipartFileIdentityFront);
      }
      request.fields['title'] = titleController.text;
      request.fields['type'] = '1'; //      typeController.text;
      request.fields['description'] = descriptionController.text;
      request.fields['start_date_time'] = dateAndTimeController.text;
      request.fields['end_date_time'] = endDateAndTimeController.text;
      request.fields['location'] = address;
      request.fields['attendee_id'] = attendeesListCommaId;
      request.fields['country'] = country;
      request.fields['state'] = state;
      request.fields['Accept-Language'] = allTranslations.locale.toString();
      request.fields['city'] = city;
      request.fields['latitude'] = Latitude;
      request.fields['longitude'] = Longitude;
      request.fields['access_option'] = access_option;
      request.fields['category'] = typeControllerId.text;
      request.fields['total_seats'] = '1000';
      request.fields['urls'] = json.encode(linkUrlList);
      var response = await request.send();
      response.stream.transform(utf8.decoder).listen((value) async {
        Map data = jsonDecode(value);
        String status = data['status'];
        String message = data['message'];
        if (status == "200") {
          Navigator.pop(context, "data");
          _calendarEnable(context);
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
    final Event event = Event(
      title: titleController.text,
      description: descriptionController.text,
      location: addressController.text,
      startDate: DateTime(year, month, date, hour ?? 00, minute ?? 00),
      endDate: DateTime(year1, month1, date1, hour1 ?? 00, minute1 ?? 00),
    );
    Add2Calendar.addEvent2Cal(event);
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
      return Hero(
          tag: "speed-dial-hero-tag",
          child: GestureDetector(
            onTap: () {
              openDialog(context);
            },
            child: Icon(
              Icons.image,
              size: 62.0,
            ),
          ));
    } else {
      return Stack(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              child: new Container(
                child: Image.file(
                  _image!,
                  width: 100,
                  height: 100,
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

    /*return FutureBuilder<File>(
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
                    child: Image.file(
                      snapshot.data,
                      width: 100,
                      height: 100,
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
          return Hero(
              tag: "speed-dial-hero-tag",
              child: GestureDetector(
                onTap: () {
                  openDialog(context);
                },
                child: Icon(
                  Icons.image,
                  size: 62.0,
                ),
              ));
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
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0)),
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
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0)),
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
                new SizedBox(
                  width: double.infinity,
                  // height: double.infinity,
                  child: OutlinedButton(
                    style: ButtonStyle(
                        side: MaterialStateProperty.all(
                            BorderSide(color: AppColours.appTheme)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)))),
                    child: Text(allTranslations.text('cancel')),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          );
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
      _image = File(pickedFile.path);
    });
  }

  Future<void> checkValidation(context) async {
    if (titleController.text == "") {
      _showToast(context, allTranslations.text('please_select_title'));
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
    } else if (contactslistSelected.length < 1 && access_option == "2") {
      _showToast(context, allTranslations.text('pleaseAddAttendees'));
    }
    /*  else if (fileNormalfront == null) {
      _showToast(context, please_add_image);
    }*/

    else {
      DateTime tempDateStart = new DateFormat("dd-MM-yyyy hh:mm a")
          .parse(dateAndTimeController.text.toString())
          .toUtc();
      DateTime tempDateEnd = new DateFormat("dd-MM-yyyy hh:mm a")
          .parse(endDateAndTimeController.text.toString())
          .toUtc();

      final difference = tempDateEnd.difference(tempDateStart).inMinutes;
      final startDifference =
          DateTime.now().difference(tempDateStart).inMinutes;
      if (int.parse(difference.toString()) <= 0) {
        _showToast(context,
            allTranslations.text('EndDateTimemustbeGreaterthanStartDateTime'));
      } else if (int.parse(startDifference.toString()) >= 30) {
        _showToast(context,
            allTranslations.text('StartDateTimemustbeGreaterthan30Min'));
      } else {
        Upload(context);
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

  Future<void> _selectStartTime(
      BuildContext context, typeController, type) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedSourceTime,
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
    var permission =
        await requestPermission("Contacts", Permission.contacts, context);
    if (permission) List blanck = [];
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContactList(
                  typeList: 'create',
                  selectedContact: contactslistSelected,
                )));
    if (result != null && result.runtimeType != bool) {
      contactslistSelected = result;
      contactAvailable = true;
      if (mounted) setState(() {});
      setIdAttendees(contactslistSelected);
    } else {
      setState(() {});
      setIdAttendees(contactslistSelected);
    }
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
                                          contactslist[index].email,
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
          decoration: InputDecoration(
            labelText: allTranslations.text('address'),
            hintText: allTranslations.text('address'),
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
      Latitude = result.latLng!.latitude.toString();
      Longitude = result.latLng!.longitude.toString();
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

  void setIdAttendees(result) {
    List<String> data = [];
    for (int i = 0; i < result.length; i++) {
      String id = result[i].id.toString();
      data.add(id);
    }
    attendeesListCommaId = data.join(', ');
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
                                          pickFile(context);
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
        pickFile(context);
        // attendenceAdd(context);
      },
    );
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
                                        addLinkDialog(context);
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
        addLinkDialog(context);
        // attendenceAdd(context);
      },
    );
  }

  Future<void> pickFile(context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        filePickedUser = File(result.files.single.path!);
        int sizeInBytes = filePickedUser!.lengthSync();
        double sizeInMb = sizeInBytes / (1024 * 1024);
        if (sizeInMb > 10) {
          _showToast(context, fileSizeCheck);
        } else {
          setState(() {
            fileName = filePickedUser.toString();
            filePicked = true;
          });
        }
      }
    } catch (e) {}
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

  linkList(List<linkEvent> eventLink, int index, BuildContext context) {
    return GestureDetector(
        child: Padding(
          padding: EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 2.0),
          child: Text(eventLink[index].name,
              overflow: TextOverflow.ellipsis,
              maxLines: 5,
              style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold)),
        ),
        onTap: () {
          _launchURL(eventLink[index].url);
          // do what you need to do when "Click here" gets clicked
        });
  }

  void addLinkDialog(context) {
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
                        if (value != null) {
                          if (value.isEmpty) {
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
              elevation: 0.0,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  linkSave(context, linkNamecontroller, linkUrlcontroller);
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

  void linkSave(
      context, TextEditingController linkName, TextEditingController linkUrl) {
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

  void _onBackPressed(context) {
    Navigator.pop(context, "null");
  }
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
