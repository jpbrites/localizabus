import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BusSelectPage extends StatefulWidget {
  const BusSelectPage({super.key});

  @override
  State<BusSelectPage> createState() => _BusSelectPageState();
}

class _BusSelectPageState extends State<BusSelectPage> {
// Initial Selected Value
  String selected_bus = 'Ônibus A';

  // List of items in our dropdown menu
  var bus_list = [
    'Ônibus A',
    'Ônibus B',
    'Ônibus C',
    'Ônibus D',
    'Ônibus E',
    'Ônibus F',
  ];

  String selected_route = 'Route 10h';

  var route_list = [
    'Route 10h',
    'Route 12h',
    'Route 16h',
    'Route 6h',
    'Route 20h',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,

        child: Stack(
          children: <Widget>[
            //ElevatedButton(onPressed: (){}, child: Icon(Icons.ice_skating)),
            Image.asset('assets/logo_app.png',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.5),
            Positioned(
                top: MediaQuery.of(context).size.height * 0.5,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                      color: Color(0xFFFFDE59),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(35),
                      )),
                  child: Column(children: [
                    SizedBox(
                      height: 50,
                    ),
                    Text('Qual Ônibus?',
                        style: TextStyle(
                          fontSize: 18,
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * 0.75,
                      height: 75,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                        style: TextStyle(
                          fontSize: 30,
                          color: const Color(0xFF004AAD),
                        ),
                        value: selected_bus,
                        iconSize: 45,
                        elevation: 16,
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: const Color(0xFF004AAD)),
                        items: bus_list.map((String items) {
                          return (DropdownMenuItem(
                            value: items,
                            child: Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Text(items),
                            ),
                          ));
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selected_bus = newValue!;
                          });
                        },
                      )),
                    ),
                    SizedBox(
                      height: 45,
                    ),
                    Text('Qual Rota?',
                        style: TextStyle(
                          fontSize: 18,
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * 0.75,
                      height: 75,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                        style: TextStyle(
                          fontSize: 30,
                          color: const Color(0xFF004AAD),
                        ),
                        value: selected_route,
                        iconSize: 45,
                        elevation: 16,
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: const Color(0xFF004AAD)),
                        items: route_list.map((String items) {
                          return (DropdownMenuItem(
                            value: items,
                            child: Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Text(items),
                            ),
                          ));
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selected_route = newValue!;
                          });
                        },
                      )),
                    )
                  ]),
                )),
            Positioned(
                top: MediaQuery.of(context).size.height * 0.05,
                right:  MediaQuery.of(context).size.width * 0.01,
                height: 50,
                child: ElevatedButton(onPressed: () async {
                       bool loggout = await loggout_Motorist();
                       if(loggout){
                         Navigator.of(context).pushReplacementNamed('/home-screen');
                       }

                },
                  style:  ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll<Color>(Colors.redAccent),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(60),

                        ),
                    ),
                  ),
                  child: Icon(Icons.exit_to_app,size: 30,)))
          ],
        ),
      ),
    );
  }
}


Future <bool> loggout_Motorist() async{
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.clear();
  return true;
}