import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/contactManage/ecityContacts.dart';
import 'package:avauserapp/components/contactfetch.dart';
import 'package:avauserapp/components/keyboardSIze.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/models/chatMessage.dart';
import 'package:avauserapp/components/models/userList.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/permission.dart';
import 'package:avauserapp/components/shimmerEffects/imageloadshimmer.dart';
import 'package:avauserapp/components/widget/Bubble.dart';
import 'package:avauserapp/components/widget/button.dart';
import 'package:avauserapp/components/widget/text.dart';
import 'package:avauserapp/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChattingUserDetail extends StatefulWidget {
  ChattingUserDetail({Key? key, this.chatGroupId, this.listSelected})
      : super(key: key);
  var chatGroupId;
  List<ContactListJson>? listSelected = [];

  @override
  _ChattingUserDetail createState() => _ChattingUserDetail();
}

class _ChattingUserDetail extends State<ChattingUserDetail> {
  bool oneTIme = false;
  var _messageBeingSent = false;
  var dataLoad = false;
  var STORES = "";
  Map? myLang;
  List<chatMessage> chatmessages = [];
  List<userProfile> userprofile = [];
  var numParticiants = "00";
  TextEditingController messageController = TextEditingController();
  var userId = "";
  var varGroupName = "";
  var varGroupDescription = "";
  ScrollController _scrollController = new ScrollController();
  SharedPreferences? prefs;
  var changeSize = "";

