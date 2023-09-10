import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/widget/button.dart';
import 'package:avauserapp/walletData/walletSetupScreen.dart';
import 'package:flutter/material.dart';

Future<bool> WalletSetupDialog(context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        actions: <Widget>[
          Column(
            children: [
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Image.asset(
                  'assets/wallet_recharge.webp',
                  height: 200,
                ),
              ),
              SizedBox(
                height: 50.0,
              ),
              Center(
                child: Text(
                  allTranslations.text('WalletSetup'),
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
                  allTranslations.text('WalletSetupDescriptionText'),
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
              Padding(
                padding: EdgeInsets.only(right: 5.0, left: 5.0),
                child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: fullColouredBtn(
                        radiusButtton: 35.0,
                        text: allTranslations.text('AddWallet'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WalletSetUp(
                                      showAppbar: true,
                                    )),
                          );
                        })),
              )
            ],
          )
        ],
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(10.0)),
      );
    },
  );
  return Future.value(false);
}
