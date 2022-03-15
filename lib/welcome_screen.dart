import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';

class WelcomeClass extends StatefulWidget {
  const WelcomeClass({Key? key}) : super(key: key);
  @override
  _Welcome createState()=>_Welcome();
}
class _Welcome extends State<WelcomeClass> {

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final qrKey=GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  DateTime timeBackPressed=DateTime.now();

  @override
  void initState(){
    super.initState();
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSInitialize=new IOSInitializationSettings();
    var initializationSettings=new InitializationSettings(android: initializationSettingsAndroid,iOS: iOSInitialize);
    flutterLocalNotificationsPlugin=new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  void dispose(){
   super.dispose();
  }

Future getNotification() async{
 var androidDetails=new AndroidNotificationDetails("channelId","local Notification",importance: Importance.high);
 var iosDetails=new IOSNotificationDetails();
 var generalNotificationDetails=new NotificationDetails(android: androidDetails,iOS: iosDetails);
 await flutterLocalNotificationsPlugin.show(0, 'Welcome', 'Welcome to Collections', generalNotificationDetails);
}

showToast(){
    Fluttertoast.showToast(msg:'You cannot go back now.');
}


  @override
  Widget build(BuildContext context){
    return new WillPopScope(
      onWillPop: () async{
        final difference=DateTime.now().difference(timeBackPressed);
        final isExitWarning=difference>=Duration(seconds: 2);
       timeBackPressed=DateTime.now();
       if(isExitWarning){
         final message='Press again to exit.';
         Fluttertoast.showToast(msg: message);

         return false;
       }
       else{
         Fluttertoast.cancel();
         SystemChannels.platform.invokeMethod('SystemNavigator.pop');
         return true;
       }

      },
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text('Welcome Screen'),
            leading: IconButton(
              icon: Icon(Icons.arrow_circle_left),
              onPressed: (){showToast();}
            ),
          ),
          body: Column(
            children: [Center(
              child: Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 20.0
                ),
              ),
            ),
              TextButton(
                onPressed: () {
                 getNotification();
                },
                child: Text("Show Notification"),
              ),
              TextButton(onPressed:(){
               Navigator.pushNamed(context, '/printer');
              },child: Text(
                'Find Bluetooth Devices'
              )),
              TextButton(onPressed:(){Navigator.pushNamed(context, '/qrscanner');} , child: Text(
                'Scan Bar Code'
              )),
              TextButton(onPressed: (){
                Navigator.pushNamed(context, '/googlemaps');
              }, child: Text('Go to Google Maps')),
              TextButton(onPressed:(){
                Navigator.pushNamed(context,'/details');
              }, child: Text('Details'))
           ],
          ),
        ),
      ),
    );
  }
}
