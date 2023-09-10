import 'dart:io';

import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/widget/appbar.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRCodeScanScreen extends StatefulWidget {
  const QRCodeScanScreen() : super();

  @override
  _QRCodeScanScreenState createState() => _QRCodeScanScreenState();
}

class _QRCodeScanScreenState extends State<QRCodeScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  bool dataLoad = false;
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        text: allTranslations.text("scanning"),
        textColour: Colors.black,
        backgroundColour: Colors.white,
        onTap: () {
          Navigator.pop(context);
        },
      ),
      body: Container(
        child: Stack(
          children: [
            Container(
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
            Positioned(
                left: 0,
                right: 0,
                bottom: 90,
                child: Text(
                  allTranslations.text("scan_instruction"),
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15),
                  textAlign: TextAlign.center,
                ))
          ],
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null && scanData.code!.isNotEmpty) {
        String? walletId = scanData.code;
        if (walletId != null && !dataLoad) {
          dataLoad = true;
          Navigator.pop(context, walletId);
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
