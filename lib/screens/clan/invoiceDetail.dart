import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/createTransactionId.dart';
import 'package:avauserapp/components/dataLoad/invoiceDetailDataLoad.dart';
import 'package:avauserapp/components/dialog/walletTrasfer.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/models/invoiceList.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/otpCheck.dart';
import 'package:avauserapp/components/widget/ListTile.dart';
import 'package:avauserapp/components/widget/button.dart';
import 'package:avauserapp/components/widget/text.dart';
import 'package:avauserapp/main.dart';
import 'package:avauserapp/screens/paymentSetup/AccountSetupUpdate.dart';
import 'package:flutter/material.dart';

class InvoiceDetail extends StatefulWidget {
  InvoiceDetail({Key? key, this.id, required this.status}) : super(key: key);
  var id;
  String status;

  @override
  _InvoiceDetailState createState() => _InvoiceDetailState();
}

class _InvoiceDetailState extends State<InvoiceDetail> {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  var dataLoad = false;
  var datafound = true;
  var data;
  late InvoiceData invoiceData;
  var alreadyPaid = false;
  var walletPaymentEnable = false;

  @override
  void initState() {
    super.initState();
    _loadInvoiceDetails();
  }

  _setNotNew(userId) async {
    await apiRequest(
        "https://alphaxtech.net/ecity/index.php/api/users/Clan/whenClickClan",
        {"invoice_id": "${widget.id}", "user_id": "$userId"},
        context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar:
          !alreadyPaid && dataLoad ? _getPayButton(context) : null,
      appBar: AppBar(
        title: Text(
          allTranslations.text('InvoiceDetails'),
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: dataLoad
          ? datafound
              ? Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
                  child: columnData(),
                )
              : RefreshIndicator(
                  key: refreshKey,
                  child: Center(
                      child: Image.asset(
                    "assets/nodatafound.webp",
                    color: Colors.transparent,
                  )),
                  onRefresh: _loadInvoiceDetails,
                )
          : Center(
              child: Image.asset("assets/storeloadding.gif"),
            ),
    );
  }

  Future<void> _loadInvoiceDetails() async {
    Map invoiceDetailMap = await invoiceDetailLoad(context, widget.id) ?? {};
    if (mounted) {
      if (invoiceDetailMap['status'] == "200") {
        setState(() {
          data = invoiceDetailMap['record'];
          invoiceData = InvoiceData.fromJson(data);
          _setNotNew(invoiceData.userId);
          alreadyPaid = widget.status == "2";
          datafound = true;
          dataLoad = true;
        });
      } else {
        setState(() {
          dataLoad = true;
          datafound = false;
        });
      }
    }
  }

  Widget listItems(List<invoice> list, int index, BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: InkWell(
        onTap: () {},
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
                Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        headerText(text: list[index].invoiceId.toString()),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(list[index].requestDate.toString())
                      ],
                    )),
                Expanded(
                    child: headerText(
                        text: list[index].invoiceTotalAmount.toString()))
              ],
            ),
          ),
        ),
      ),
    );
  }

  columnData() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/invoiceImage.png',
              height: 40.0,
            ),
            SizedBox(
              width: 10.0,
            ),
            headerText(text: invoiceData.invoiceId.toString()),
          ],
        ),
        SizedBox(
          height: 30.0,
        ),
        typeManage(invoiceData.invoiceType.toString()),
        SizedBox(
          height: 10.0,
        ),
        listTile(context,
            keyText: allTranslations.text('RequestDate'),
            valueText: invoiceData.requestDate.toString()),
        SizedBox(
          height: 10.0,
        ),
        listTile(context,
            keyText: allTranslations.text('MyShare'),
            valueText: invoiceData.invoiceCurrency.toString() +
                " " +
                invoiceData.share.toString()),
        SizedBox(
          height: 10.0,
        ),
      ],
    );
  }

  typeManage(String invoice_type) {
    if (invoice_type == "1") {
      // Event
      return Column(
        children: [
          listTile(context,
              keyText: allTranslations.text('title'),
              valueText: invoiceData.eventTitle.toString()),
          SizedBox(
            height: 10.0,
          ),
          listTile(context,
              keyText: allTranslations.text('description'),
              valueText: invoiceData.description.toString()),
        ],
      );
    }
    return Column(
      children: [
        // Order
        listTile(context,
            keyText: allTranslations.text('BookingId'),
            valueText: invoiceData.bookingId.toString()),
        SizedBox(
          height: 10.0,
        ),
        listTile(context,
            keyText: 'Total Products',
            valueText: invoiceData.numOfItems.toString()),
      ],
    );
  }

  Widget _getPayButton(BuildContext context) {
    return Container(
      height: 50,
      margin: EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      child: fullColouredBtn(
        radiusButtton: 15.0,
        text: allTranslations.text("pay"),
        onPressed: _checkPaymentType,
      ),
    );
  }

  Future<void> topUpWalletData() async {
    await WalletTransferDialogForInvoice(context, invoiceData.share,
        invoiceData.invoiceCurrency, "8", invoiceData.walletID, widget.id);
  }

  Future<bool> _checkPaymentType() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Invoice"),
          content: Text(allTranslations.text('SelectPaymentMethod')),
          actions: <Widget>[
            MaterialButton(
              elevation: 0.0,
              child: Text(
                allTranslations.text('Wallet'),
                style: TextStyle(color: AppColours.appTheme),
              ),
              onPressed: () async {
                Navigator.pop(context);
                var reply =
                    await walletOtpPayment(navigatorKey.currentContext!);
                if (reply == "Success") {
                  topUpWalletData();
                }
              },
            ),
            MaterialButton(
              elevation: 0.0,
              child: Text(
                allTranslations.text('CardorPhone'),
                style: TextStyle(color: AppColours.appTheme),
              ),
              onPressed: () async {
                Navigator.pop(context);
                _navigateToPayment();
              },
            )
          ],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        );
      },
    ).then((value) => false);
  }

  void _navigateToPayment() {
    var cpmId = selectDatePick(context, "ECITY");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountSetUpUpdate(
          payment_mode: "phone",
          id: widget.id,
          paymentFor: "3",
          // wallet for 3
          referenceId: "0",
          merchantId: invoiceData.userId.toString(),
          // share is a amount that you pay
          cpm_trans_id: cpmId,
          amount: invoiceData.share.toString(),
          // share is a amount that you pay
          record: "",
          isClan: invoiceData.clanInvoiceId,
        ),
      ),
    );
  }
}

