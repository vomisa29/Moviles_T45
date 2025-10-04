//import 'dart:io';

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutterapp/auth_service.dart';
import 'package:flutterapp/main_view.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _auth = AuthService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose(){
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Most of the structure is here
      body:Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset("lib/Images/Logo_app_SportLink.png"),
                SizedBox(height: 26),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                  labelText: 'Enter Email',
                  border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 26),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                  labelText: 'Enter Password',
                  border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 26),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 49, 177, 121),
                    textStyle: TextStyle(
                      
                    ),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1)
                    ),
                  ),
                ),
                SizedBox(height: 26),
                Center(
                  child: Text(
                    'Forgot Password?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF87879D),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                child: Text(
                  "Don't have an account? Sign Up",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Color(0xFF87879D),
                    ),
                  ),
                ),
              ],
            )
          )
      ),
      backgroundColor: const Color.fromARGB(255, 255, 252, 249),
    );
  }
  goToMainView(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const MainView()));

  _login() async{
    final user =  await _auth.createUserWithEmailAndPassword(_emailController.text, _passwordController.text);
    if (user != null){
      log("User created succesfully");
      goToMainView(context);
    }
  }
}