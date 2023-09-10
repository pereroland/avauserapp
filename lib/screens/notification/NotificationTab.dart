import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:flutter/material.dart';

import 'BeaconNotification.dart';
import 'NormalNotification.dart';

class NotificationTabs extends StatefulWidget {
  final int? index;
  final int? currentNotificationId;

  const NotificationTabs({this.index, this.currentNotificationId});

  @override
  _NotificationTabsState createState() => _NotificationTabsState();
}

class _NotificationTabsState extends State<NotificationTabs>
    with TickerProviderStateMixin {
  TabController? tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    if (widget.index != null) {
      tabController?.index = widget.index!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          bottom: TabBar(
            controller: tabController,
            tabs: [
              setText(allTranslations.text('BeaconNotification')),
              setText(allTranslations.text('ApplicationNotification'))
            ],
          ),
          centerTitle: true,
          title: Text(
            allTranslations.text('notifications'),
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: TabBarView(
          controller: tabController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            BeaconNotificationDetail(),
            NormalNotificationDetail(),
          ],
        ),
      ),
    );
  }

  setText(String textString) {
    return Text(
      textString,
      style: TextStyle(color: Colors.black),
    );
  }
}
