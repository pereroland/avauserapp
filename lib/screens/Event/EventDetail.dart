import 'dart:convert';
import 'dart:io';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/contactManage/ecityContacts.dart';
import 'package:avauserapp/components/dataLoad/categoryLoad.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/language/languageSelected.dart';
import 'package:avauserapp/components/models/linkEventModel.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/shimmerEffects/imageloadshimmer.dart';
import 'package:avauserapp/components/shimmerEffects/profiledetailshimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'EditEvent.dart';

class EventPageRoute extends StatefulWidget {
  final String eventId;

  const EventPageRoute({Key? key, required this.eventId}) : super(key: key);

  @override
  State<EventPageRoute> createState() => _EventPageRouteState();
}

class _EventPageRouteState extends State<EventPageRoute> {
  var updateEvent = "null";

  List<EventParticipant> eventList = [];
  var internet_connection_mesage = "",
      profilePic = "",
      userId = "",
      descriptionTxt = "",
      eventLocationTxt = "",
      eventLocation = "",
      event_date_time = "",
      event_type = "",
      event_id = "",
      event_title = "",
      adminOrganizerId = "",
      event_latitude = "",
      event_longitude = "",
      event_deep_link = "",
      full_name_organizer = "",
      you = "",
      description = "",
      event_link = "",
      organizer = "",
      access_option = "",
      eventDocument = "",
      eventParticipant = "";
  var data;
  var documentdownload = false;
  var editEventAccess = false;
  var linkShare = false;
  var dataLoad = false;
  late Map myLangData;
  List<String> EventAvailableParticipant = [];
  List<linkEvent> eventLink = [];
  late List categoty_type_list;
  var eventJoint = false;
  late var is_upcomming;

  @override
  void initState() {
    super.initState();
    myLangGet();
  }

