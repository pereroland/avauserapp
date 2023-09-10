import 'dart:convert';
import 'dart:io';

import 'package:avauserapp/components/LabeledCheckbox.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/contactfetch.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactList extends StatefulWidget {
  ContactList(
      {Key? key,
      this.userAvaiable,
      this.typeList,
      required this.selectedContact})
      : super(key: key);
  List? userAvaiable;
  List<ContactListJson> selectedContact;
  var typeList;

  @override
  _State createState() => _State();
}

class _State extends State<ContactList> {
  List<bool> inputs = [];
  var dataSelect = false;
  String searchName = "";
  List<ContactListJson> _list = [];
  List<ContactListJson> _listSelected = [];
  String attendeesListCommaId = "";
  var userId = "";
  Icon actionIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  Widget appBarTitle = new Text(
    allTranslations.text('contact'),
    style: new TextStyle(color: Colors.white),
  );
  final TextEditingController _searchQuery = new TextEditingController();
  bool _IsSearching = false;
  var loadData = false;
  var dataFound = true;

  _CurrencyPickerState() {
    _searchQuery.addListener(() {
      if (_searchQuery.text.isEmpty) {
        setState(() {
          _IsSearching = false;
          searchName = "";
        });
      } else {
        setState(() {
          loadData = false;
          _IsSearching = true;
          searchName = _searchQuery.text;
          loadData = true;
        });
      }
    });
  }

  void _handleSearchStart() {
    setState(() {
      _IsSearching = true;
    });
  }

  var refreshKey = GlobalKey<RefreshIndicatorState>();

  void _handleSearchEnd() {
    setState(() {
      this.actionIcon = new Icon(
        Icons.search,
        color: Colors.white,
      );
      this.appBarTitle = new Text(
        allTranslations.text('contact'),
        style: new TextStyle(color: Colors.white),
      );
      _IsSearching = false;
      _searchQuery.clear();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    contactsFetch();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: AppColours.appTheme,
            centerTitle: true,
            title: appBarTitle,
            actions: const <Widget>[
              // new IconButton(
              //   icon: actionIcon,
              //   onPressed: () {
              //     setState(() {
              //       if (this.actionIcon.icon == Icons.search) {
              //         this.actionIcon = new Icon(
              //           Icons.close,
              //           color: Colors.white,
              //         );
              //         this.appBarTitle = new TextField(
              //           controller: _searchQuery,
              //           style: new TextStyle(
              //             color: Colors.white,
              //           ),
              //           decoration: new InputDecoration(
              //               enabledBorder: UnderlineInputBorder(
              //                 borderSide: BorderSide(color: Colors.transparent),
              //               ),
              //               focusedBorder: UnderlineInputBorder(
              //                 borderSide: BorderSide(color: Colors.transparent),
              //               ),
              //               prefixIcon:
              //                   new Icon(Icons.search, color: Colors.white),
              //               hintText: allTranslations.text('Search'),
              //               hintStyle: new TextStyle(color: Colors.white)),
              //         );
              //         _handleSearchStart();
              //       } else {
              //         _handleSearchEnd();
              //       }
              //     });
              //   },
              // ),
            ]),
        bottomNavigationBar: dataSelect || widget.selectedContact != null
            ? Padding(
                padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ButtonTheme(
                        minWidth: 200.0,
                        height: 50.0,
                        buttonColor: AppColours.appTheme,
                        child: MaterialButton(
                          elevation: 16.0,
                          color: AppColours.appTheme,
                          shape: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColours.appTheme),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          onPressed: () async {
                            if (widget.typeList == "create") {
                              Navigator.pop(context, _listSelected);
                            } else {
                              setIdAttendees(_listSelected);
                            }
                          },
                          child: Text(
                            allTranslations.text('select'),
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Text(''),
        body: loadData
            ? dataFound
                ? RefreshIndicator(
                    key: refreshKey,
                    child: ListView.builder(
                        itemCount: _list.length,
                        itemBuilder: (BuildContext context, int index) {
                          return listItems(_list, index, context);
                        }),
                    onRefresh: contactsFetch,
                  )
                : Container(
                    height: MediaQuery.of(context).size.height,
                    color: Colors.white,
                    child: Center(
                      child: Image.asset("assets/nodatafound.webp"),
                    ),
                  )
            : Container(
                height: MediaQuery.of(context).size.height,
                color: Colors.white,
                child: Center(
                  child: Image.asset("assets/storeloadding.gif"),
                ),
              ),
      ),
    );
  }

  Future<void> contactsFetch() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('id') ?? "";
      var list = await contactsfetch(context);
      List<String> alLEmail = [];
      for (int j = 0; j < widget.selectedContact.length; j++) {
        alLEmail.add(widget.selectedContact[j].email);
      }
      setState(() {
        for (int i = 0; i < list.length; i++) {
          if (alLEmail.contains(list[i].email)) {
            _listSelected.add(list[i]);
            inputs.add(true);
          } else
            inputs.add(false);
        }
        _list = list;
        if (_list.length < 1) {
          dataFound = false;
        }
        loadData = true;
      });
    } catch (_) {
      dataFound = false;
      loadData = true;
    }
  }

