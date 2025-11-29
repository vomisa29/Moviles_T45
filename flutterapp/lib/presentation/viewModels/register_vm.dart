import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import '../../domain/useCases/useCase_register.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:is_valid/is_valid.dart';

class RegisterVm with ChangeNotifier{
  
  bool _error = false;
  bool get error => _error;

  String? _errorMessage = "";
  String? get errorMessage => _errorMessage;


  final RegisterUseCase _registerUseCase;


  RegisterVm({RegisterUseCase? registerUseCase})
      : _registerUseCase = registerUseCase ?? RegisterUseCase();

  Future<void> register(String email, String password) async {
    final bool isConnected = await InternetConnection().hasInternetAccess;
    if(isConnected){
      await FirebaseAnalytics.instance.logEvent(
        name: 'petition_register',
        parameters: {
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      final result = await _registerUseCase.execute(email: email, password: password);

      if (result.success) {
        log("User registered and created in Firestore successfully");
        _error = false;
        _errorMessage = null;
      }
      _error=true;
      notifyListeners();
      if(!IsValid.validateEmail(email)){
        _errorMessage = "Please enter a valid email.";
        notifyListeners();
        log("Registration failed: ${result.errorMessage}");
      }else{
        _errorMessage = result.errorMessage;
        notifyListeners();
      }
    }else{
      _error=true;
      _errorMessage = "There is a problem with the Internet Connection.\nTry again later.";
      notifyListeners();
    }
  }
}
