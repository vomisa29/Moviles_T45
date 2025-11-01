import 'package:show_hide_password/show_hide_password.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/presentation/viewModels/login_vm.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'dart:developer';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _LoginPageState();
  }
}

class _LoginPageState extends StatelessWidget{
  _LoginPageState();

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final LoginVm loginVm = LoginVm();
    
    return ChangeNotifierProvider(
      create: (context) => loginVm,
      child: Scaffold(
      //Most of the structure is here
      body:Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("lib/assets/Logo_app_SportLink.png",height: 300),
                  SizedBox(height: 26),
                  TextField(
                    inputFormatters: [
                        LengthLimitingTextInputFormatter(30),
                    ],
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Enter Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 26),
                  ShowHidePassword(
                    hidePassword: true,
                    passwordField: (hidePassword){
                    return TextField(
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(20),
                        ],
                        obscureText: hidePassword,
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Enter Password',
                          border: OutlineInputBorder(),
                        ),
                      );
                    }
                  ),
                  SizedBox(height: 26),
                  ElevatedButton(
                    onPressed: (){
                        _login(context,_emailController.text, _passwordController.text,loginVm);
                      },
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
                            "Sign up",
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
              ),
            ),
          )
      ),
      backgroundColor: const Color.fromARGB(255, 255, 252, 249),
      ),
    );
  }

  void _login(BuildContext context, email, String password, LoginVm loginVm) async{
    await loginVm.login(_emailController.text, _passwordController.text);
    _loginButtonAction(context,loginVm.error,loginVm.errorMessage);
  }


  Future<void> _loginButtonAction(BuildContext context, bool error, String errorMessage) async{
    
    if (error){
      log(errorMessage);
      return showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              title: Text(errorMessage),
              actions: [
                ElevatedButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text("Ok")
                ),
              ],
            );
          }
      );
    }
    else{
    }
  }
}