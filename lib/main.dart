import 'package:flutter/material.dart';
import 'package:localizabus_app/map_screen.dart';
import 'package:localizabus_app/splash_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       title: 'Localizabus',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      routes: {
        '/': (context) => const SplashScreen(),
        '/home-screen': (context) => const MapScreen(),
      },
    );
  }
}