  @override
  build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          _onBackPressed();
          return Future.value(false);
        },
        child: Scaffold(
          floatingActionButton: eventJoint
              ? FloatingActionButton.extended(
                  onPressed: () {
                    _showToast(context, allTranslations.text('Please wait'));
                    eventAcceptReject(event_id, "2", userId, context);
                  },
                  icon: Icon(Icons.add_circle),
                  label: Text(allTranslations.text('joinEvent')),
                )
              : SizedBox.shrink(),
          body: dataLoad
              ? SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Stack(
                        children: [
                          Column(
                            children: <Widget>[
                              headerWidget(),
                            ],
                          ),
                          eventWidget(),
                          Padding(
                              padding: EdgeInsets.only(top: 40.0),
                              child: Row(
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(
                                      Icons.arrow_back_ios,
                                      color: AppColours.whiteColour,
                                    ),
                                    onPressed: () {
                                      _onBackPressed();
                                    },
                                  ),
                                  Spacer(
                                    flex: 3,
                                  ),
                                  editEventAccess
                                      ? Expanded(
                                          flex: 1,
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              color: AppColours.whiteColour,
                                            ),
                                            onPressed: () {
                                              editEvent(myLangData, context);
                                            },
                                          ),
                                        )
                                      : SizedBox.shrink()
                                ],
                              ))
                        ],
                      ),
                      eventDetail(),
                    ],
                  ),
                )
              : profileDetail(context),
        ));
  }

  void editEvent(myLang, context) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              EditEvent(myLang, categoty_type_list, context, data)),
    );
    if (result != null) {
      if (mounted)
        setState(() {
          updateEvent = "data";
          eventDetailApi(context);
        });
    }
  }

  Future<void> eventDetailApi(context) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        try {
          final result = await InternetAddress.lookup('google.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            Map map = {"event_id": widget.eventId};
            var urlData = eventDetailUrl + "/" + widget.eventId;
            Map decoded = jsonDecode(await apiRequestMainPage(urlData, map));
            String status = decoded['status'];
            String message = decoded['message'];
            if (status == success_status) {
              setState(() {
                data = decoded['record'];
                event_title = data['title'];
                adminOrganizerId = data['user_id'];
                event_id = data['id'];
                full_name_organizer = data['organizer_name'];
                event_type = data['type'];
                event_date_time = data['start_date_time'];
                var eventDate = data['event_date'];
                var eventTime = data['event_time'];
                eventLocation = data['address'];
                var eventState = data['event_state'];
                var eventCity = data['event_city'];
                event_latitude = data['latitude'];
                event_deep_link = data['event_link'];
                event_longitude = data['longitude'];
                description = data['description'];
                access_option = data['access_option'];
                eventDocument = data['documents'];
                is_upcomming = data['is_upcomming'];
                var urls = data['urls'] as List;
                if (access_option == "1" || access_option == 1) {
                  linkShare = true;
                }
                if (eventDocument == "") {
                  documentdownload = false;
                } else {
                  documentdownload = true;
                }
                var eventUsers = data['participant'] as List;
                List eventImages = data['imgs'];
                event_link = data['event_link'];
                if (eventImages.length == 0) {
                } else {
                  profilePic = eventImages[0];
                }
                eventList = eventUsers
                    .map<EventParticipant>(
                        (json) => EventParticipant.fromJson(json))
                    .toList();
                eventLink = urls
                    .map<linkEvent>((json) => linkEvent.fromJson(json))
                    .toList();
                EventAvailableParticipant = [];
                for (int i = 0; i < eventUsers.length; i++) {
                  var eventUsersID = eventUsers[i]['user_id'];
                  EventAvailableParticipant.add(eventUsersID);
                }
                if (adminOrganizerId == userId) {
                  setState(() {
                    editEventAccess = true;
                    if ('type' == "past") {
                      linkShare = false;
                      editEventAccess = false;
                    }
                  });
                }
                checkForPublicEventJoin();
                dataLoad = true;
              });
            } else if (status == unauthorized_status) {
              await checkLoginStatus(context);
            } else if (status == unauthorized_status) {
              await checkLoginStatus(context);
            } else if (status == "408") {
              Map decoded = jsonDecode(await apiRefreshRequest(context));
              eventDetailApi(context);
            } else {
              _showToast(context, message);
            }
          }
        } on SocketException catch (_) {
          _showToast(context, internet_connection_mesage);
        }
      }
    } on SocketException catch (_) {
      _showToast(context, internet_connection_mesage);
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

  headerWidget() {
    return Container(
      color: AppColours.appTheme,
      height: 250.0,
      width: double.maxFinite,
      child: CachedNetworkImage(
        imageUrl: profilePic,
        placeholder: (context, url) => Image.asset(
          'assets/logo.png',
        ),
        errorWidget: (context, url, error) => Image.asset(
          "assets/logo.png",
        ),
      ),
    );
  }

  eventWidget() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 200.0, 10.0, 0.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          padding: new EdgeInsets.only(top: 0.0),
          child: new Container(
              padding: new EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      dateTimeSet(),
                      Expanded(
                        flex: 1,
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                            child: Container(
                                height: 50,
                                child: VerticalDivider(
                                    color: AppColours.whiteColour))),
                      ),
                      Expanded(
                        flex: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              event_title,
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: AppColours.whiteColour),
                            ),
                            Text(
                              event_type,
                              style: TextStyle(
                                  fontSize: 14.0,
                                  color: AppColours.whiteColour),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: IconButton(
                          icon: Icon(
                            Icons.location_on,
                            color: AppColours.whiteColour,
                          ),
                          onPressed: () {
                            openMapApplication(event_latitude, event_longitude);
                          },
                        ),
                      )
                    ],
                  ),
                  nameSetOrganizerData(),
                  Padding(
                    padding: EdgeInsets.only(bottom: 5.0),
                  ),
                ],
              )),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  AppColours.appgradientfirstColour,
                  AppColours.appgradientsecondColour
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(0.5, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }

  dateTimeSet() {
    String splitDateTime = event_date_time;
    List<String> date = splitDateTime.split(" ");
    return Expanded(
      flex: 6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            date[0],
            style: TextStyle(fontSize: 16.0, color: AppColours.whiteColour),
          ),
          setTimeEvent(date),
        ],
      ),
    );
  }

  eventDetail() {
    return Padding(
        padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10.0),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Text(
                    descriptionTxt,
                    style: TextStyle(
                        color: AppColours.blackColour,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),
                  ),
                ),
                editEventAccess
                    ? Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: Icon(Icons.share),
                          onPressed: () {
                            getDeepLink(context);
                          },
                        ),
                      )
                    : checkLinkShare()
              ],
            ),
            Text(
              description,
              style: TextStyle(
                  color: AppColours.blackColour,
                  fontWeight: FontWeight.normal,
                  fontSize: 14.0),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0),
            ),
            Divider(
              color: AppColours.blacklightLineColour,
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0),
            ),
            Text(
              eventLocationTxt,
              style: TextStyle(
                  color: AppColours.blackColour,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0),
            ),
            Text(
              eventLocation,
              style: TextStyle(
                  color: AppColours.blackColour,
                  fontWeight: FontWeight.normal,
                  fontSize: 14.0),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0),
            ),
            Divider(
              color: AppColours.blacklightLineColour,
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0),
            ),
            documentdownload ? eventDownLoadSection() : SizedBox.shrink(),
            eventsLink(),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Text(
                    eventParticipant,
                    style: TextStyle(
                        color: AppColours.blackColour,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),
                  ),
                ),
                editEventAccess
                    ? Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            attendenceAdd(context, event_id);
                          },
                        ),
                      )
                    : SizedBox.shrink()
              ],
            ),
            ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: eventList.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListData(eventList, index, context);
                }),
          ],
        ));
  }

  Future<void> getDeepLink(context) async {
    Map map = {"user_id": userId, "event_id": event_id};
    Map decoded = jsonDecode(await apiRequestMainPage(GetPrivateLink, map));
    String status = decoded['status'];
    String message = decoded['message'];
    if (status == success_status) {
      String dataLink = decoded['data']['link'];
      dataLink = dataLink + "&id=$event_id";
      Share.share(
          'You are invited to join event ($event_title)' +
              "\n" +
              'Please click the link'
                  "\n" +
              dataLink,
          subject: 'Event Share');
    } else if (status == unauthorized_status) {
      await checkLoginStatus(context);
    } else if (status == "408") {
      jsonDecode(await apiRefreshRequest(context));
      getDeepLink(context);
    } else {
      _showToast(context, message);
    }
  }

  void attendenceAdd(context, eventId) async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => ContactList(
            userAvaiable: EventAvailableParticipant,
            typeList: eventId,
            selectedContact: [],
          ),
          fullscreenDialog: true,
        ));
    if (result == null) {
    } else {
      if (mounted)
        setState(() {
          updateEvent = "data";
          eventDetailApi(context);
        });
    }
  }

  Widget ListData(
      List<EventParticipant> contactslist, int index, BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
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
                                      imageUrl:
                                          contactslist[index].user_profile,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          imageShimmer(context, 48.0),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        "assets/logo.png",
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
                                        setName(contactslist, index),
                                        Text(
                                          contactslist[index].role,
                                          style: TextStyle(
                                            fontSize: 14.0,
                                          ),
                                        )
                                      ],
                                    ))),
                            editEventAccess
                                ? Expanded(
                                    flex: 5,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          15.0, 10.0, 5.0, 10.0),
                                      child: statusManage(contactslist, index),
                                    ))
                                : SizedBox.shrink(),
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
    );
  }

  Future<void> myLangGet() async {
    myLangData = await langTxt(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    categoty_type_list = await callCategoryLoad(context) ?? [];
    event_id = widget.eventId;
    setState(() {
      userId = prefs.getString('id') ?? "";
      internet_connection_mesage = myLangData['internet_connection_mesage'];
      descriptionTxt = myLangData['descriptionTxt'];
      eventLocationTxt = myLangData['eventLocation'];
      eventParticipant = myLangData['eventParticipant'];
      organizer = myLangData['organizer'];
      you = myLangData['you'];
    });
    var check = myLangData['email'];
    eventDetailApi(context);
  }

  setName(List<EventParticipant> contactslist, int index) {
    String name = "";

    if (userId == contactslist[index].user_id) {
      name = you;
      return Text(
        name,
        style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: AppColours.appTheme),
      );
    } else {
      name = contactslist[index].user_name;
      return Text(
        name,
        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      );
    }
  }

  Future<void> openMapApplication(eventLatitude, eventLongitude) async {
    var eventLatitudeData = double.parse(eventLatitude);
    var eventLongitudeData = double.parse(eventLongitude);
    final String googleMapsUrl =
        "comgooglemaps://?center=$eventLatitudeData,$eventLongitudeData";
    final String appleMapsUrl =
        "https://maps.apple.com/?q=$eventLatitudeData,$eventLongitudeData";

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    }
    if (await canLaunch(appleMapsUrl)) {
      await launch(appleMapsUrl, forceSafariVC: false);
    } else {
      throw "Couldn't launch URL";
    }
  }

  nameSetOrganizerData() {
    if (userId == adminOrganizerId) {
      return Text(
        organizer + " : " + you,
        style: TextStyle(fontSize: 14.0, color: AppColours.whiteColour),
      );
    } else {
      return Text(
        organizer + " : " + full_name_organizer,
        style: TextStyle(fontSize: 14.0, color: AppColours.whiteColour),
      );
    }
  }

  setTimeEvent(date) {
    var date1 = date[0];
    if (date1 == "") {
      return Text(
        "NA",
        style: TextStyle(fontSize: 14.0, color: AppColours.whiteColour),
      );
    } else {
      return Text(
        date[1] + " " + date[2],
        style: TextStyle(fontSize: 14.0, color: AppColours.whiteColour),
      );
    }
  }

  checkLinkShare() {
    return Expanded(
      flex: 1,
      child: linkShare
          ? IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                Share.share(
                    'You are invited to join event ($event_title.)' +
                        "\n" +
                        'Please click the link'
                            "\n" +
                        event_deep_link,
                    subject: '');
              },
            )
          : SizedBox.shrink(),
    );
  }

  statusManage(List<EventParticipant> contactslist, int index) {
    /*1= panding 2 =cancel 3 = accepted 4 = cancel by user, 5= remove by users*/
    String text = "";
    if (contactslist[index].status == "1") {
      text = "pending";
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          IconButton(
            onPressed: () {
              _deleteRequest(contactslist, index);
            },
            icon: Icon(Icons.delete),
          ),
          Text(
            text,
            style: TextStyle(color: AppColours.redColour),
          )
        ],
      );
    } else if (contactslist[index].status == "2") {
      text = "";
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[Text(text)],
      );
    } else if (contactslist[index].status == "3") {
      text = "";
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[Text(text)],
      );
    } else if (contactslist[index].status == "4") {
      text = "cancel by user";
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[Text(text)],
      );
    } else if (contactslist[index].status == "5") {
      text = "remove by users";
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[Text(text)],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[Text(text)],
      );
    }
  }

  Future<bool> _deleteRequest(contactslist, index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(allTranslations.text('AreyousureQuestionMark')),
          content: Text(allTranslations.text("") + ' $event_title event'),
          actions: <Widget>[
            MaterialButton(
              elevation: 0.0,
              child: Text(
                'No',
                style: TextStyle(color: AppColours.appTheme),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            MaterialButton(
              elevation: 0.0,
              child: Text(
                'Yes',
                style: TextStyle(color: AppColours.appTheme),
              ),
              onPressed: () {
                Navigator.pop(context);
                removeUser(context, contactslist, index);
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

  Future<void> removeUser(context, contactslist, index) async {
    Map map = {"id": event_id, "attendee_id": contactslist[index].user_id};
    Map decoded = jsonDecode(await apiRequestMainPage(removeAttendeeUrl, map));
    String status = decoded['status'];
    String message = decoded['message'];
    if (status == success_status) {
      _showToast(context, message);
      eventDetailApi(context);
    } else if (status == unauthorized_status) {
      await checkLoginStatus(context);
    } else if (status == "408") {
      Map decoded = jsonDecode(await apiRefreshRequest(context));
      removeUser(context, contactslist, index);
    } else {
      _showToast(context, message);
    }
  }

  eventsLink() {
    if (eventLink.length > 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            allTranslations.text('EventLink'),
            style: TextStyle(
                color: AppColours.blackColour,
                fontWeight: FontWeight.bold,
                fontSize: 16.0),
          ),
          ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: eventLink.length,
              itemBuilder: (BuildContext context, int index) {
                return LinkData(eventLink, index, context);
              }),
          Divider(
            color: AppColours.blacklightLineColour,
          ),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  LinkData(List<linkEvent> eventLink, int index, BuildContext context) {
    return GestureDetector(
        child: Padding(
          padding: EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 2.0),
          child: Text(eventLink[index].name,
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

  _launchURL(Link) async {
    if (Platform.isAndroid) {
      await launch(Link);
    } else if (Platform.isIOS) {
      await launch(Link);
    } else {
      throw 'Could not launch $Link';
    }
  }

  void _onBackPressed() {
    Navigator.pop(context, updateEvent);
  }

  eventDownLoadSection() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: Text(
                  allTranslations.text('eventDocument'),
                  style: TextStyle(
                      color: AppColours.blackColour,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0),
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: Icon(Icons.info_outline),
                  onPressed: () {
                    _launchURL(eventDocument);
                  },
                ),
              )
            ],
          ),
          Divider(
            color: AppColours.blacklightLineColour,
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
        ]);
  }

  void checkForPublicEventJoin() {
    if (EventAvailableParticipant.contains(userId)) {
      eventJoint = false;
    } else {
      if (access_option == "1" ||
          access_option == 1 ||
          access_option == "3" ||
          access_option == 3) {
        if (is_upcomming.toString() == "1") {
          eventJoint = true;
        }
      }
    }
  }

  Future<void> eventAcceptReject(eventId, statusEvent, userId, context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('id');
    });
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        try {
          final result = await InternetAddress.lookup('google.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            Map map = {
              "id": eventId,
              "attendee_id": userId,
              "status": statusEvent
            };
            Map decoded =
                jsonDecode(await apiRequestMainPage(updateAttendee, map));
            String status = decoded['status'];
            String message = decoded['message'];
            if (status == success_status) {
              eventDetailApi(context);
              _calendarEnable(data);
            } else if (status == unauthorized_status) {
              await checkLoginStatus(context);
            } else if (status == data_not_found_status) {
            } else if (status == "408") {
              Map decoded = jsonDecode(await apiRefreshRequest(context));
              eventAcceptReject(eventId, statusEvent, userId, context);
            } else {
              _showToast(context, message);
            }
          }
        } on SocketException catch (_) {
          _showToast(context, internet_connection_mesage);
        }
      }
    } on SocketException catch (_) {
      _showToast(context, internet_connection_mesage);
    }
  }

  Future<bool> _calendarEnable(data) {
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
                EventCalendarAdd(data);
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

  EventCalendarAdd(data) async {
    DateTime tempDateStart = new DateFormat("dd-MM-yyyy hh:mm a")
        .parse(data['start_date_time'].toString().toUpperCase());
    DateTime tempDateEnd = new DateFormat("dd-MM-yyyy hh:mm a")
        .parse(data['end_date_time'].toString().toUpperCase());
    final Event event = Event(
      title: data['title'].toString(),
      description: data['description'].toString(),
      location: data['address'].toString(),
      startDate: tempDateStart,
      endDate: tempDateEnd,
    );
    Add2Calendar.addEvent2Cal(event);
  }
}

