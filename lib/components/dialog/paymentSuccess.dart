import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:flutter/material.dart';

Future<bool> PaymentWalletSetupDialog(context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 10.0, left: 10.0),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              )),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/payment_successFull_wallet.png',
                  height: 200,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50.0,
          ),
          Center(
            child: Text(
              allTranslations.text('PaymentSuccessful'),
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Center(
            child: Text(
              allTranslations.text('paymentSuccessfullText'),
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black45),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
        ],
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(10.0)),
      );
    },
  );
  return Future.value(false);
}
