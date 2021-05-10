import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({
    Key key,
  }) : super(key: key);

  @override
  _ScanQRScreenState createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode result;
  QRViewController _controller;

  bool isFlash = false;
  bool isScanned = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller.pauseCamera();
    } else if (Platform.isIOS) {
      _controller.resumeCamera();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var scanArea = MediaQuery.of(context).size.width * 0.7;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        brightness: Brightness.dark,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                      borderColor: Colors.white,
                      borderRadius: 10,
                      borderLength: 30,
                      borderWidth: 10,
                      cutOutSize: scanArea
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      child: ClipOval(
                        child: Material(
                          color: Colors.white,
                          child: InkWell(
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: Icon(
                                Icons.help,
                                color: Colors.black45,
                              ),
                            ),
                            onTap: () {},
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(15),
                      child: ClipOval(
                        child: Material(
                          color: Colors.white,
                          child: InkWell(
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: Icon(
                                isFlash ? Icons.flash_off : Icons.flash_on,
                                color: Colors.black45,
                              ),
                            ),
                            onTap: () {
                             setState(() {
                               isFlash = !isFlash;
                             });
                             _controller.toggleFlash();
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            )
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  "assets/images/food.png",
                  fit: BoxFit.cover,
                  height: 80,
                ),
                SizedBox(
                  height: 8,
                ),
                Text("Let's Get Started", style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold
                ),),
                SizedBox(
                  height: 8,
                ),
                Text(
                  "Scan QR Code yang diberikan oleh waiter di meja resepsionis agar"
                      " dapat mulai melakukan pemesanan.",
                  style: TextStyle(
                      fontSize: 16
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this._controller = controller;

    controller.scannedDataStream.listen((scanData) {
      if (!isScanned) {
        HapticFeedback.heavyImpact();
        print(scanData.code);
        setState(() {
          isScanned = true;
          result = scanData;
        });
        _showErrorOnScanQRCode();
      }
    });
  }

  void _showErrorOnScanQRCode() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        builder: (builder) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 20),
            height: 300,
            child: Column(
              children: [
                Image.asset(
                  "assets/images/error.png",
                  fit: BoxFit.cover,
                  height: 150,
                ),
                Text("Can't use this QR Code", style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26
                ),),
                SizedBox(
                  height: 8,
                ),
                Text(
                  "QR Code tidak valid dan tidak dapat digunakan untuk melakukan pemesanan mandiri.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Mengerti'),
                  ),
                ),
              ],
            ),
          );
        }
    ).whenComplete(() {
      setState(() {
        isScanned = false;
      });
    });
  }
}