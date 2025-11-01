import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutterapp/model/serviceAdapters/auth_adapter.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:is_valid/is_valid.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class LoginVm with ChangeNotifier {

  final _auth = AuthService();

  bool _error = false;
  bool get error => _error;

  String _errorMessage = "";
  String get errorMessage => _errorMessage;

  Future<void> login(String email,String password) async{

    final bool isConnected = await InternetConnection().hasInternetAccess;
    if(isConnected){
      //Only tries lo login if there's an Internet Connection
      await FirebaseAnalytics.instance.logEvent(
      name: 'petition_login',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
        },
      );

      final user =  await _auth.logInUserWithEmailAndPassword(email, password);
      if (user != null){
        log("User created succesfully");
        _error = false;
      }
      //Failed the login process
      
      _error=true;
      notifyListeners();
      if (!IsValid.validateEmail(email)){
        _errorMessage = "Please enter a valid email.";
        notifyListeners();
      }else{
        _errorMessage = "Invalid Credentials.";
        notifyListeners();
      }

    }
    else{
      _error=true;
      _errorMessage = "There is a problem with the Internet Connection.\nTry again later.";
      notifyListeners();
    }
    
  }
}