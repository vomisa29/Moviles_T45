import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      log(email);
      log(password);
      final credentials = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credentials.user;
    } catch (e) {
      //en caso de que no haya internet
      log("Something went wrong during user creation: $e");
    }
    return null;
  }

  Future<User?> logInUserWithEmailAndPassword(String email, String password) async {
    try {
      final credentials = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credentials.user;
    } catch (e) {
      //en caso de que no haya internet
      log("Something went wrong during login: $e");
    }
    return null;
  }


  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log("Something went wrong during sign out: $e");
    }
  }
}
