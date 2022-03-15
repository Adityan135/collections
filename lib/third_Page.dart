import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:login/main.dart';
import 'package:login/second_page.dart';
import 'package:login/welcome_screen.dart';
import 'package:pinput/pinput.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_otp/flutter_otp.dart';
import 'package:sms/sms.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
class ThirdClass extends StatefulWidget {
  const ThirdClass({Key? key}) : super(key: key);
  @override
  OtpState createState()=>OtpState();


}
class OtpState extends State<ThirdClass>{

static String mobilenum='';
String verificationid='';
late TwilioFlutter twilioFlutter;



  @override
  void initState(){
    super.initState();
    twilioFlutter = TwilioFlutter(
        accountSid: 'AC62e177435ec3d9a9ad95b3ae6c5f2e82',
        authToken: '72090cb9f141459647e190446f305130',
        twilioNumber: '+17315959576');
    listen_otp();
  }
  @override
  Widget buildPinPut() {
    return Pinput(
      onCompleted: (pin) => print(pin),
    );
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: MaterialApp(
        home: Scaffold(
        body:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [Text('OTP Verification',style: TextStyle(fontSize: 20.0),),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: PinFieldAutoFill(
                textInputAction:TextInputAction.none,
        codeLength: 4,
        onCodeChanged: (val){
          print(val!.length);
          if(val.length==4){
            Navigator.pushNamed(context, '/welcome');
          }
        },
      ),
            ),
            TextButton(onPressed: (){generateOTP();}, child: Text('Generate OTP'))
         ]
        )
        )
      ),
    );
  }
void generateOTP() async{
/*SmsSender s=new SmsSender();
print(MyAppState.selectedsimcard);
s.sendSms(new SmsMessage('+'+MyAppState.selectedsimcard,'<#>abc abc 3456\n'+ExampleAppState.signcode));*/
  twilioFlutter.sendSMS(
      toNumber: '+'+MyAppState.selectedsimcard, messageBody: '<#>abc abc 3456\n'+ExampleAppState.signcode);
}
  void listen_otp() async{
    await SmsAutoFill().listenForCode;
  }

}