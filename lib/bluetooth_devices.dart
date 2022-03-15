import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:flutter/material.dart';

class BluetoothClass extends StatefulWidget {
  const BluetoothClass({Key? key}) : super(key: key);

  @override
  _BluetoothPrinter createState() => _BluetoothPrinter();
}
class _BluetoothPrinter extends State<BluetoothClass> {
  BluetoothPrint bluetoothprint=BluetoothPrint.instance;
  List<BluetoothDevice> _devices=[];
  String _deviceMsg='';
  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_)=> {initPrinter()});
  }
  Future<void> initPrinter() async{
   bluetoothprint.startScan(timeout: Duration(seconds: 2));
   if(!mounted) return;
   bluetoothprint.scanResults.listen((event) {
     if(!mounted) return;
     setState(() {
       _devices=event;
     });
     if(_devices.isEmpty){
       _deviceMsg='No devices available';
     }
   });
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bluetooth Devices'
        ),
      ),
      body: ListView.builder(
             itemCount: _devices.length,
              itemBuilder: (c,i){
               return ListTile(
                 leading: Icon(Icons.print),
                 title: Text(_devices[i].name.toString()),
                 subtitle: Text(_devices[i].address.toString()),
                 onTap: (){},
               );
              })
    );
  }
}