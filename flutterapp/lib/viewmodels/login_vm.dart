import 'package:flutterapp/services/auth_service.dart';
import 'dart:developer';

class LoginVm {

  final _auth = AuthService();

  void login(email,password,context) async{
    final user =  await _auth.logInUserWithEmailAndPassword(email, password);
    if (user != null){
      log("User created succesfully");
      context.go('/main_view');
    }
  }
}