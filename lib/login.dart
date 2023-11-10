import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}


final _formkey = GlobalKey<FormState>();
final _emailController = TextEditingController();
final _passwordController = TextEditingController();

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
  }

  /*
  final _formkey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  */


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formkey,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[

                    Image.asset('assets/logo_app.png', width: MediaQuery.of(context).size.width * 0.2),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'E-mail',

                      ),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (email){
                        if(email == null || email.isEmpty){
                          return 'Por favor, digite seu e-mail';
                        } else if(!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(_emailController.text)) {
                          return 'Por favor, digite um e-mail valido';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      decoration:  InputDecoration(
                        labelText: 'Senha',

                      ),
                      controller: _passwordController,
                      keyboardType: TextInputType.text,
                      validator: (senha){
                        if(senha == null || senha.isEmpty){
                          return'Por favor, digite sua senha';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32.0),
                    MaterialButton(
                      minWidth: 300,
                      onPressed: () async {
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if(_formkey.currentState!.validate()){
                            bool form_OK = await request_Login();
                            if(!currentFocus.hasPrimaryFocus){
                              currentFocus.unfocus();
                            }
                            if(form_OK){
                              Navigator.of(context).pushReplacementNamed('/busSelectPage');
                            }
                            else {
                              _passwordController.clear();
                              ScaffoldMessenger.of(context).showSnackBar((snackBar));
                            }
                        }
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      color: const Color(0xFFFFDE59),
                      textColor: Color(0xFF004AAD),
                      child: const Text(
                        'ENTRAR',
                        style: TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
      ),
    );
  }
}

final snackBar = SnackBar(
    content: Text('e-mail ou senha são inválidos', textAlign: TextAlign.center,
      style: TextStyle(backgroundColor: Colors.redAccent ),
    )
);

Future<bool> request_Login( ) async {
  SharedPreferences sharedPreferences= await SharedPreferences.getInstance();
  //var url= Uri.parse('http://67.205.172.182:3333/sessions'); // LocalizaBUS
  var url= Uri.parse('https://restful-booker.herokuapp.com/auth');
 /* var response= await http.post(url,
    body: {
      "email": _emailController.text,
      "password": _passwordController.text,
    },
  );*/
  var response= await http.post(url,
    body: {
      "username": _emailController.text,
      "password": _passwordController.text,
    },
  );
  if(response.statusCode == 200){ //nao esta verficando a existencia do token
    print(jsonDecode(response.body)['reason']);
    return true;
  }else{
    print('NAO AUTORIZADO');
    return false;
  }
}
