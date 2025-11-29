import 'package:show_hide_password/show_hide_password.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/presentation/viewModels/register_vm.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final RegisterVm registerVm = RegisterVm();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => registerVm,
      child: Scaffold(
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
                    border: const OutlineInputBorder(),
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
                  const SizedBox(height: 26),
                  ElevatedButton(
                    onPressed: (){
                      _register(context,_emailController.text, _passwordController.text,registerVm);
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
                        const Text("Already have an account?",
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
                          child: const Text(
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
      ),
    );
  }

  void _register(BuildContext context,String email, String password, RegisterVm registerVm) async{
    await registerVm.register(email, password);
    _registerButtonAction(context,registerVm.error,registerVm.errorMessage);
  }

  Future<void> _registerButtonAction(BuildContext context, bool error, String? errorMessage) async{
    if (error){
      return showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              title: Text(errorMessage ?? "Something went wrong :("),
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
  }

}