import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import '../model/serviceAdapters/auth_adapter.dart';

class AppUser {
  final String uid;
  final String? email;
  final String? displayName;

  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
  });
}

class AuthNotifier extends ChangeNotifier {
  final AuthService _authService = AuthService();
  AppUser? _user;
  late final Stream<AppUser?> _authStateChanges;

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;

  AuthNotifier() {
    _authStateChanges = _authService.authStateChanges.map(_mapFirebaseUser);
    _authStateChanges.listen((appUser) {
      _user = appUser;
      notifyListeners();
    });
  }


  AppUser? _mapFirebaseUser(firebase_auth.User? firebaseUser) {
    if (firebaseUser == null) {
      return null;
    }
    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
    );
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
