import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/widget/appbar.dart';
import 'package:avauserapp/walletData/qr_code/qr_code_scan.dart';
import 'package:flutter/material.dart';

class QRCodeHomeScreen extends StatelessWidget {
  final String _qrCodeImageLink;
  final String _walletId;

  const QRCodeHomeScreen({
    required String walletId,
    required String qrCodeImageLink,
  })  : _walletId = walletId,
        _qrCodeImageLink = qrCodeImageLink,
        super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        text: allTranslations.text("share_qr_code"),
        textColour: Colors.black,
        backgroundColour: Colors.white,
        onTap: () {
          Navigator.pop(context);
        },
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            QRCodeCard(_walletId, _qrCodeImageLink),
            SizedBox(height: 30),
            ScanQRButton(
              onTap: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => QRCodeScanScreen(),
                  ),
                );
                if (result != null) {
                  Navigator.pop(context, result);
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

class ScanQRButton extends StatelessWidget {
  final void Function() _onTap;
  const ScanQRButton({required void Function() onTap})
      : _onTap = onTap,
        super();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ElevatedButton(
        style: ButtonStyle(
          fixedSize: MaterialStateProperty.all<Size>(Size(200, 50)),
          backgroundColor:
              MaterialStateProperty.all<Color>(AppColours.appTheme),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
          ),
        ),
        onPressed: _onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code),
            SizedBox(width: 15),
            Text(
              allTranslations.text("scan_qr_code"),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class QRCodeCard extends StatelessWidget {
  final _phoneNumber;
  final _qrCodeLink;
  const QRCodeCard(this._phoneNumber, this._qrCodeLink) : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Card(
        elevation: 5,
        child: Column(
          children: [
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: AppColours.appTheme,
                  size: 35,
                ),
                SizedBox(width: 5),
                Text(
                  _phoneNumber,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 28,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Image.network(_qrCodeLink),
            )
          ],
        ),
      ),
    );
  }
}
