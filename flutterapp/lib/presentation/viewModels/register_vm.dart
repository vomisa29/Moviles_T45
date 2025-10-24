import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import '../../domain/useCases/useCase_register.dart';

class RegisterVm {
  final RegisterUseCase _registerUseCase;
  String? errorMessage;

  RegisterVm({RegisterUseCase? registerUseCase})
      : _registerUseCase = registerUseCase ?? RegisterUseCase();

  Future<bool> register(String email, String password, BuildContext context) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'petition_register',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    final result = await _registerUseCase.execute(email: email, password: password);

    if (result.success) {
      log("User registered and created in Firestore successfully");
      errorMessage = null;
      return true;
    } else {
      errorMessage = result.errorMessage;
      log("Registration failed: ${result.errorMessage}");
      return false;
    }
  }
}
