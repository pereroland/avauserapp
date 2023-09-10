import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/models/commentMessage.dart';
import 'package:avauserapp/components/models/userList.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/widget/Bubble.dart';
import 'package:avauserapp/components/widget/button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as Path;
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:add_2_calendar/add_2_calendar.dart';
class DisputeDetail extends StatefulWidget {
  DisputeDetail({Key? key, required this.disputeId}) : super(key: key);
  String disputeId;

  @override
  _DisputeDetailState createState() => _DisputeDetailState();
}

class _DisputeDetailState extends State<DisputeDetail> {
  var dataLoad = false;
  var STORES = "";
  Map? myLang;
  List<CommentMessage> commentmessages = [];
  List<userProfile> userprofile = [];
  var numParticiants = "00";
  TextEditingController messageController = TextEditingController();
  var userId = "";
  var varGroupName = "";
  var varGroupDescription = "";
  var varStoreName = "";
  late ScrollController _scrollController;
  late SharedPreferences prefs;
  var changeSize = "";
  var record, chat, dispute_detail, dispute_order_detail;
  var loaddingDone = false;
  File? filePickedUser;
  bool isProgress = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // scrollToBottom();
    callDisputeDetailCheck();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void scrollToBottom() {
    final bottomOffset = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      bottomOffset,
      duration: Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return new Scaffold(
      bottomSheet: chatMessageEnterData(context),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
                width: size.width,
                height: size.height / 3.5,
                color: '#453885'.parse(),
                child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: IconButton(
                                    icon: Icon(Icons.arrow_back_ios_outlined),
                                    color: Colors.white,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    })),
                            SizedBox(
                              width: 10.0,
                            ),
                            Expanded(
                                flex: 8,
                                child: Text(
                                  varGroupName,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20.0),
                                ))
                          ],
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          varGroupDescription,
                          maxLines: 1,
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          allTranslations.text('storeName') +
                              " : " +
                              varStoreName,
                          maxLines: 2,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20.0),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                      ],
                    ))),
          ),
          Padding(
            padding: EdgeInsets.only(top: size.height / 4.5),
            child: Stack(
              children: [
                Align(
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
                    height: size.height,
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 50.0),
                        child: loaddingDone
                            ? ListView.builder(
                                controller: _scrollController,
                                itemCount: commentmessages.length,
                                reverse: true,
                                itemBuilder: (BuildContext context, int index) {
                                  return listItems(
                                    commentmessages,
                                    index,
                                    context,
                                  );
                                })
                            : SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  spaceHeight() {
    return SizedBox(height: 10.0);
  }

  chatMessageEnterData(context) {
    return Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                height: 50.0,
                margin: EdgeInsets.only(right: 10),
                padding: const EdgeInsets.only(left: 10.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.circular(10.0),
                    border: Border.all(width: 0.5, color: Colors.black)),
                child: TextFormField(
                  controller: messageController,
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      hintText:
                          allTranslations.text('EnterCommentsHere') + "..."),
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 50.0,
                child: fullColouredImageBtn(
                    icon: isProgress
                        ? Padding(
                            padding:
                                const EdgeInsets.only(top: 12.0, bottom: 12),
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                    backgroundColour: AppColours.appTheme,
                    radiusButtton: 15.0,
                    onPressed: () {
                      if (messageController.text.toString().trim().toString() !=
                              "" &&
                          !isProgress) {
                        sendMessage(context);
                      }
                    }),
              ),
            )
          ],
        ));
  }

  int minusData(int convert) {
    int convertData = convert - 1;
    return convertData;
  }

  void sendMessage(context) async {
    setState(() {
      isProgress = true;
    });
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck) {
      prefs = await SharedPreferences.getInstance();
      String authtoken = prefs.getString('authtoken') ?? "";
      Map<String, String> headers = {"authtoken": authtoken};
      var uri = Uri.parse(sendDisputeMessageUrl);
      var request = new http.MultipartRequest("POST", uri);
      request.headers.addAll(headers);
      if (filePickedUser != null) {
        var stream =
            new http.ByteStream(DelegatingStream(filePickedUser!.openRead()));
        var length = await filePickedUser!.length();
        var multipartFile_identity_front = new http.MultipartFile(
            'attachments[]', stream, length,
            filename: Path.basename(filePickedUser!.path));
        request.files.add(multipartFile_identity_front);
      }
      request.fields['Accept-Language'] =
          jsonEncode(allTranslations.locale.toString());
      request.fields['dispute_id'] = widget.disputeId.toString();
      request.fields['message'] = messageController.text;
      request.fields['chat_time'] = DateTime.now().toUtc().toString();
      var response = await request.send();
      response.stream.transform(utf8.decoder).listen((value) async {
        setState(() {
          isProgress = false;
        });
        Map data = jsonDecode(await value);
        String status = data['status'];
        String message = data['message'];
        if (status == "200") {
          callDisputeDetailCheck();
          if (mounted)
            setState(() {
              FocusScope.of(context).requestFocus(FocusNode());
              messageController.text = "";
            });
        } else if (status == unauthorized_status) {
          await checkLoginStatus(context);
        } else if (status == data_not_found_status) {
        } else if (status == already_login_status) {
        } else if (status == "408") {
          jsonDecode(await apiRefreshRequest(context));
        } else {
          showToast(message);
        }
      });
    } else {
      setState(() {
        isProgress = false;
      });
    }
  }

  Widget listItems(
      List<CommentMessage> commentmessages, int index, BuildContext context) {
    var isMe;
    if (commentmessages[index].sendBy == userId) {
      isMe = false;
    } else {
      isMe = true;
    }
    String time;
    try {
      time = DateTime.parse(commentmessages[index].messageTime)
          .toLocal()
          .toString()
          .substring(0, 16);
      String amPM =
          DateTime.parse(commentmessages[index].messageTime).toLocal().hour > 12
              ? " PM"
              : " AM";
      if (DateTime.parse(commentmessages[index].messageTime).toLocal().hour >
          12) {
        DateTime dateTime =
            DateTime.parse(commentmessages[index].messageTime).toLocal();
        time =
            "${dateTime.month}-${dateTime.day.toString().length == 2 ? dateTime.day : "0" + dateTime.day.toString()}-${dateTime.year} ${"0" + "${dateTime.hour - 12}"}:${dateTime.minute.toString().length == 2 ? dateTime.minute : "0" + "${dateTime.minute}"}";
      }
      time = time + amPM;
    } catch (_) {
      time = "";
    }
    return Padding(
      padding: EdgeInsets.only(bottom: 25.0),
      child: Bubble(
        name: commentmessages[index].sendByName,
        // isMe
        //     ? commentmessages[index].sendByName
        //     : commentmessages[index].sendToName,
        message: commentmessages[index].message,
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

  // checkHeight(context) {
  //   if (changeSize.toString() == "" || changeSize.toString() == "null") {
  //     if (WidgetsBinding.instance!.window.viewInsets.bottom > 0.0) {
  //       changeSize = MediaQuery.of(context).viewInsets.bottom.toString();
  //       if (changeSize != null && prefs != null) {
  //         prefs.setString('sizeBottomKeyBoard',
  //             MediaQuery.of(context).viewInsets.bottom.toString());
  //       }
  //
  //       return SizedBox(
  //         height: 0.0,
  //       );
  //     } else {
  //       return keyBoardSize();
  //     }
  //   } else {
  //     return SizedBox(
  //       height: 0.0,
  //     );
  //   }
  // }

  void callDisputeDetailCheck() async {
    prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("id") ?? "";
    Map decoded = jsonDecode(await getApiDataRequest(
        disputeDetailUrl + widget.disputeId.toString(), context));
    String status = decoded['status'];
    String message = decoded['message'];
    if (status == success_status) {
      record = decoded['record'];
      dispute_detail = record['dispute_detail'];
      chat = record['chat'];
      dispute_order_detail = record['dispute_order_detail'];
      varGroupName = dispute_detail['title'];
      varGroupDescription = dispute_detail['description'];
      varStoreName = dispute_order_detail['store_name'];
      commentmessages = chat
          .map<CommentMessage>((json) => CommentMessage.fromJson(json))
          .toList();
      if (mounted)
        setState(() {
          loaddingDone = false;
          loaddingDone = true;
        });
    } else if (status == unauthorized_status) {
      await checkLoginStatus(context);
    } else if (status == already_login_status) {
    } else if (status == data_not_found_status) {
    } else if (status == "408") {
      jsonDecode(await apiRefreshRequest(context));
      callDisputeDetailCheck();
    } else {
      showToast(message);
    }
    if (mounted) Timer(Duration(seconds: 1), () => callDisputeDetailCheck());
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
  String convert0ToZeroAdd() {
    if (this > 10) {
      return this.toString();
    } else {
      return "0" + this.toString();
    }
  }
}
