import 'dart:convert';
import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/dataLoad/myWallettModeLoad.dart';
import 'package:avauserapp/components/dialog/otpCheck.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/widget/appbar.dart';
import 'package:avauserapp/screens/kiosk/invoice_web_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KioskPaymentScreen extends StatefulWidget {
  const KioskPaymentScreen(
      {Key? key,
      required this.transactionId,
      required this.kioskId,
      required this.total,
      required this.addUserWalletId,
      required this.addMerchantWalletId})
      : super(key: key);

  final String transactionId;
  final String kioskId;
  final String total;
  final String addUserWalletId;
  final String addMerchantWalletId;

  @override
  State<KioskPaymentScreen> createState() => _KioskPaymentScreenState();
}

class _KioskPaymentScreenState extends State<KioskPaymentScreen> {
  bool _isLoading = false;
  String orderId = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(text: allTranslations.text('kiosk_payment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  allTranslations.text('payment_confirmation') +
                      widget.transactionId,
                  style: TextStyle(fontSize: 20, color: AppColours.appTheme),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                      color: AppColours.appTheme,
                      child: Text(allTranslations.text('no'),
                          style: TextStyle(fontSize: 12)),
                      textColor: Colors.white,
                      onPressed: () {},
                    ),
                    MaterialButton(
                      color: AppColours.appTheme,
                      child: Text(allTranslations.text('yes'),
                          style: TextStyle(fontSize: 12)),
                      textColor: Colors.white,
                      onPressed: _onYesPressed,
                    )
                  ],
                )
              ],
            ),
            if (_isLoading)
              Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              )
          ],
        ),
      ),
    );
  }

  void _onYesPressed() async {
    if (_isLoading) return;
    String? walletPin = await _getWalletPin(context);
    if (walletPin == null) {
      showToast(allTranslations.text("kiosk_payment_error"));
      return;
    }
    bool otpValidated = await _validateOtp(walletPin);
    if (!otpValidated) {
      return;
    }
    try {
      final paymentDone = await _completePayment();
      if (paymentDone) {
        final prefs = await SharedPreferences.getInstance();
        String token = prefs.getString('authtoken') ?? "";

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                InvoicePage(authToken: token, orderId: orderId),
          ),
        );
      }
    } catch (th, stack) {
      showToast(th.toString());
      print(th);
      print(stack);
      // showToast(stack.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (mounted) {
      setState(() {
        _isLoading = value;
      });
    }
  }

  Future<String?> _getWalletPin(BuildContext context) async {
    _setLoading(true);
    Map detail = await myWalletModeLoad(context) ?? {};
    _setLoading(false);
    if (detail['status'] == "200") {
      String authPinCode = detail['record'][0]['auth_pin_code'];
      return authPinCode;
    } else {
      return null;
    }
  }

  Future<bool> _validateOtp(String pinCode) async {
    //if the result is null, that means the otp is invalid,
    //if the result is not null, then otp is validated.
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => otpDialog(pin: pinCode),
      ),
    );
    return result != null;
  }

  Future<bool> _completePayment() async {
    final requestBody = {
      "group_id": "",
      "clan_userId": "",
      "cart_total": widget.total,
      "txn_id": widget.transactionId,
      "camp_id": "",
      "Accept-Language": "en",
      "kiosk_id": widget.kioskId,
      "add_user_wallet_id": widget.addUserWalletId,
      "add_merchant_wallet_id": widget.addMerchantWalletId
    };
    _setLoading(true);
    Map response = jsonDecode(
      await apiRequest(completeKioskPayment, requestBody, ''),
    );
    _setLoading(false);
    print("response:");
    print(response);
    if (response['status'] == '200') {
      orderId = response['record']['id'].toString();
      showToast(allTranslations.text('payment_completed'));
      return true;
    } else {
      showToast(response['message']);
      return false;
    }
  }
}
