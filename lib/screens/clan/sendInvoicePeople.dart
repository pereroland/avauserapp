import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/models/clanList.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/shimmerEffects/imageloadshimmer.dart';
import 'package:avauserapp/components/widget/button.dart';
import 'package:avauserapp/components/widget/text.dart';
import 'package:avauserapp/components/widget/textfield.dart';
import 'package:avauserapp/main.dart';
import 'package:avauserapp/screens/home/baseTabClass.dart';
import 'package:flutter/material.dart';

class SendInvoicePeople extends StatefulWidget {
  SendInvoicePeople(
      {Key? key,
      this.invoiceType,
      this.typeId,
      this.groupId,
      this.totalAmount,
      this.userId,
      this.members})
      : super(key: key);
  var invoiceType, typeId, groupId, totalAmount, userId;
  List<Members>? members;

  @override
  _SendInvoicePeopleState createState() => _SendInvoicePeopleState();
}

class _SendInvoicePeopleState extends State<SendInvoicePeople> {
  List memberAmountSelected = [];
  List<TextEditingController> controllers = []; //the controllers list
  var sendingInvoice = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        bottomNavigationBar: buttonBottom(context),
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            allTranslations.text('sendInvoice'),
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          leading: BackButton(
            color: Colors.black,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: widget.members != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20.0,
                      ),
                      headerText(
                          text: allTranslations.text('participants') +
                              " : " +
                              widget.members!.length
                                  .convertToZeroAdd()
                                  .toString(),
                          size: 20.0),
                      SizedBox(
                        height: 40.0,
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: widget.members!.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 30.0),
                              child: listItems(widget.members!, index, context),
                            );
                          }),
                    ],
                  )
                : SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  buttonBottom(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: SizedBox(
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: fullColouredBtn(
          radiusButtton: 15.0,
          text: sendingInvoice
              ? allTranslations.text("sending")
              : allTranslations.text('sendInvoice'),
          onPressed: () {
            if (!sendingInvoice) {
              itemSetPayment();
            }
          },
        ),
      ),
    );
  }

  Widget listItems(List<Members> members, int index, BuildContext context) {
    var showMember = false;
    if (members[index].userId == widget.userId) {
      showMember = false;
    } else {
      showMember = true;
    }
    return showMember
        ? Row(
            children: [
              Expanded(
                  flex: 2,
                  child: new CircleAvatar(
                    backgroundColor: AppColours.whiteColour,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: members[index].profile,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            imageShimmer(context, 48.0),
                        errorWidget: (context, url, error) => Image.asset(
                          "assets/userImage.png",
                          fit: BoxFit.fill,
                        ),
                        width: 42,
                        height: 42,
                      ),
                    ),
                  )),
              SizedBox(
                width: 20.0,
              ),
              Expanded(
                  flex: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(members[index].fullName),
                      normalNumberTextfield(
                          hintText: '0.00',
                          keyboardType: const TextInputType.numberWithOptions(
                              signed: true, decimal: true),
                          borderColour: Colors.black45,
                          onChanged: (content) {
                            var linkData = {
                              "user_id": members[index].userId.toString(),
                              "amount": content.toString(),
                            };
                            if (mounted)
                              setState(() {
                                memberAmountSelected.add(linkData);
                              });
                          }),
                    ],
                  ))
            ],
          )
        : SizedBox.shrink();
  }

  void itemSetPayment() {
    if (memberAmountSelected.length == 0) {
      showToast(allTranslations.text("please_enter_member_amount"));
    } else {
      List memberAmountSelectedreverse = [];
      memberAmountSelectedreverse = memberAmountSelected.reversed.toList();
      checkDatafilter(memberAmountSelectedreverse);
    }
  }

  void amountCheck(
      double totalAmount, double invoiceAmount, List<dynamic> listFinal) {
    var invoiceAmountString = invoiceAmount.toString();
    if (totalAmount > invoiceAmount) {
      showToast(
          "${allTranslations.text("amount_not_greater_then")} $invoiceAmountString");
    } else {
      sendInvoice(listFinal, invoiceAmountString);
    }
  }

  void listItemsData() {}

  void checkDatafilter(List<dynamic> memberAmountSelectedreverse) {
    List itemsCheck = [];
    List listFinal = [];
    for (int i = 0; i < memberAmountSelectedreverse.length; i++) {
      if (itemsCheck.contains(memberAmountSelectedreverse[i]['user_id'])) {
      } else {
        listFinal.add(memberAmountSelectedreverse[i]);
        itemsCheck.add(memberAmountSelectedreverse[i]['user_id']);
      }
    }
    amountCheckData(listFinal);
  }

  void amountCheckData(List listFinal) {
    var totalAmount = 0.0;
    for (int i = 0; i < listFinal.length; i++) {
      if (listFinal[i]['amount'].toString().trim().toString() == "") {
      } else {
        double amountChange = double.parse(listFinal[i]['amount'].toString());
        totalAmount = amountChange + totalAmount;
      }
    }
    if (totalAmount < 0.1) {
      showToast("Please enter amount");
    } else {
      if (widget.totalAmount == "") {
        sendInvoice(listFinal, "");
      } else {
        var invoiceAmount = double.parse(widget.totalAmount.toString());
        amountCheck(totalAmount, invoiceAmount, listFinal);
      }
    }
  }

  void sendInvoice(List<dynamic> listFinal, String invoiceAmountString) async {
    sendingInvoice = true;
    if (mounted) setState(() {});
    Map map = {
      "type": widget.invoiceType.toString(),
      "type_id": widget.typeId.toString(),
      "group_id": widget.groupId.toString(),
      "user_id_amount": listFinal,
      "total_amount": invoiceAmountString.toString(),
      "invoice_currency": "XOF////////////"
    };
    Map invoiceMap = jsonDecode(await apiRequestMainPage(sendInvoiceUrl, map));
    String status = invoiceMap['status'];
    String message = invoiceMap['message'];
    if (status == success_status) {
      showToast("Invoice Created Successfully.");
      navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (_) => TabBarController(0)));
    } else if (status == unauthorized_status) {
      await checkLoginStatus(context);
    } else if (status == expire_token_status) {
      jsonDecode(await apiRefreshRequest(context));
      sendInvoice(listFinal, invoiceAmountString);
    } else {
      showToast(message);
    }
    sendingInvoice = false;
    if (mounted) setState(() {});
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

class MapAmount {
  String id;
  String price;
  late String currency;

  MapAmount({required this.id, required this.price});

  factory MapAmount.fromJson(Map<String, dynamic> parsedJson) {
    return MapAmount(
      id: parsedJson['id'].toString(),
      price: parsedJson['price'].toString(),
    );
  }
}
