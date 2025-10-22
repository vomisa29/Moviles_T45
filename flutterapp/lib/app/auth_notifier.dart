import 'package:flutter/material.dart';
import '../model/serviceAdapters/auth_adapter.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;

class AppUser {
  final String uid;
  final String? email;
  const AppUser({required this.uid, this.email});
}

class AuthNotifier extends ChangeNotifier {
  final AuthService _authService = AuthService();
  AppUser? _user;

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;

  AuthNotifier() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? firebaseUser) {
    if (firebaseUser == null) {
      _user = null;
    } else {
      _user = AppUser(uid: firebaseUser.uid, email: firebaseUser.email);
    }
    notifyListeners();
  }
  Future<void> signOut() async {
    await _authService.signOut();
  }
}