/*              "user_name": "user",
                "user_profile": "https://alphaxtech.net/ecity/uploads/user_profile/3a45a1c0-dc38-41da-b371-043b1bd466621952954024793224763.jpg",
                "id": "3",
                "event_id": "3",
                "user_id": "32",
                "status": "2",
                "added_on": "1615977578",
                "update_on": "1615977578",
                "role": "1",
                "calendar_status": "1",
                "user_profile_thumb": "https://alphaxtech.net/ecity/uploads/user_profile/thumb/3a45a1c0-dc38-41da-b371-043b1bd466621952954024793224763.jpg"*/
class EventParticipant {
  var user_name,
      user_profile,
      id,
      event_id,
      user_id,
      status,
      added_on,
      update_on,
      role,
      calendar_status,
      user_profile_thumb;

  /*{userId: 1, first_name: jaydeep,
   full_name: jaydeep sharma, about_me: , role: developer,
  added_on: 11-Feb-2020,
  profile_photo: http://18.218.229.67/ecard/frontend_asset/images/default.png}*/
  EventParticipant._(
      {this.user_name,
      this.user_profile,
      this.id,
      this.event_id,
      this.user_id,
      this.status,
      this.added_on,
      this.update_on,
      this.role,
      this.calendar_status,
      this.user_profile_thumb});

  factory EventParticipant.fromJson(Map<String, dynamic> json) {
    return new EventParticipant._(
        user_name: json['user_name'],
        user_profile: json['user_profile'],
        id: json['id'],
        event_id: json['event_id'],
        user_id: json['user_id'],
        status: json['status'],
        added_on: json['added_on'],
        update_on: json['update_on'],
        role: json['role'],
        calendar_status: json['calendar_status'],
        user_profile_thumb: json['user_profile_thumb']);
  }
}
