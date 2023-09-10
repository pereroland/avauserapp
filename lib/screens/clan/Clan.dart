import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/contactManage/ecityContacts.dart';
import 'package:avauserapp/components/contactfetch.dart';
import 'package:avauserapp/components/dataLoad/clanListDataLoad.dart';
import 'package:avauserapp/components/dataLoad/clanOrder.dart';
import 'package:avauserapp/components/dataLoad/eventLoad.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/models/clanList.dart';
import 'package:avauserapp/components/permission.dart';
import 'package:avauserapp/components/shimmerEffects/imageloadshimmer.dart';
import 'package:avauserapp/screens/clan/createClan.dart';
import 'package:avauserapp/screens/clan/sendInvoice.dart';
import 'package:avauserapp/screens/home/baseTabClass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ChatingUser.dart';
import 'sendInvoicePeople.dart';

class ClanDetail extends StatefulWidget {
  @override
  _ClanDetail createState() => _ClanDetail();
}

class _ClanDetail extends State<ClanDetail>
    with AutomaticKeepAliveClientMixin<ClanDetail> {
  var dataLoad = false;
  var STORES = "";
  Map? myLang;
  var userId = "",
      profilePic = "",
      userFullName = "",
      userEmail = "",
      userImage = "";
  var eventFirstValue;
  List<Map> eventDatatMap = [];
  var orderFirstValue;
  List<Map> orderDatatMap = [];
  List<ClanListModel> clanList = [];
  var dataFound = true;
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  var apiDataLoad = false;
  var selectforChat = true;
  Map? selectedInvoice;
  var clanId = "";
  var changeSize = "";

  @override
  void initState() {
    super.initState();
    myLangGet();
    myclanList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      floatingActionButton: selectforChat ? dropButtonFab() : const SizedBox.shrink(),
      drawer: dataLoad
          ? drawerData(
              context, userId, profilePic, userFullName, userEmail, userImage)
          : null,
      appBar: selectforChat ? chatAppBar() : clanInvoiceAppBar(),
      body: apiDataLoad
          ? dataFound
              ? RefreshIndicator(
                  key: refreshKey,
                  onRefresh: myclanList,
                  child: ListView.builder(
                      itemCount: clanList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return listItems(clanList, index, context);
                      }),
                )
              : RefreshIndicator(
                  key: refreshKey,
                  onRefresh: myLangGet,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                          child: Image.asset("assets/nodatafound.webp")),
                    ),
                  ),
                )
          : Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
              child: Container(
                height: MediaQuery.of(context).size.height,
                color: Colors.white,
                child: Center(
                  child: Image.asset("assets/storeloadding.gif"),
                ),
              ),
            ),
    );
  }

  Future<void> myLangGet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('email')!;
      userId = prefs.getString('id')!;
      userFullName = prefs.getString('full_name') ?? "";
      userImage = prefs.getString('image') ?? "";
      dataLoad = true;
    });
    eventLoad();
    orderLoad();
  }

  spaceHeight() {
    return const SizedBox(height: 10.0);
  }

  Widget listItems(
      List<ClanListModel> clanList, int index, BuildContext context) {
    return GestureDetector(
      child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Card(
            color: Colors.white,
            child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: CircleAvatar(
                  backgroundColor: AppColours.whiteColour,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: clanList[index].image,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          imageShimmer(context, 48.0),
                      errorWidget: (context, url, error) => Image.asset(
                        "Images/userimage.png",
                        fit: BoxFit.fill,
                      ),
                      width: 42,
                      height: 42,
                    ),
                  ),
                ),
              ),
              Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        clanList[index].name,
                        style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0),
                      )
                    ],
                  )),
            ],
          ),
            ),
          )),
      onTap: () {
        selectforChat
            ? chatDataOpen(clanList[index].id)
            : invoiceDataOpen(
                clanList[index].id, clanList[index].members ?? []);
      },
    );
  }

  @override
  bool get wantKeepAlive => true;

  dropButtonFab() {
    return SpeedDial(
      onClose: () {},
      onOpen: () {},
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: const IconThemeData(size: 22.0),
      visible: true,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      tooltip: 'Speed Dial',
      heroTag: 'dialOpen',
      backgroundColor: AppColours.appTheme,
      foregroundColor: Colors.white,
      elevation: 8.0,
      shape: const CircleBorder(),
      children: [
        SpeedDialChild(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.asset(
              'assets/sendInvoice.png',
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColours.appTheme,
          label: allTranslations.text("sendInvoice"),
          labelStyle: const TextStyle(fontSize: 15.0, color: AppColours.appTheme),
          onTap: () async {
            if (clanList.isNotEmpty) {
              sendInvoice(context);
            } else {
              showToast(allTranslations.text("createclanFirst"));
            }
          },
        ),
        SpeedDialChild(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.asset(
              'assets/createClan.png',
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColours.appTheme,
          label: allTranslations.text("createclan"),
          labelStyle: const TextStyle(fontSize: 15.0, color: AppColours.appTheme),
          onTap: () async {
            attendenceAdd(context);
          },
        ),
      ],
    );
  }

  void attendenceAdd(context) async {
    await requestPermission("Contacts", Permission.contacts, context);
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactList(
          typeList: 'create',
          selectedContact: [],
        ),
      ),
    );
    if (result != null) {
      List<ContactListJson> _listSelected = [];
      if (result.runtimeType != bool) {
        _listSelected = result;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateClan(listSelected: _listSelected),
        ),
      );
    }
  }

  Future<void> sendInvoice(BuildContext context) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SendInvoice(
          eventFirstValue: eventFirstValue.toString(),
          eventDatatMap: eventDatatMap,
          orderFirstValue: orderFirstValue,
          orderDatatMap: orderDatatMap,
        ),
      ),
    );
    if (result == null) {
      if (mounted)
        setState(() {
          selectforChat = true;
        });
    } else {
      if (mounted)
        setState(() {
          selectforChat = false;
          selectedInvoice = result;
        });
    }
  }

  Future<void> myclanList() async {
    Map? clanListMap = await clanListLoad(context);
    if (clanListMap != null) {
      if (clanListMap['status'] == "200") {
        List data = clanListMap['record'];
        if (mounted)
          setState(() {
            clanList = data
                .map<ClanListModel>((json) => ClanListModel.fromJson(json))
                .toList();
            dataFound = true;
            apiDataLoad = true;
          });
      } else {
        if (mounted)
          setState(() {
            apiDataLoad = true;
            dataFound = false;
          });
      }
    } else {
      if (mounted)
        setState(() {
          apiDataLoad = true;
          dataFound = false;
        });
    }
  }

  Future<void> eventLoad() async {
    Map eventMap = await eventDataListLoad(context) ?? {};
    if (eventMap['status'] == "200") {
      var data = eventMap['record'];
      for (int i = 0; i < data.length; i++) {
        if (i == 0) {
          eventFirstValue = data[i]['title'].toString() + "(${data[i]['id']})";
        }
        var map = {"id": data[i]['id'], "name": data[i]['title']};
        eventDatatMap.add(map);
      }
      if (eventDatatMap.isNotEmpty) {
        eventFirstValue =
            eventDatatMap[0]["name"] + "(${eventDatatMap[0]["id"]})";
      }
      if (mounted) setState(() {});
    }
  }

  Future<void> orderLoad() async {
    Map eventMap = await callordersClanLoad(context) ?? {};
    if (eventMap['status'] == "200") {
      var data = eventMap['record'];
      for (int i = 0; i < data.length; i++) {
        if (i == 0) {
          var bookingIdName =
              data[i]['store_name'] + " (" + data[i]['booking_id'] + ")";
          orderFirstValue = bookingIdName;
        }
        var bookingIdName =
            data[i]['store_name'] + " (" + data[i]['booking_id'] + ")";
        var map = {
          "id": data[i]['id'],
          "name": bookingIdName,
          "amount": data[i]['total_payed_amount']
        };
        orderDatatMap.add(map);
      }
    }
  }

  chatDataOpen(id) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChattingUserDetail(chatGroupId: id)),
    );
  }

  invoiceDataOpen(id, List<Members> members) {
    if (mounted)
      setState(() {
        clanId = id;
      });
    if (selectedInvoice != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SendInvoicePeople(
                  groupId: id,
                  members: members,
                  invoiceType: selectedInvoice!['type'],
                  totalAmount: selectedInvoice!['amount'],
                  typeId: selectedInvoice!['type_id'],
                  userId: userId,
                )),
      );
    }
  }

  chatAppBar() {
    return AppBar(
      title: Text(
        selectforChat
            ? allTranslations.text('chat')
            : allTranslations.text('SelectClan'),
        style: const TextStyle(color: Colors.black),
      ),
      iconTheme: const IconThemeData(color: Colors.black),
      centerTitle: true,
      backgroundColor: Colors.white,
    );
  }

  clanInvoiceAppBar() {
    return AppBar(
      title: Text(
        selectforChat
            ? allTranslations.text('chat')
            : allTranslations.text('SelectClan'),
        style: const TextStyle(color: Colors.black),
      ),
      leading: BackButton(
        onPressed: () {
          sendInvoice(context);
        },
      ),
      iconTheme: const IconThemeData(color: Colors.black),
      centerTitle: true,
      backgroundColor: Colors.white,
    );
  }
}
