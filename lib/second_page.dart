import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:login/main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
//import 'package:internet_connection_checker/internet_connection_checker.dart';

class SecondClass extends StatefulWidget {
  const SecondClass({Key? key}) : super(key: key);

  @override
  ExampleAppState createState() => ExampleAppState();
}

class ExampleAppState extends State<SecondClass> {
  //final _activityStreamController = StreamController<Activity>();
  final _geofenceStreamController = StreamController<Geofence>();
  static String signcode='';
  bool? result;
  final _geofenceService = GeofenceService.instance.setup(
      interval: 5000,
      accuracy: 100,
      loiteringDelayMs: 60000,
      statusChangeDelayMs: 10000,
      useActivityRecognition: true,
      allowMockLocations: false,
      printDevLog: false,
      geofenceRadiusSortType: GeofenceRadiusSortType.DESC);

  final _geofenceList = <Geofence>[
    Geofence(
      id: 'Epikindifi',
      latitude: 13.0032515,
      longitude: 80.2110552,
      radius: [
        GeofenceRadius(id: 'radius_250m', length: 50),
      ],
    ),

  ];

  Future<void> _onGeofenceStatusChanged(
      Geofence geofence,
      GeofenceRadius geofenceRadius,
      GeofenceStatus geofenceStatus,
      Location location) async {
    print('geofence: ${geofence.toJson()}');
    print('geofenceRadius: ${geofenceRadius.toJson()}');
    print('geofenceStatus: ${geofenceStatus.toString()}');
    print(MyAppState.geostatus);
    if(geofenceStatus==GeofenceStatus.EXIT){
      if(MyAppState.geostatus=='in') {
        setState(() {
          MyAppState.geostatus='no';
        });
        navigate();
      }
    }
    if(geofenceStatus==GeofenceStatus.ENTER||geofenceStatus==GeofenceStatus.DWELL){
      if(MyAppState.geostatus=='no') {
        setState(() {
          MyAppState.geostatus='in';
        });
        navigate();
      }
    }
    _geofenceStreamController.sink.add(geofence);
  }


  /*void _onActivityChanged(Activity prevActivity, Activity currActivity) {
    print('prevActivity: ${prevActivity.toJson()}');
    print('currActivity: ${currActivity.toJson()}');
    _activityStreamController.sink.add(currActivity);
  }*/


  void _onLocationChanged(Location location) async {
   result= await InternetConnectionChecker().hasConnection;
   /* if(result==false){
      setState(() {
        MyAppState.geostatus='no';
      });
    }
    if(result==true){
      setState(() {
        MyAppState.geostatus='in';
      });
    }*/
    print('location: ${location.toJson()}');
  }

  void _onLocationServicesStatusChanged(bool status) {
    print('isLocationServicesEnabled: $status');
  }

  void _onError(error) {
    final errorCode = getErrorCodesFromError(error);
    if (errorCode == null) {
      print('Undefined error: $error');
      return;
    }

    print('ErrorCode: $errorCode');
  }

  Future<void> navigate() async{
    if(MyAppState.geostatus=='in'){
      Navigator.pushNamed(context, '/second');
    }
    if(MyAppState.geostatus=='no'){
      Navigator.pushNamed(context, '/first');
    }
  }

  @override
  void initState() {
    super.initState();
    checkPermissions();
    generateCode();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _geofenceService.addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
      _geofenceService.addLocationChangeListener(_onLocationChanged);
      _geofenceService.addLocationServicesStatusChangeListener(_onLocationServicesStatusChanged);
      //_geofenceService.addActivityChangeListener(_onActivityChanged);
      _geofenceService.addStreamErrorListener(_onError);
      _geofenceService.start(_geofenceList).catchError(_onError);
    });
  }
  void checkPermissions() async{
    var locationStatus=await Permission.location;
    var activityper= await Permission.activityRecognition;
    if(locationStatus!=Permission.location.isGranted){
      await Permission.location.request();
    }
    if(activityper!=Permission.activityRecognition.isGranted){
      await Permission.activityRecognition.request();
    }
  }
  @override
  Widget build(BuildContext context) {
    /*if(MyAppState.geostatus=='in') {
      navigate();
    }*/
    return MaterialApp(

      home: WillStartForegroundTask(
        onWillStart: () async {
          checkPermissions();
          return _geofenceService.isRunningService;
        },
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'geofence_service_notification_channel',
          channelName: 'Geofence Service Notification',
          channelDescription: 'This notification appears when the geofence service is running in the background.',
          channelImportance: NotificationChannelImportance.LOW,
          priority: NotificationPriority.LOW,
          isSticky: false,
        ),
        iosNotificationOptions: const IOSNotificationOptions(),
        notificationTitle: 'Geofence Service is running',
        notificationText: 'Tap to return to the app',
        child: Scaffold(
          appBar: AppBar(
            title: TextButton(child:Text('Go to third'),
                onPressed: ()async
                {
                  //generateCode();
                  }),
            centerTitle: true,
            backgroundColor: Colors.yellow,
          ),
          body:Center(
            child: Text('You are not in the range.Plese come to the range',
            style: TextStyle(
              fontSize: 20.0
            ),),
          ),
        ),
      ),
    );
  }
 void generateCode() async{
   signcode=await SmsAutoFill().getAppSignature;
   print(signcode);
 }
  @override
  void dispose() {
    //_activityStreamController.close();
    _geofenceStreamController.close();
    super.dispose();
  }

}