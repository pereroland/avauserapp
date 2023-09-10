import 'package:avauserapp/components/dataLoad/invoiceListDataLoad.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/models/invoiceList.dart';
import 'package:avauserapp/components/widget/text.dart';
import 'package:flutter/material.dart';

import 'invoiceDetail.dart';

class InvoiceList extends StatefulWidget {
  String? invoiceId;

  InvoiceList({this.invoiceId});

  @override
  _InvoiceListState createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList> {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  var dataLoad = false;
  var datafound = true;
  List<invoice> _list = [];

  @override
  void initState() {
    super.initState();
    myinvoiceList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          allTranslations.text('Invoice'),
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: dataLoad
          ? datafound
              ? RefreshIndicator(
                  key: refreshKey,
                  child: ListView.builder(
                      itemCount: _list.length,
                      itemBuilder: (BuildContext context, int index) {
                        return listItems(_list, index, context);
                      }),
                  onRefresh: myinvoiceList,
                )
              : RefreshIndicator(
                  key: refreshKey,
                  child: Container(
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        child: Center(
                            child: Image.asset("assets/nodatafound.webp")),
                      ),
                    ),
                  ),
                  onRefresh: myinvoiceList,
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

  Future<void> myinvoiceList() async {
    Map clanListMap = await invoiceListLoad(context) ?? {};

    if (clanListMap['status'] == "200") {
      List data = clanListMap['record']['record'];
      if (mounted)
        setState(() {
          _list = data.map<invoice>((json) => invoice.fromJson(json)).toList();
          datafound = true;
          dataLoad = true;
        });
    } else {
      if (mounted)
        setState(() {
          dataLoad = true;
          datafound = false;
        });
    }
  }

  Widget listItems(List<invoice> list, int index, BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: InkWell(
        onTap: () {
          list[index].newClanDetails = "2";
          if (mounted) setState(() {});
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => InvoiceDetail(
                      id: list[index].id,
                      status: list[index].detailsStatus,
                    )),
          );
        },
        child: Card(
          child: Padding(
            padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Image.asset(
                    'assets/invoiceImage.png',
                    height: 40.0,
                  ),
                  flex: 1,
                ),
                SizedBox(
                  width: 10.0,
                ),
                Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            headerText(text: list[index].invoiceId.toString()),
                            if (widget.invoiceId != null &&
                                widget.invoiceId == list[index].id.toString() &&
                                list[index].newClanDetails != "1")
                              Text(
                                "(Notice)",
                                style: TextStyle(color: Colors.green),
                              ),
                            if (list[index].newClanDetails == "1")
                              Text(
                                "(New)",
                                style: TextStyle(color: Colors.green),
                              )
                          ],
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(list[index].requestDate.toString())
                      ],
                    )),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    headerText(
                        text: list[index].invoiceCurrency.toString() +
                            " " +
                            list[index].share.toString(),
                        textAlign: TextAlign.end),
                    if (list[index].detailsStatus == "2")
                      headerText(
                          text: "Paid",
                          size: 15,
                          fontWeight: FontWeight.normal,
                          textAlign: TextAlign.end),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
