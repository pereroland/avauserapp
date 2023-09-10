import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/keyboardSIze.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/widget/appbar.dart';
import 'package:avauserapp/components/widget/pinSetWidget.dart';
import 'package:flutter/material.dart';

class otpDialog extends StatefulWidget {
  otpDialog({Key? key, this.pin}) : super(key: key);
  var pin;

  @override
  _otpDialogState createState() => _otpDialogState();
}

class _otpDialogState extends State<otpDialog> {
  var PinData = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBarWidget(
        text: allTranslations.text('CheckPinCode'),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/pincode.png',
                    height: 200,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Container(
                height: 100.0,
                child: pinSetWidget(
                  context: context,
                  onChanged: (value) {
                    checkPin(value);
                  },
                ),
              ),
            ),
            SizedBox(
              height: 60.0,
            ),
            keyBoardSize(),
          ],
        ),
      ),
    );
  }

  checkPin(String value) {
    if (mounted) if (value.length == 4) {
      if (widget.pin.toString() == value.toString()) {
        showToast(allTranslations.text('CorrectPin'));
        PinData = value.toString();
        Navigator.pop(context, PinData);
        return true;
      } else {
        showToast(allTranslations.text('IncorrectPin'));
        Navigator.pop(context);
        return false;
      }
    }
  }
}
