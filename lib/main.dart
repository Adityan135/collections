
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
//import 'package:geofence_service/geofence_service.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:login/api/localauth_api.dart';
import 'package:login/bluetooth_devices.dart';
import 'package:login/details.dart';
import 'package:login/google_maps.dart';
import 'package:login/qr_scanner.dart';
import 'package:login/welcome_screen.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'second_page.dart';
import 'third_Page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_settings/open_settings.dart';
import 'package:firebase_core/firebase_core.dart';
Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(routes: {
    '/first': (context) => SecondClass(),
    '/second': (context) => ThirdClass(),
    '/welcome':(context)=>WelcomeClass(),
    '/printer':(context)=>BluetoothClass(),
    '/qrscanner':(context)=>QRScannerClass(),
    '/googlemaps':(context)=>GoogleMapsClass(),
    '/details':(context)=>DetailsClass()
  }, home: MyApp()));

}
class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  static final String openSignalid="ec449d41-6ee4-472f-bd89-ba42559ff90e";
  LocationPermission _locationPermission=LocationPermission.denied;
  static String geostatus='no';
  static bool internetcon=false;
  String _platformImei = 'Unknown';
  String uniqueId = "Unknown";
  static String selectedsimcard='';
  String _mobileNumber = '';
  List<SimCard> _simCard = <SimCard>[];
  static Position position=Position(longitude: 0, latitude: 0, timestamp: new DateTime.now(), accuracy: 0, altitude: 0, heading:0 , speed: 0, speedAccuracy: 0);

  @override
  void initState() {
    super.initState();
    //_determinePosition();
    initPlatformState();
    MobileNumber.listenPhonePermission((isPermissionGranted) {
      if (isPermissionGranted) {
        //initPlatformState();
        askPermissions();
      } else {
       openAppSettings();
      }
    });
   // initPlatformState();
    askPermissions();
  }

 void askPermissions() async {
   var phonestatus = await MobileNumber.hasPhonePermission;
   var locationstatus = await Geolocator.checkPermission();
   var bluetoothper=await Permission.bluetooth;
   var bluetooth2per=await Permission.bluetoothScan;
   var smsservice=await Permission.sms;
   var contactsper=await Permission.contacts;
   bool serviceEnabled=await Geolocator.isLocationServiceEnabled();
   String platformImei;
   String idunique = '';
    String mobileNumber = '';

   if (!await MobileNumber.hasPhonePermission) {
     await MobileNumber.requestPhonePermission;
     return;
   }
   if(await bluetoothper!=Permission.bluetooth.isGranted){
     await Permission.bluetooth.request();
   }
   if(await bluetooth2per!=Permission.bluetoothScan.isGranted){
     await Permission.bluetoothScan.request();
   }
if(await smsservice!=Permission.sms.isGranted){
  await Permission.sms.request();
}
if(await contactsper!=Permission.contacts.isGranted){
  await Permission.contacts.request();
}
   if (!serviceEnabled) {
     OpenSettings.openLocationSourceSetting();
     return Future.error('Location services are disabled.');
   }
   if (locationstatus == LocationPermission.denied) {
     locationstatus = await Geolocator.requestPermission();
   }
   if (locationstatus == LocationPermission.denied) {
     openAppSettings();
     return Future.error('Location permissions are denied');
   }
   if (locationstatus == LocationPermission.deniedForever) {

     return Future.error(
         'Location permissions are permanently denied, we cannot request permissions.');
   }
   try {
     mobileNumber = (await MobileNumber.mobileNumber)!;
     _simCard = (await MobileNumber.getSimCards)!;
     platformImei =
     await ImeiPlugin.getImei(shouldShowRequestPermissionRationale: false);
     List<String> multiImei = await ImeiPlugin.getImeiMulti();
     //print(multiImei);
     idunique = await ImeiPlugin.getId();
   } on PlatformException {
     platformImei = 'Failed to get platform version.';
   }

   if (!mounted) return;

   Position position=await Geolocator.getCurrentPosition();
   setState(() {
     _locationPermission=locationstatus;
     MyAppState.position=position;
     _platformImei = platformImei;
     uniqueId = idunique;
     _mobileNumber = mobileNumber;
   });
 }
  Future<void> initPlatformState() async{
    OneSignal.shared.setAppId(openSignalid);
  }

  Widget fillCards() {
    List<Widget> widgets = _simCard
        .map((SimCard sim) => Container(
        child: TextButton(
          onPressed: (){
            setState(() {
              selectedsimcard=sim.number.toString();
              OtpState.mobilenum='+'+selectedsimcard;
            });
            print(sim.displayName);
          },
          child: Card(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 50.0),
              child: ListTile(
                leading: Icon(
                  Icons.phone,
                  color: Colors.teal,
                ),
                title: Text(
                  '${sim.number}',
                  style: TextStyle(color: Colors.teal),
                ),
              )),
        )
    ))
        .toList();
    return Column(children: widgets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Text(
              'Imei:$_platformImei',
              style: TextStyle(
                fontSize: 20.0
              ),
            ),
            Text(
              'location:${MyAppState.position}',
              style: TextStyle(
                fontSize: 20.0
              ),
            ),
            Center(
              child: Text(
                'Choose a number:',
                style: TextStyle(
                  fontSize: 20.0
                ),
              ),
            ),
            fillCards(),
            Text(
              'Number Selected:$selectedsimcard',
              style: TextStyle(
                fontSize: 20.0
              ),
            ),
            TextButton(onPressed: () async{
              final isAuthenticated=await LocalAuthApi.authenticate();
              if(isAuthenticated){
                Navigator.pushNamed(context, '/first');
               print('Authenticated');
              };
            }, child: Text('Authenticate'))
      ]
        ),
      );

  }

}
