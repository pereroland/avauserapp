import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/dataLoad/categoryLoad.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/shimmerEffects/ListShimmer.dart';
import 'package:avauserapp/screens/home/baseTabClass.dart';
import 'package:avauserapp/screens/notification/NotificationTab.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'CreateEvent.dart';
import 'EventDetail.dart';

class EventDetail extends StatefulWidget {
  String? eventId;

  EventDetail({this.eventId});

  @override
  _EventDetail createState() => _EventDetail();
}

class _EventDetail extends State<EventDetail>
    with AutomaticKeepAliveClientMixin<EventDetail> {
  var dataLoad = false;
  var STORES = "";
  Map? myLang;
  bool isLoadingOnFirst = true;
  bool apiRun = false;
  List categoty_type_list = [];
  var userId = "",
      profilePic = "",
      userFullName = "",
      userEmail = "",
      userImage = "";
  var welcomeTxtheaderDetail = "",
      firstName = "",
      lastName = "",
      userName = "",
      userRole = "",
      contactfetch = "",
      internet_connection_mesage = "",
      StartDateTime = "",
      EndDateTime = "",
      accept = "",
      reject = "",
      pending = "",
      all = "",
      upcoming = "",
      past = "";
  var data_not_found = true;
  List<EventList> listRemain = [];
  List<EventList> list = [];
  List<EventList> listhistory = [];
  var remainEventShow = false;
  var allEventsShow = false;
  var allHistoryEventsShow = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var refreshEventStatus = false;
  String appName = "";
  var drawerOpen = false;
  String? idAcceptReject;
  String isAccept = "1";

  @override
  void initState() {
    super.initState();
    myLangGet();
    eventListPending(true);
    eventFetch();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        drawer: drawerOpen
            ? drawerData(
                context, userId, profilePic, userFullName, userEmail, userImage)
            : Text("CreateEvent"),
        floatingActionButton: FloatingActionButton(
          heroTag: "CreateEvent",
          onPressed: () {
            if (apiRun) {
              _showToast(context, "Wait Data Load In Progress!!");
            } else {
              attendenceAdd(context);
            }
          },
          child: Icon(Icons.add),
          backgroundColor: AppColours.appTheme,
        ),
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationTabs()),
                );
              },
              icon: Icon(
                Icons.notifications_active,
                color: AppColours.appTheme,
              ),
            )
          ],
          title: Text(
            allTranslations.text('Event'),
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
            child: dataLoad
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      remainEventShow
                          ? Padding(
                              padding:
                                  EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 0.0),
                              child: Text(allTranslations.text('pending')))
                          : SizedBox.shrink(),
                      remainEventShow
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: listRemain.length,
                              itemBuilder: (BuildContext context, int index) {
                                return eventListItem(
                                    listRemain, index, context, "pending");
                              })
                          : SizedBox.shrink(),
                      allEventsShow
                          ? Padding(
                              padding:
                                  EdgeInsets.fromLTRB(20.0, 20.0, 10.0, 0.0),
                              child: Text(allTranslations.text('upcoming')))
                          : SizedBox.shrink(),
                      ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: list.length,
                          itemBuilder: (BuildContext context, int index) {
                            return eventListItem(
                                list, index, context, "upcoming");
                          }),
                      allHistoryEventsShow
                          ? Padding(
                              padding:
                                  EdgeInsets.fromLTRB(20.0, 20.0, 10.0, 0.0),
                              child: Text(past))
                          : SizedBox.shrink(),
                      ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: listhistory.length,
                          itemBuilder: (BuildContext context, int index) {
                            return eventListItem(
                                listhistory, index, context, "past");
                          })
                    ],
                  )
                : Container(
                    color: AppColours.whiteColour,
                    child: data_not_found
                        ? SingleChildScrollView(
                            physics: NeverScrollableScrollPhysics(),
                            child: Column(
                              children: <Widget>[
                                listShimmer(context),
                                listShimmer(context),
                                listShimmer(context),
                                listShimmer(context),
                                listShimmer(context),
                                listShimmer(context),
                                listShimmer(context),
                                listShimmer(context),
                                listShimmer(context),
                                listShimmer(context),
                                listShimmer(context),
                                listShimmer(context),
                                listShimmer(context),
                              ],
                            ),
                          )
                        : Container(
                            height: MediaQuery.of(context).size.height,
                            color: AppColours.whiteColour,
                            child: Center(
                              child: Image.asset(
                                "assets/no_event_found.webp",
                                height: MediaQuery.of(context).size.height / 2,
                              ),
                            ),
                          ),
                  )));
  }

  refreshContact() {
    return refreshEventStatus
        ? Padding(
            padding: EdgeInsets.fromLTRB(14.0, 14.0, 12.0, 14.0),
            child: SizedBox(
              child: CircularProgressIndicator(),
              height: 20.0,
              width: 30.0,
            ),
          )
        : IconButton(
            onPressed: () {
              setState(() {
                refreshEventStatus = true;
                eventListPending(true);
              });
            },
            icon: Icon(
              Icons.refresh,
              size: 35.0,
              color: AppColours.appTheme,
            ),
          );
    /**/
  }

  void attendenceAdd(context) async {
    var result = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (BuildContext context) =>
              new CreateEvent(categoty_type_list),
          fullscreenDialog: true,
        ));
    if (result == null || result == "null") {
    } else {
      if (mounted)
        setState(() {
          eventListPending(true);
        });
    }
  }

  eventListItem(list, index, context, type) {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            padding: new EdgeInsets.only(top: 0.0),
            child: new Container(
                padding: new EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                child: Row(
                  children: <Widget>[
                    dateTimeSet(list, index),
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
                      child: detailOpen(list, index, type),
                    ),
                  ],
                )),
            decoration: new BoxDecoration(
              gradient: new LinearGradient(
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
      ),
      onTap: () {
        editEvent(list, index, type, context);
      },
    );
  }

  void editEvent(List<EventList> list, index, type, context) async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EventPageRoute(eventId: list[index].id.toString())));
    if (result == null || result == "null") {
    } else {
      if (mounted)
        setState(() {
          eventListPending(true);
        });
    }
  }

  textClickShowAcceptReject(list, index) {
    return Padding(
      padding: EdgeInsets.only(left: 5.0),
      child: Column(
        children: <Widget>[
          MaterialButton(
            color: Colors.white,
            elevation: 0.0,
            shape: new RoundedRectangleBorder(
                side: BorderSide(
                    color: AppColours.appTheme, style: BorderStyle.solid),
                borderRadius: new BorderRadius.circular(10.0)),
            textColor: AppColours.appTheme,
            padding: EdgeInsets.all(8.0),
            onPressed: () {
              if (idAcceptReject == null)
                eventAcceptReject(list[index].id, "2", list[index]);
            },
            child:
                isAccept == "2" && idAcceptReject == list[index].id.toString()
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      )
                    : Text(
                        allTranslations.text('accept'),
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
          ),
          MaterialButton(
            elevation: 0.0,
            color: Colors.white,
            shape: new RoundedRectangleBorder(
                side: BorderSide(
                    color: AppColours.redColour, style: BorderStyle.solid),
                borderRadius: new BorderRadius.circular(10.0)),
            textColor: AppColours.redColour,
            padding: EdgeInsets.all(8.0),
            onPressed: () {
              if (idAcceptReject == null)
                eventAcceptReject(list[index].id, "3", list[index]);
            },
            child:
                isAccept == "3" && idAcceptReject == list[index].id.toString()
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      )
                    : Text(
                        allTranslations.text('reject'),
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
          )
        ],
      ),
    );
  }

