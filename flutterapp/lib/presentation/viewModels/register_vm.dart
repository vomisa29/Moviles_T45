import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutterapp/model/serviceAdapters/auth_adapter.dart';
import 'dart:developer';


class RegisterVm {
  final _auth = AuthService();

  Future<bool> register(email,password,context) async{
    await FirebaseAnalytics.instance.logEvent(
      name: 'petition_register',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
   final user =  await _auth.createUserWithEmailAndPassword(email,password);
   if (user != null){
     log("User registered succesfully");
     return true;
   }
   return false;
  }
}