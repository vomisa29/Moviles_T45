import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutterapp/services/auth_service.dart';
import 'dart:developer';

class LoginVm {

  final _auth = AuthService();

  Future<bool> login(email,password,context) async{
    await FirebaseAnalytics.instance.logEvent(
      name: 'petition_login',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    final user =  await _auth.logInUserWithEmailAndPassword(email, password);
    if (user != null){
      log("User created succesfully");
      return true;
    }
    return false;
  }
}