
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerClass extends StatefulWidget {
  const QRScannerClass({Key? key}) : super(key: key);
  @override
  QRScanner createState()=>QRScanner();
}
class QRScanner extends State<QRScannerClass>{
  final qrKey=GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? barcode;
  static String text='';
  @override
  void initState(){
    super.initState();
    text='';
  }
  @override
  void dispose(){
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() async{
    super.reassemble();
    if(Platform.isAndroid){
      await controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  Widget buildQrView(BuildContext context)=>QRView(
      key: qrKey,
      onQRViewCreated: onQRViewCreated,
       overlay: QrScannerOverlayShape(
       borderWidth: 10,
      borderLength: 20,
      borderRadius: 10,
      cutOutSize: MediaQuery.of(context).size.width*0.8,
  ));

  void onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller=controller;
    });
    if(text=='') {
      controller.scannedDataStream.listen((barcode) {
        setState(() {
          this.barcode = barcode;
          QRScanner.text = barcode.code!;
        });
      });
    }
  }
Widget redirectPage(){
      return Center(child: Text(QRScanner.text));
}
  @override
  Widget build(BuildContext context) {
   return Scaffold(
     body:text!=''?redirectPage():
         Stack(
           alignment: Alignment.center,
           children: [
             buildQrView(context)
           ],
         ),
     );

  }
}