  Widget listItems(List list, int index, BuildContext context) {
    List? userCheck = widget.userAvaiable;
    if (userCheck.toString() == "null" || userCheck == null) {
      if (userId == list[index].id) {
        return SizedBox.shrink();
      } else {
        return userListSet(list, index, context);
      }
    } else {
      if (userCheck.contains(list[index].id)) {
        return SizedBox.shrink();
      } else {
        if (userId == list[index].id) {
          return SizedBox.shrink();
        } else {
          return userListSet(list, index, context);
        }
      }
    }
  }

  void ItemChange(bool val, int index, List<ContactListJson> contactslist,
      int indexPosition, BuildContext context) {
    setState(() {
      inputs[index] = val;
      if (val == true) {
//        attendees.add(contactslist[index].id);
        _listSelected.add(contactslist[index]);
      } else {
//        attendees.remove(contactslist[index].id);
        _listSelected.remove(contactslist[index]);
      }
      if (_listSelected.length > 0) {
        dataSelect = true;
      } else {
        dataSelect = false;
      }
    });
  }

  userListSet(List list, int index, BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 0.0),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          padding: new EdgeInsets.only(top: 0.0),
          child: new Container(
              padding: new EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
              child: ListTile(
                subtitle: Text(
                  list[index].email,
                  style: TextStyle(color: Colors.black),
                ),
                title: Text(
                  list[index].name_in_app,
                  style: TextStyle(color: Colors.black),
                ),
                trailing: new LabeledCheckbox(
                    value: inputs[index],
                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
                    onChanged: (bool val) {
                      ItemChange(val, index, _list, index, context);
                    }),
                onTap: () {
                  getData(true);
                },
              )),
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
                colors: const [
                  AppColours.whiteColour,
                  AppColours.whiteColour,
                  /*AppColours.appgradientfirstColour,
                    AppColours.appgradientsecondColour*/
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(0.5, 0.0),
                stops: const [0.0, 1.0],
                tileMode: TileMode.clamp),
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }

  void setIdAttendees(result) {
    List<String> data = [];
    for (int i = 0; i < result.length; i++) {
      String id = result[i].id.toString();
      data.add(id);
    }
    attendeesListCommaId = data.join(', ');
    addNewAttendeesApi(context, attendeesListCommaId);
  }

  Future<void> addNewAttendeesApi(context, attendeesListCommaId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        try {
          final result = await InternetAddress.lookup('google.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            Map map = {
              "id": widget.typeList,
              "attendee_id": attendeesListCommaId
            };
            Map decoded =
                jsonDecode(await apiRequestMainPage(addAttendeeUrl, map));
            String status = decoded['status'];
            String message = decoded['message'];
            if (status == success_status) {
              _showToast(context, message);
              Navigator.pop(context, "_listSelected");
            } else if (status == unauthorized_status) {
              await checkLoginStatus(context);
            } else if (status == "408") {
              Map decoded = jsonDecode(await apiRefreshRequest(context));
              addNewAttendeesApi(context, attendeesListCommaId);
            } else {
              _showToast(context, message);
            }
          }
        } on SocketException catch (_) {
          _showToast(
              context, allTranslations.text('internet_connection_mesage'));
        }
      }
    } on SocketException catch (_) {
      _showToast(context, allTranslations.text('internet_connection_mesage'));
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
}
