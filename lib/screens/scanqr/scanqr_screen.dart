import 'dart:io';

import 'package:akbmobile/api/api_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({
    Key key,
  }) : super(key: key);

  @override
  _ScanQRScreenState createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String result;
  QRViewController _controller;

  bool isFlash = false;
  bool isScanned = false;
  bool isLoading = false;

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
                        cutOutSize: scanArea),
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
              )),
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
                Text(
                  "Let's Get Started",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  "Scan QR Code yang diberikan oleh waiter di meja resepsionis agar"
                  " dapat mulai melakukan pemesanan.",
                  style: TextStyle(fontSize: 16),
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
          isLoading = true;
          result = scanData.code;
        });
        DialogBuilder(context).showLoadingIndicator('Mohon Tunggu');
        _cek(result);
      }
    });
  }

  void _cek(res) async {
    final response = await http
        .post(Uri.parse(ApiHelper().getBaseUrl() + 'order/' + res + '/check'));

    DialogBuilder(context).hideOpenDialog();
    if (response.statusCode == 200) {
      print(response.body.toString());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', res);
      Navigator.pop(context, res);
    } else {
      _showErrorOnScanQRCode();
    }
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
                Text(
                  "Can't use this QR Code",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                ),
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
        }).whenComplete(() {
      setState(() {
        isScanned = false;
      });
    });
  }
}

class LoadingIndicator extends StatelessWidget {
  LoadingIndicator({this.text = ''});
  final String text;
  @override
  Widget build(BuildContext context) {
    var displayedText = text;
    return Container(
        padding: EdgeInsets.all(16),
        color: Colors.black87,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _getLoadingIndicator(),
              _getHeading(context),
              _getText(displayedText)
            ]));
  }

  Padding _getLoadingIndicator() {
    return Padding(
        child: Container(
            child: CircularProgressIndicator(strokeWidth: 3),
            width: 32,
            height: 32),
        padding: EdgeInsets.only(bottom: 16));
  }

  Widget _getHeading(context) {
    return Padding(
        child: Text(
          'Please wait …',
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        padding: EdgeInsets.only(bottom: 4));
  }

  Text _getText(String displayedText) {
    return Text(
      displayedText,
      style: TextStyle(color: Colors.white, fontSize: 14),
      textAlign: TextAlign.center,
    );
  }
}

class DialogBuilder {
  DialogBuilder(this.context);
  final BuildContext context;
  void showLoadingIndicator([String text]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              backgroundColor: Colors.black87,
              content: LoadingIndicator(text: text),
            ));
      },
    );
  }

  void hideOpenDialog() {
    Navigator.of(context).pop();
  }
}
