import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds: 5), 
      () {
        Navigator.of(context).pushReplacementNamed('/home-screen');
      },
    );
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
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Image.asset('assets/logo_bus.png', width: 300),
              )
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 19.0),
              child: Image.asset('assets/logo_univasf_new.png', width: 180),
              )
          ],
        ),
      ),
    );
  }
}