// Future<bool> _calendarEnable(list, index) {
//   return showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: Text('Are you sure?'),
//         content: Text('Do you want to Add This Event in Calendar'),
//         actions: <Widget>[
//           MaterialButton(
//             child: Text(
//               'No',
//               style: TextStyle(color: AppColours.appTheme),
//             ),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//           MaterialButton(
//             child: Text(
//               'Yes',
//               style: TextStyle(color: AppColours.appTheme),
//             ),
//             onPressed: () {
//               Navigator.pop(context);
//               EventCalendarAdd(list, index);
//             },
//           )
//         ],
//         shape: new RoundedRectangleBorder(
//             borderRadius: new BorderRadius.circular(10.0)),
//       );
//     },
//   ) ??
//       false;
// }
// Future<bool> _deleteEventEnable(eventId) {
//   return showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: Text('Are you sure?'),
//         content: Text('Do you want to Delete This Event'),
//         actions: <Widget>[
//           MaterialButton(
//             child: Text(
//               'No',
//               style: TextStyle(color: AppColours.appTheme),
//             ),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//           MaterialButton(
//             child: Text(
//               'Yes',
//               style: TextStyle(color: AppColours.appTheme),
//             ),
//             onPressed: () {
//               Navigator.pop(context);
//               eventDeleteReject(eventId);
//             },
//           )
//         ],
//         shape: new RoundedRectangleBorder(
//             borderRadius: new BorderRadius.circular(10.0)),
//       );
//     },
//   ) ??
//       false;
// }
// EventCalendarAdd(list, index) async {
//   DateTime tempDateStart = new DateFormat("dd-MM-yyyy hh:mm:ss a")
//       .parse(list[index].event_date_time.toString().toUpperCase());
//   DateTime tempDateEnd = new DateFormat("dd-MM-yyyy hh:mm:ss a")
//       .parse(list[index].event_end_date_time.toString().toUpperCase());
//   final Event event = Event(
//     title: list[index].event_title.toString(),
//     description: list[index].description.toString(),
//     location: list[index].event_location.toString(),
//     startDate: tempDateStart,
//     endDate: tempDateEnd,
//   );
//   Add2Calendar.addEvent2Cal(event);
// }

  Future<void> myLangGet() async {
    categoty_type_list = await callCategoryLoad(context) ?? [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted)
      setState(() {
        userEmail = prefs.getString('email') ?? "";
        userId = prefs.getString('id') ?? "";
        userFullName = prefs.getString('full_name') ?? "";
        userImage = prefs.getString('image') ?? "";
        drawerOpen = true;
      });
  }

  Future<void> eventList(bool loadingShow) async {
    if (loadingShow) {
      list = [];
      listhistory = [];
    }
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        try {
          final result = await InternetAddress.lookup('google.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty && mounted) {
            Map map = {
              "page_no": "",
              "search": "",
              "category": "",
              "pending": "1"
            };
            Map decoded =
                jsonDecode(await apiRequestMainPage(eventListUrl, map));
            String status = decoded['status'];
            String message = decoded['message'];
            if (status == success_status) {
              var data = decoded['record']['upcommings'];
              var history = decoded['record']['pendings'];
              if (mounted)
                setState(() {
                  list = data
                      .map<EventList>((json) => EventList.fromJson(json))
                      .toList();
                  // listhistory = history
                  //     .map<EventList>((json) => EventList.fromJson(json))
                  //     .toList();
                });
            } else {
              // _showToast(context, message);
            }
            if (mounted)
              setState(() {
                if (list.length > 0) {
                  allEventsShow = true;
                } else {
                  allEventsShow = false;
                }
                if (listhistory.length > 0) {
                  allHistoryEventsShow = true;
                } else {
                  allHistoryEventsShow = false;
                }
                if (data_not_found) {
                  dataLoad = true;
                  refreshEventStatus = false;
                }
                if (list.length == 0 &&
                    listRemain.length == 0 &&
                    listhistory.length == 0) {
                  dataLoad = false;
                  data_not_found = false;
                }
              });
          }
        } on SocketException catch (_) {
          // _showToast(context, internet_connection_mesage);
        }
      }
    } on SocketException catch (_) {
      // _showToast(context, internet_connection_mesage);
    }
  }

  Future<void> eventAcceptReject(event_id, statusEvent, EventList data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('id') ?? "";
    });
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Map map = {
          "id": event_id,
          "attendee_id": userId,
          "status": statusEvent
        };
        idAcceptReject = event_id.toString();
        isAccept = statusEvent;
        if (mounted) setState(() {});
        Map decoded = jsonDecode(await apiRequestMainPage(updateAttendee, map));
        idAcceptReject = null;
        isAccept = "1";
        String status = decoded['status'];
        String message = decoded['message'];
        if (status == success_status) {
          if (statusEvent == "2") await _calendarEnable(context, data);
          eventListPending(true);
        } else if (status == unauthorized_status) {
          await checkLoginStatus(context);
        } else if (status == data_not_found_status) {
        } else if (status == "408") {
          jsonDecode(await apiRefreshRequest(context));
          eventAcceptReject(event_id, statusEvent, data);
        } else {
          _showToast(context, message);
        }
      }
    } on SocketException catch (_) {
      idAcceptReject = null;
      isAccept = "1";
      if (mounted) setState(() {});
      _showToast(context, internet_connection_mesage);
    }
  }

  Future<bool> _calendarEnable(context, EventList data) {
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
              onPressed: () async {
                Navigator.pop(context);
                await EventCalendarAdd(data);
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

  EventCalendarAdd(EventList eventList) async {
    var dateTime = eventList.start_date_time.toString().split(" ").toList();
    var dateData = dateTime[0].split("-").toList();
    var date = int.parse(dateData[0].toString());
    var month = int.parse(dateData[1].toString());
    var year = int.parse(dateData[2].toString());
    var timeData = dateTime[1].split(":");
    var minute = int.parse(timeData[1]);
    var hour = int.parse(timeData.first);
    var dateTime1 = eventList.end_date_time.toString().split(" ").toList();
    var dateData1 = dateTime1[0].split("-").toList();
    var date1 = int.parse(dateData1[0].toString());
    var month1 = int.parse(dateData1[1].toString());
    var year1 = int.parse(dateData1[2].toString());
    var timeData1 = dateTime1[1].split(":");
    var minute1 = int.parse(timeData1[1]);
    var hour1 = int.parse(timeData1.first);
    final Event event = Event(
      title: eventList.title,
      description: eventList.description,
      location: eventList.address,
      startDate: DateTime(year, month, date, hour, minute),
      endDate: DateTime(year1, month1, date1, hour1, minute1),
    );
    Add2Calendar.addEvent2Cal(event);
  }

  Future<void> eventListPending(bool loadingCheck) async {
    if (loadingCheck) {
      listRemain = [];
      isLoadingOnFirst = false;
    }
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        try {
          final result = await InternetAddress.lookup('google.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            if (loadingCheck) {
              apiRun = true;
              setState(() {});
            }
            Map map = {"user_id": userId, "limit": "", "start": ""};
            Map decoded =
                jsonDecode(await apiRequestMainPage(fetchPendingEvent, map));
            if (mounted && loadingCheck) {
              apiRun = false;
              if (mounted) setState(() {});
            }
            String status = decoded['status'];
            if (status == success_status) {
              List data = decoded['record'];
              if (loadingCheck) {
                if (data.length > 0) {
                  listRemain = data
                      .map<EventList>((json) => EventList.fromJson(json))
                      .toList();
                }
              } else {
                var dataLoad = data
                    .map<EventList>((json) => EventList.fromJson(json))
                    .toList();
                listRemain = dataLoad;
              }
            }
            if (mounted)
              setState(() {
                if (listRemain.length > 0) {
                  remainEventShow = true;
                } else {
                  remainEventShow = false;
                }
                eventList(loadingCheck);
              });
          }
        } on SocketException catch (_) {
          // _showToast(context, internet_connection_mesage);
        }
      }
    } on SocketException catch (_) {
      // _showToast(context, internet_connection_mesage);
    }
  }

  Future<void> eventFetch() async {
    if (mounted)
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) eventListPending(false);
        if (mounted) eventFetch();
      });
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

  dateTimeSet(list, index) {
    String splitDateTime = list[index].start_date_time;
    List<String> date = splitDateTime.split(" ");
    return Expanded(
      flex: 6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          dateSplit(date),
          setTimeEvent(date),
        ],
      ),
    );
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

  dateSplit(date) {
    return Text(
      date[0],
      style: TextStyle(fontSize: 16.0, color: AppColours.whiteColour),
    );
  }

  detailOpen(List<EventList> list, index, type) {
    var acceptReject = false;
    var pastEvent = false;
    if (list[index].event_user_status == "1") {
      acceptReject = true;
    } else {
      acceptReject = false;
    }
    if (type == "past") {
      pastEvent = true;
    }
    return Row(
      children: <Widget>[
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.eventId == list[index].id.toString()
                    ? list[index].title + " (New)"
                    : list[index].user_id == userId
                        ? list[index].title + " (Owner)"
                        : list[index].title,
                style: TextStyle(fontSize: 16.0, color: AppColours.whiteColour),
              ),
              Text(
                list[index].description,
                style: TextStyle(
                  fontSize: 14.0,
                  color: AppColours.whiteColour,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
        acceptReject
            ? Expanded(
                flex: 4,
                child: textClickShowAcceptReject(list, index),
              )
            : SizedBox.shrink(),
        pastEvent
            ? Expanded(
                flex: 1,
                child: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: AppColours.whiteColour,
                  ),
                  onPressed: () {
                    // _deleteEventEnable(list[index].eventId);
                  },
                ),
              )
            : SizedBox.shrink(),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

/*class EventList {
  final String eventId,
      user_id,
      event_title,
      event_type,
      event_date_time,
      event_end_date_time,
      event_location,
      description,
      contactId,
      event_status,
      added_on,
      update_on,
      event_user_status;
  EventList._(
      {this.eventId,
        this.user_id,
        this.event_title,
        this.event_type,
        this.event_date_time,
        this.event_end_date_time,
        this.event_location,
        this.description,
        this.contactId,
        this.event_status,
        this.added_on,
        this.update_on,
        this.event_user_status});

  factory EventList.fromJson(Map<String, dynamic> json) {
    return new EventList._(
        eventId: json['eventId'],
        user_id: json['user_id'],
        event_title: json['event_title'],
        event_type: json['event_type'],
        event_date_time: json['event_date_time'],
        event_end_date_time: json['event_end_date_time'],
        event_location: json['event_location'],
        description: json['description'],
        contactId: json['contactId'],
        event_status: json['event_status'],
        added_on: json['added_on'],
        update_on: json['update_on'],
        event_user_status: json['event_user_status']);
  }
}*/
class EventList {
  var id,
      user_id,
      title,
      type,
      category,
      description,
      start_date_time,
      end_date_time,
      country,
      state,
      city,
      address,
      longitude,
      latitude,
      access_option,
      uniq_id,
      imgs,
      documents,
      urls,
      status,
      total_seats,
      added_on,
      update_on,
      organizer_name,
      event_user_status,
      organizer_profile;

  EventList._({
    this.id,
    this.user_id,
    this.title,
    this.type,
    this.category,
    this.description,
    this.start_date_time,
    this.end_date_time,
    this.country,
    this.state,
    this.city,
    this.address,
    this.longitude,
    this.latitude,
    this.access_option,
    this.uniq_id,
    this.imgs,
    this.documents,
    this.urls,
    this.status,
    this.total_seats,
    this.added_on,
    this.update_on,
    this.organizer_name,
    this.event_user_status,
    this.organizer_profile,
  });

  factory EventList.fromJson(Map<String, dynamic> json) {
    return new EventList._(
        id: json['id'],
        user_id: json['user_id'],
        title: json['title'],
        type: json['type'],
        category: json['category'],
        description: json['description'],
        start_date_time: json['start_date_time'],
        end_date_time: json['end_date_time'],
        country: json['country'],
        state: json['state'],
        city: json['city'],
        address: json['address'],
        longitude: json['longitude'],
        latitude: json['latitude'],
        access_option: json['access_option'],
        uniq_id: json['uniq_id'],
        imgs: json['imgs'],
        documents: json['documents'],
        urls: json['urls'],
        status: json['status'],
        total_seats: json['total_seats'],
        added_on: json['added_on'],
        update_on: json['update_on'],
        organizer_name: json['organizer_name'],
        event_user_status: json['event_user_status'],
        organizer_profile: json['organizer_profile']);
  }
}

// class EventListSingle {
//   final String eventId,
//       user_id,
//       event_title,
//       event_type,
//       event_date_time,
//       description,
//       status;
//
//   /*eventId: 212, event_title: hshsh, event_date_time: 1582839840, description: heheh, user_id: 60, status: 1*/
//   EventListSingle._(
//       {this.eventId,
//       this.user_id,
//       this.event_title,
//       this.event_type,
//       this.event_date_time,
//       this.description,
//       this.status});
//
//   factory EventListSingle.fromJson(Map<String, dynamic> json) {
//     return new EventListSingle._(
//         eventId: json['eventId'],
//         user_id: json['user_id'],
//         event_title: json['event_title'],
//         event_type: json['event_type'],
//         event_date_time: json['event_date_time'],
//         description: json['description'],
//         status: json['status']);
//   }
// }
