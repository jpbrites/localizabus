import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    isLogged().then((value){
      if(value){
        Navigator.of(context).pushReplacementNamed('/busSelectPage');
      }
      else{
        Timer(
          const Duration(seconds: 5),
              () {
            Navigator.of(context).pushReplacementNamed('/home-screen');
          },
        );
      }
    });

    /*Timer(
      const Duration(seconds: 5), 
      () {
        Navigator.of(context).pushReplacementNamed('/home-screen');
      },
    );*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child:
                Image.asset('assets/logo_app.png', width: 300),
                )
            )
          ],
        ),
      ),
    );
  }
}

Future<bool> isLogged() async{
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  if(sharedPreferences.getString('token') != null){
    return true; //caso exista um token, Usuario Logado!
  }
  else{
    return false;
  }
}