class InvoiceData {
  late var share;
  late var invoiceStatus;
  late var clanInvoiceId;
  late var invoiceId;
  late var status;
  late var requestDate;
  late var userId;
  late var bookingId;
  late var subTotal;
  late var storeId;
  late var numOfItems;
  late var deliveryAmount;
  late var tax;
  late var totalAmount;
  late var invoiceTotalAmount;
  late var eventTitle;
  late var description;
  late var address;
  late var eventType;
  late var invoiceType;
  late var currency;
  late var walletID;
  late var storeCurrency;
  late var paymentWithWallet;
  late String invoiceCurrency;

  InvoiceData(
      {this.share,
      this.invoiceStatus,
      this.clanInvoiceId,
      this.invoiceId,
      this.requestDate,
      this.userId,
      this.bookingId,
      this.subTotal,
      this.status,
      this.storeId,
      this.numOfItems,
      this.deliveryAmount,
      this.tax,
      this.totalAmount,
      this.invoiceTotalAmount,
      this.eventTitle,
      this.description,
      this.address,
      this.eventType,
      this.invoiceType,
      this.currency,
      this.walletID,
      this.storeCurrency,
      this.paymentWithWallet,
      required this.invoiceCurrency});

  InvoiceData.fromJson(Map<String, dynamic> json) {
    share = json['share'];
    invoiceStatus = json['invoice_status'];
    clanInvoiceId = json['clan_invoice_id'];
    invoiceId = json['invoiceId'];
    requestDate = json['request_date'];
    userId = json['userId'];
    bookingId = json['booking_id'];
    status = json["status"];
    subTotal = json['sub_total'];
    storeId = json['store_id'];
    numOfItems = json['num_of_items'];
    deliveryAmount = json['delivery_amount'];
    tax = json['tax'];
    totalAmount = json['total_amount'];
    invoiceTotalAmount = json['invoice_total_amount'];
    eventTitle = json['event_title'];
    description = json['description'];
    address = json['address'];
    eventType = json['event_type'];
    invoiceType = json['invoice_type'];
    currency = json['currency'];
    walletID = json['wallet_ID'];
    storeCurrency = json['store_currency'];
    paymentWithWallet = json['paymentWithWallet'];
    invoiceCurrency = json['invoice_currency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['share'] = this.share;
    data['invoice_status'] = this.invoiceStatus;
    data['clan_invoice_id'] = this.clanInvoiceId;
    data['invoiceId'] = this.invoiceId;
    data['request_date'] = this.requestDate;
    data['userId'] = this.userId;
    data["status"] = this.status;
    data['booking_id'] = this.bookingId;
    data['sub_total'] = this.subTotal;
    data['store_id'] = this.storeId;
    data['num_of_items'] = this.numOfItems;
    data['delivery_amount'] = this.deliveryAmount;
    data['tax'] = this.tax;
    data['total_amount'] = this.totalAmount;
    data['invoice_total_amount'] = this.invoiceTotalAmount;
    data['event_title'] = this.eventTitle;
    data['description'] = this.description;
    data['address'] = this.address;
    data['event_type'] = this.eventType;
    data['invoice_type'] = this.invoiceType;
    data['currency'] = this.currency;
    data['wallet_ID'] = this.walletID;
    data['store_currency'] = this.storeCurrency;
    data['paymentWithWallet'] = this.paymentWithWallet;
    data['invoice_currency'] = this.invoiceCurrency;
    return data;
  }
}
