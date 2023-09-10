import 'dart:convert';

import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/longLog.dart';
import 'package:avauserapp/components/models/DisputeModel.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/widget/appbar.dart';
import 'package:avauserapp/screens/Dispute/DisputeDetail.dart';
import 'package:flutter/material.dart';

class DisputeList extends StatefulWidget {
  @override
  _DisputeListState createState() => _DisputeListState();
}

class _DisputeListState extends State<DisputeList> {
  List<disputeList> _list = [];
  var dataNotFound = false;
  var loaddingDone = false;

  @override
  void initState() {
    super.initState();
    callDisputeListCheck();
  }

  void callDisputeListCheck() async {
    Map map = {"page_no": "1", "search": ""};
    Map decoded = jsonDecode(await apiRequest(disputeListUrl, map, context));
    String status = decoded['status'];
    String message = decoded['message'];
    if (status == success_status) {
      var data = decoded['record']['data'];
      _list =
          data.map<disputeList>((json) => disputeList.fromJson(json)).toList();
      if (_list.length > 0) {
        setState(() {
          dataNotFound = false;
        });
      } else {
        setState(() {
          dataNotFound = true;
        });
      }
      if (mounted)
        setState(() {
          loaddingDone = true;
        });
    } else if (status == unauthorized_status) {
      await checkLoginStatus(context);
    } else if (status == already_login_status) {
    } else if (status == data_not_found_status) {
      setState(() {
        loaddingDone = true;
        dataNotFound = true;
      });
    } else if (status == "408") {
      Map decoded = jsonDecode(await apiRefreshRequest(context));
      callDisputeListCheck();
    } else {
      showToast(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
          text: allTranslations.text('disputeList'),
          onTap: () {
            Navigator.pop(context);
          }),
      body: loaddingDone
          ? dataNotFound
              ? Container(
                  height: MediaQuery.of(context).size.height,
                  child:
                      Center(child: Image.asset("assets/noproductfound.webp")),
                )
              : ListView.builder(
                  itemCount: _list.length,
                  itemBuilder: (BuildContext context, int index) {
                    return listItem(_list, index, context);
                  })
          : Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
              child: Center(
                child: Image.asset("assets/storeloadding.gif"),
              ),
            ),
    );
  }

  listItem(List<disputeList> list, int index, BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
      child: InkWell(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  list[index].bookingId,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.0),
                Text(
                  list[index].storeName,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.0),
                Text(
                  list[index].title,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.0),
                Text(
                  list[index].description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    DisputeDetail(disputeId: list[index].id.toString())),
          );
        },
      ),
    );
  }
}
