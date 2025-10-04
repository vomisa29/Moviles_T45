import 'package:flutterapp/services/auth_service.dart';
import 'dart:developer';


class RegisterVm {
  final _auth = AuthService();

  void register(email,password,context) async{
   final user =  await _auth.createUserWithEmailAndPassword(email,password);
   if (user != null){
     log("User created succesfully");

     context.go('/login');
   }
  }
}