//import 'dart:io';

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutterapp/presentation/register.dart';
import 'package:flutterapp/services/auth_service.dart';
import 'package:flutterapp/presentation/main_view.dart';

import 'package:go_router/go_router.dart';

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
                Image.asset("lib/assets/Logo_app_SportLink.png",height: 400),
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
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1)
                    ),
                  ),
                ),
                SizedBox(height: 14),
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
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                      Text("Don't have an account?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Color(0xFF87879D),
                        ),
                      ),
                      TextButton(
                        onPressed: (){
                          //goToRegisterView(context);
                          context.go('/register');
                        },
                        child: Text(
                          textAlign: TextAlign.center,
                          "Sign in",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Color.fromARGB(255, 82, 186, 255),
                          ),
                        ),
                      ),       
                    ],
                  )
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

  goToRegisterView(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const RegisterPage()));

  _login() async{
    final user =  await _auth.logInUserWithEmailAndPassword(_emailController.text, _passwordController.text);
    if (user != null){
      log("User created succesfully");
      //goToMainView(context);
      context.go('/main_view');
    }
  }
}