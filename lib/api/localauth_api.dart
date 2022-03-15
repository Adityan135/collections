import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
class LocalAuthApi{
static final _auth=LocalAuthentication();

static Future<bool> hasBiometrics() async{
  return await _auth.canCheckBiometrics;
}
static Future<bool> authenticate() async{
  final isAvailable=await hasBiometrics();
  if(!isAvailable){
    return false;
  }
  try {
    return await _auth.authenticateWithBiometrics(
        localizedReason: 'Scan Fingerprint to Authenticate',
        useErrorDialogs: true,
        stickyAuth: true);
  } on PlatformException catch(e){
    return false;
  }
}
}