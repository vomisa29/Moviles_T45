import 'package:show_hide_password/show_hide_password.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/viewmodels/register_vm.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final registerVM = RegisterVm();

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
          child: SingleChildScrollView(
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
                  ShowHidePassword(
                    hidePassword: true,
                    passwordField: (hidePassword){
                    return TextField(
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
                    onPressed: () async{
                      bool registered = await registerVM.register(_emailController.text, _passwordController.text, context);
                      if (registered){
                        context.go('/login');
                      }
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
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                        Text("Already have an account?",
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
                            context.go('/login');
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
              ),
            ),
          )
      ),
      backgroundColor: const Color.fromARGB(255, 255, 252, 249),
    );
  }


}