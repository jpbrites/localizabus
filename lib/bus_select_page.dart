import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class BusSelectPage extends StatefulWidget {
  const BusSelectPage({super.key});

  @override
  State<BusSelectPage> createState() => _BusSelectPageState();
}

List<String> buss= [

];

var bus_list = [
  'Onibus 1',


];

String selected_route = 'Selecione o onibus';
String selected_bus = 'Onibus 1';

var route_list = [
  'Selecione o onibus',
  'Route 12h',
];


class _BusSelectPageState extends State<BusSelectPage> {

  @override
  void initState() {
    super.initState();
    get_Bus();

  }
// Initial Selected Value


  // List of items in our dropdown menu


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
                            int temp_bus=busName_to_Number(selected_bus);
                            print(temp_bus);
                            get_Routes(temp_bus);
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
                    ),
                    SizedBox(height: 25,),
                    ElevatedButton(onPressed: (){},
                      style: ButtonStyle(
                        backgroundColor:  MaterialStatePropertyAll<Color>( Color(0xFF004AAD)),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),

                          ),
                      )),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.45,
                          height: MediaQuery.of(context).size.height * 0.06,
                          child: Center(
                            child: Text('Confirma',style: TextStyle(
                              fontSize: 19,

                            )),
                          ),
                        )
                    )
                  ]
                  ),
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
                            borderRadius: BorderRadius.circular(6),

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

Future<Map<String, dynamic>> get_Routes(int _bus_number) async{
  SharedPreferences sharedPreferences= await SharedPreferences.getInstance();
  var url= Uri.parse('http://67.205.172.182:3333/listRoutes');

  var response= await http.get(url);

  if(response.statusCode == 200){
    Map<String, dynamic> data = json.decode(response.body);

    //Obtém a letra do onibus
    String bus_Letter= int_to_letter(_bus_number);
    print(bus_Letter);

    // Obtém a lista de ônibus do mapa
    List<dynamic> rotes = data['routes'];

    // Cria um vetor para armazenar os nomes dos ônibus
    List<String> rotesNames = [];

    route_list.clear();
    // Itera sobre a lista de ônibus e armazena os nomes no vetor
    print(rotes);
    for (var bus in rotes) {
      if( bus_Letter == bus['letter']) {
        String name = bus['hour'];
        print(bus['name']);
        rotesNames.add(name);
      }
    }

    route_list=rotesNames;


    return jsonDecode(utf8.decode(response.bodyBytes));
  }
  else {
    throw Exception('Erro ao carregar dados do servidor');
  }
}

Future<Map<String, dynamic>> get_Bus() async{
  SharedPreferences sharedPreferences= await SharedPreferences.getInstance();
  var url= Uri.parse('http://67.205.172.182:3333/listBus');

  var response= await http.get(url);

  if(response.statusCode == 200){
    Map<String, dynamic> data = json.decode(response.body);
    // Obtém a lista de ônibus do mapa
    List<dynamic> buses = data['bus'];

    // Cria um vetor para armazenar os nomes dos ônibus
    List<String> busNames = [];
    bus_list.clear();
    // Itera sobre a lista de ônibus e armazena os nomes no vetor
    for (var bus in buses) {
      String name = bus['name'];
      busNames.add(name);
    }
    bus_list=busNames;


    return jsonDecode(utf8.decode(response.bodyBytes));
  }
  else {
    throw Exception('Erro ao carregar dados do servidor');
  }
}

String int_to_letter(int number){

    final result = switch (number) {
      1 => 'A',
      2 => 'B',
      3 => 'C',
      4 => 'D',
      5 => 'E',
      6 => 'F',
      7 => 'G',
      8 => 'H',
      9 => 'I',
      10=> 'J',
      11=> 'K',
      12=> 'L',


      _ => 'numero maior que 12', //Valor padrão, substitui o default
    };
    return result;

  }
int busName_to_Number(String busname){

  int bus_number;
  switch(busname) {
    case 'Onibus 1':
       bus_number= 1;
      break;

    case 'Onibus 2':
      bus_number= 2;
      break;

    case 'Onibus 3':
      bus_number= 3;
      break;

    case 'Onibus 4':
      bus_number= 4;
      break;

    case 'Onibus 5':
      bus_number= 5;
      break;



    default: bus_number=0;
  }

  return bus_number;

}