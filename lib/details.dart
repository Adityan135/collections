import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:login/qr_scanner.dart';

class DetailsClass extends StatefulWidget {
  const DetailsClass({Key? key}) : super(key: key);
  @override
  _Details createState()=>_Details();
}
class _Details extends State<DetailsClass> {
  String details='';
  @override
  void initState(){
    super.initState();
    details=QRScanner.text;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(title:Text('Details')),
     body:Column(children: [Text(details),TextButton(onPressed: (){
       setState(() {
         QRScanner.text='';
         details='';
       });
     }, child: Text('Clear Details'))]),
    );
  }
}