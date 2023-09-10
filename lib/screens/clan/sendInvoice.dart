import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/widget/button.dart';
import 'package:flutter/material.dart';

class SendInvoice extends StatefulWidget {
  SendInvoice(
      {Key? key,
      this.eventDatatMap,
      this.eventFirstValue,
      this.orderDatatMap,
      this.orderFirstValue})
      : super(key: key);
  List<Map>? eventDatatMap;
  String? eventFirstValue;
  List<Map>? orderDatatMap;
  String? orderFirstValue;
  var id;

  @override
  _SendInvoiceState createState() => _SendInvoiceState();
}

class _SendInvoiceState extends State<SendInvoice> {
  int? selectedRadio;
  var marketId = true;
  String tag_add_hint_event = "";
  String tag_add_hint_order = "";
  var eventEnable = true;
  var idSelected = "";
  var totalPayedAmount = "";

  @override
  void initState() {
    super.initState();
    selectedRadio = 1;
  }

  setSelectedRadio(int? val) {
    setState(() {
      if (val != null) {
        selectedRadio = val;
        if (val == 1) {
          eventEnable = true;
        } else {
          eventEnable = false;
        }
      }
    });
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
        body: Column(
          children: [
            SizedBox(
              height: 20.0,
            ),
            invoiceType(),
            selectEvent(),
            selectShop(),
            // selectShop(),
          ],
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
          text: allTranslations.text('Next'),
          onPressed: () {
            invoiceDataSelected();
            navigatorBackData();
          },
        ),
      ),
    );
  }

  invoiceType() {
    return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
              child: Text(
                allTranslations.text('selectType'),
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Radio(
                        value: 1,
                        groupValue: selectedRadio,
                        onChanged: (int? val) {
                          setSelectedRadio(val);
                        },
                      ),
                      Text(allTranslations.text('event'))
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Radio(
                        value: 2,
                        groupValue: selectedRadio,
                        onChanged: (int? val) {
                          setSelectedRadio(val);
                        },
                      ),
                      Text(allTranslations.text('shop'))
                    ],
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  selectEvent() {
    return eventEnable && widget.eventDatatMap != null
        ? Padding(
            padding: EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 0.0),
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                isExpanded: true,
                items: widget.eventDatatMap!.map((Map map) {
                  return DropdownMenuItem<String>(
                    value: map["name"].toString() + "(${map["id"]})",
                    child: Text(
                      map["name"].toString() + "(${map["id"]})",
                    ),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    widget.eventFirstValue = value;
                  });
                },
                hint: Text(tag_add_hint_event),
                value: widget.eventFirstValue,
              ),
            ),
          )
        : SizedBox.shrink();
  }

  selectShop() {
    return eventEnable
        ? SizedBox.shrink()
        : Padding(
            padding: EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 0.0),
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                isExpanded: true,
                items: widget.orderDatatMap!.map((Map map) {
                  return new DropdownMenuItem<String>(
                    value: map["name"].toString(),
                    child: new Text(
                      map["name"],
                    ),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    widget.orderFirstValue = value;
                  });
                },
                hint: Text(tag_add_hint_order),
                value: widget.orderFirstValue,
              ),
            ),
          );
  }

  void invoiceDataSelected() {
    if (selectedRadio == 1) {
      idSelectionEvent();
    } else {
      idSelectionOrder();
    }
  }

  void idSelectionEvent() {
    for (int i = 0; i < widget.eventDatatMap!.length; i++) {
      Map map = widget.eventDatatMap![i];
      var id = map['id'].toString();
      var name = map['name'].toString();
      if (widget.eventFirstValue.toString().substring(
                  0, widget.eventFirstValue.toString().indexOf("(")) ==
              name &&
          widget.eventFirstValue.toString().substring(
                  widget.eventFirstValue.toString().indexOf("(") + 1,
                  widget.eventFirstValue.toString().length - 1) ==
              id) {
        if (mounted)
          setState(() {
            idSelected = id;
            totalPayedAmount = "";
          });
      }
    }
  }

  void idSelectionOrder() {
    for (int i = 0; i < widget.orderDatatMap!.length; i++) {
      Map map = widget.orderDatatMap![i];
      var id = map['id'].toString();
      var name = map['name'].toString();
      var total_payed_amount = map['amount'].toString();
      if (widget.orderFirstValue == name) {
        if (mounted)
          setState(() {
            idSelected = id;
            totalPayedAmount = total_payed_amount;
          });
      }
//{id: 63, name: detail item}
    }
  }

  void navigatorBackData() {
    Map map = {
      "type": selectedRadio.toString(),
      "type_id": idSelected,
      "amount": totalPayedAmount
    };
    Navigator.pop(context, map);
  }
}
