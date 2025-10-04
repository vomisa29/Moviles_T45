//import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterapp/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //final _auth = AuthService();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose(){
    super.dispose();
    _usernameController.dispose();
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
                Image.asset("lib/assets/Logo_app_SportLink.png"),
                SizedBox(height: 26),
                TextField(
                  controller: _usernameController,
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
                  onPressed: () {
                    //TODO
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 49, 177, 121),
                    textStyle: TextStyle(
                      
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1)
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                child: Text(
                  "Already have an account? Sign Up",
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

}