
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;


  Future<User?> createUserWithEmailAndPassword(String email, String password) async{
    try{
      log(email);
      log(password);
      final credentials = await _auth.createUserWithEmailAndPassword(email:email,password:password);
      return credentials.user;
    }catch(e){
      log("Something went wrong");
      //in case theres no internet connection
    }
    return null;
  }

  Future<User?> logInUserWithEmailAndPassword(String email, String password) async{
    try{
      final credentials = await _auth.signInWithEmailAndPassword(email:email,password:password);
      return credentials.user;
    }catch(e){
      log("Something went wrong");
      //in case theres no internet connection
    }
    return null;
  }

}