  @override
  void initState() {
    super.initState();
    chatMessageDetail(true);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: RefreshIndicator(
            onRefresh: () {
              setState(() {
                dataLoad = false;
                chatMessageDetail(true);
              });
              return Future.value();
            },
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                      width: size.width,
                      height: 190,
                      color: '#453885'.parse(),
                      child: Padding(
                          padding: EdgeInsets.only(
                              left: 20.0, right: 20.0, top: 10.0, bottom: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: IconButton(
                                          icon: Icon(
                                              Icons.arrow_back_ios_outlined),
                                          color: Colors.white,
                                          onPressed: () {
                                            Navigator.pop(context);
                                          })),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Icon(
                                        Icons.account_circle,
                                        color: Colors.white,
                                        size: 30.0,
                                      )),
                                  SizedBox(
                                    width: 20.0,
                                  ),
                                  Expanded(
                                      flex: 8,
                                      child: Text(
                                        varGroupName,
                                        maxLines: 1,
                                        overflow: TextOverflow.visible,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20.0),
                                      ))
                                ],
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  headerText(
                                      text: allTranslations
                                              .text('participants') +
                                          " : " +
                                          int.parse(numParticiants.toString())
                                              .convertToZeroAdd()
                                              .toString(),
                                      color: Colors.white,
                                      size: 18.0),
                                  GestureDetector(
                                    child: Icon(
                                      Icons.refresh,
                                      color: Colors.white,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        dataLoad = false;
                                        chatMessageDetail(true);
                                      });
                                    },
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              dataLoad
                                  ? Container(
                                      height: 50.0,
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: userprofile.length + 1,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Container(
                                              child: ListData(
                                                  userprofile, index, context),
                                            );
                                          }),
                                    )
                                  : SizedBox.shrink()
                            ],
                          ))),
                ),
                Expanded(
                  child: Container(
                    color: '#453885'.parse(),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(top: 15),
                            width: size.width,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(40),
                                topLeft: Radius.circular(40),
                              ),
                            ),
                            child: ListView.builder(
                                padding: EdgeInsets.all(10.0),
                                controller: _scrollController,
                                itemCount: chatmessages.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return listItems(
                                      chatmessages, index, context);
                                }),
                          ),
                        ),
                        chatMessageEnterData(context),
                        checkHeight(context),
                      ],
                    ),
                  ),
                ),
                if (!dataLoad)
                  Align(
                    child: LinearProgressIndicator(
                      backgroundColor: '#453885'.parse(),
                      color: Colors.white,
                    ),
                    alignment: Alignment.topCenter,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  spaceHeight() {
    return SizedBox(height: 10.0);
  }

  chatMessageEnterData(context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: new Container(
              height: 50.0,
              margin: EdgeInsets.only(left: 10, top: 10, bottom: 10),
              padding: const EdgeInsets.only(left: 10.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: new BorderRadius.circular(10.0),
                  border: Border.all(width: 0.5, color: Colors.black)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: messageController,
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      hintText: allTranslations.text('Entermessagehere'),
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            width: 10.0,
          ),
          Container(
            height: 50.0,
            width: 70,
            padding: EdgeInsets.only(right: 10),
            child: _messageBeingSent
                ? Center(child: CircularProgressIndicator())
                : fullColouredImageBtn(
                    icon: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    backgroundColour: AppColours.appTheme,
                    radiusButtton: 15.0,
                    onPressed: () {
                      final messageEmpty =
                          messageController.text.toString().trim() == "";
                      if (!messageEmpty && mounted) {
                        setState(() {
                          FocusScope.of(context).requestFocus(FocusNode());
                        });
                        sendMessage(context);
                      }
                    },
                  ),
          )
        ],
      ),
    );
  }

  Widget ListData(
      List<userProfile> userprofile, int index, BuildContext context) {
    if (userprofile.length == index) {
      return Padding(
        padding: EdgeInsets.all(5.0),
        child: SizedBox(
          child: FloatingActionButton(
            backgroundColor: AppColours.whiteColour,
            child: Icon(
              Icons.add,
              color: AppColours.appTheme,
            ),
            onPressed: () {
              attendenceAdd(context);
            },
          ),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(5.0),
        child: new CircleAvatar(
          backgroundColor: AppColours.whiteColour,
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: userprofile[index].profile,
              fit: BoxFit.cover,
              placeholder: (context, url) => imageShimmer(context, 48.0),
              errorWidget: (context, url, error) => Image.asset(
                "assets/userImage.png",
                fit: BoxFit.fill,
              ),
              width: 42,
              height: 42,
            ),
          ),
        ),
      );
    }
  }

  int minusData(int convert) {
    int convertData = convert - 1;
    return convertData;
  }

  void chatMessageDetail(bool refresh) async {
    if (chatmessages.toString() == "[]" && refresh) dataLoad = false;
    var url = groupMessagesUrl + widget.chatGroupId;
    prefs = await SharedPreferences.getInstance();
    if (mounted)
      setState(() {
        changeSize = prefs!.getString('sizeBottomKeyBoard') ?? "";
        userId = prefs!.getString('id') ?? "";
      });
    Map groupMessageList =
        jsonDecode(await getApiDataRequest(url, navigatorKey.currentContext!));
    String status = groupMessageList['status'];
    String message = groupMessageList['message'];
    if (status == success_status) {
      List<chatMessage> oldChat = [];
      if (mounted)
        setState(() {
          var record = groupMessageList['record'] as List;
          var user_profiles = groupMessageList['user_profiles'] as List;
          var num_particiants = groupMessageList['num_particiants'];
          var group_info = groupMessageList['group_info'];
          oldChat = chatmessages;
          chatmessages = record
              .map<chatMessage>((json) => chatMessage.fromJson(json))
              .toList();
          userprofile = user_profiles
              .map<userProfile>((json) => userProfile.fromJson(json))
              .toList();
          numParticiants = num_particiants.toString();
          varGroupName = group_info['name'].toString();
          varGroupDescription = group_info['description'].toString();
        });
      if (oldChat.length != chatmessages.length) callScroll();
      if (mounted)
        Future.delayed(Duration(seconds: 2), () => chatMessageDetail(false));
    } else if (status == unauthorized_status) {
      await checkLoginStatus(context);
    } else if (status == expire_token_status) {
      jsonDecode(await apiRefreshRequest(context));
      chatMessageDetail(refresh);
    } else {
      if (!oneTIme) showToast(message);
      oneTIme = true;
    }
    dataLoad = true;
  }

  void sendMessage(context) async {
    _messageBeingSent = true;
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck) {
      prefs = await SharedPreferences.getInstance();
      String authtoken = prefs!.getString('authtoken') ?? "";

      Map<String, String> headers = {"authtoken": authtoken};
      var uri = Uri.parse(sendMessageUrl);
      var request = new http.MultipartRequest("POST", uri);
      request.headers.addAll(headers);
      request.fields['Accept-Language'] =
          jsonEncode(allTranslations.locale.toString());
      request.fields['group_id'] = widget.chatGroupId.toString();
      request.fields['message'] = messageController.text;
      request.fields['chat_time'] = DateTime.now().toUtc().toString();
      var response = await request.send();
      response.stream.transform(utf8.decoder).listen((value) async {
        Map data = jsonDecode(value);
        String status = data['status'];
        String message = data['message'];
        if (status == "200") {
          if (mounted)
            setState(() {
              // chatMessageDetail();
              messageController.text = "";
            });
        } else if (status == unauthorized_status) {
          await checkLoginStatus(context);
        } else if (status == data_not_found_status) {
        } else if (status == already_login_status) {
        } else if (status == "408") {
          Map decoded = jsonDecode(await apiRefreshRequest(context));
        } else {
          showToast(message);
        }
      });
      callScroll();
    } else {}
    _messageBeingSent = false;
  }

  Widget listItems(
      List<chatMessage> chatmessages, int index, BuildContext context) {
    var isMe;
    if (chatmessages[index].sendBy == userId) {
      isMe = false;
    } else {
      isMe = true;
    }
    String time;
    try {
      time = DateTime.parse(chatmessages[index].localTime!)
          .toLocal()
          .toString()
          .substring(0, 16);
      String amPM =
          DateTime.parse(chatmessages[index].localTime!).toLocal().hour > 12
              ? " PM"
              : " AM";
      time = time + amPM;
    } catch (_) {
      time = chatmessages[index].message_time;
    }
    return Padding(
      padding: EdgeInsets.only(bottom: 25.0),
      child: Bubble(
        name: chatmessages[index].fullName,
        message: chatmessages[index].message,
        time: time,
        delivered: true,
        isMe: isMe,
      ),
    );
  }

  void callScroll() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted)
        setState(() {
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut);
        });
    });
  }

  void attendenceAdd(context) async {
    List ids = [];
    for (int i = 0; i < userprofile.length; i++) {
      if (userprofile[i].toString() == "null") {
      } else {
        ids.add(userprofile[i].userId.toString());
      }
    }
    var permission =
        await requestPermission("Contacts", Permission.contacts, context);
    if (permission) List blanck = [];
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContactList(
                  typeList: 'create',
                  userAvaiable: ids,
                  selectedContact: [],
                )));
    if (result == null) {
    } else {
      List<String> data = [];
      List<ContactListJson> _listSelected = [];
      _listSelected = result;

      for (int i = 0; i < _listSelected.length; i++) {
        String id = _listSelected[i].id.toString();
        data.add(id);
      }
      var userIds = data.join(', ');
      editClanApiData(userIds);
    }
  }

  void editClanApiData(String userIds) async {
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck) {
      prefs = await SharedPreferences.getInstance();
      String authtoken = prefs!.getString('authtoken') ?? "";
      Map<String, String> headers = {"authtoken": authtoken};
      var uri = Uri.parse(editClanUrl);
      var request = new http.MultipartRequest("POST", uri);
      request.headers.addAll(headers);
      request.fields['user_ids'] = userIds; //      typeController.text;
      request.fields['title'] = varGroupName; //      typeController.text;
      request.fields['group_id'] =
          widget.chatGroupId; //      typeController.text;
      request.fields['description'] = varGroupDescription;
      var response = await request.send();
      response.stream.transform(utf8.decoder).listen((value) async {
        Map data = jsonDecode(value);
        String status = data['status'];
        String message = data['message'];
        if (status == "200") {
          if (mounted)
            setState(() {
              chatMessageDetail(true);
              FocusScope.of(context).requestFocus(FocusNode());
              messageController.text = "";
            });
        } else if (status == unauthorized_status) {
          await checkLoginStatus(context);
        } else if (status == data_not_found_status) {
        } else if (status == already_login_status) {
        } else if (status == "408") {
          Map decoded = jsonDecode(await apiRefreshRequest(context));
          editClanApiData(userIds);
        } else {
          showToast(message);
        }
      });
    } else {}
  }

  checkHeight(context) {
    if (changeSize.toString() == "" || changeSize.toString() == "null") {
      if (WidgetsBinding.instance.window.viewInsets.bottom > 0.0) {
        changeSize = MediaQuery.of(context).viewInsets.bottom.toString();
        prefs!.setString('sizeBottomKeyBoard',
            MediaQuery.of(context).viewInsets.bottom.toString());

        return SizedBox(
          height: 0.0,
        );
      } else {
        return keyBoardSize();
      }
    } else {
      return SizedBox(
        height: 0.0,
      );
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
