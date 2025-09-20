import 'dart:io';

import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

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
                //Image.file(File("./Images/Logo_app_SportLink.png")),
                SizedBox(height: 26),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 26),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  ),
                ),
              ],
            )
          )
      ),
      backgroundColor: const Color.fromARGB(255, 255, 252, 249),
      floatingActionButton: FloatingActionButton(
        onPressed: () => (),
      ),
    );
  }

}