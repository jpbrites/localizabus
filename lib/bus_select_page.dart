import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class BusSelectPage extends StatefulWidget {
  const BusSelectPage({super.key});

  @override
  State<BusSelectPage> createState() => _BusSelectPageState();
}




String selected_route = 'CCA-07:00-COHAB-PET-JUA';
String selected_bus = 'Onibus 1';

int bus_id=0;
 int route_id=0;

ROTA rota_1 = ROTA(1, "CCA-07:00-COHAB-PET-JUA", "E", 7, "CCA","JUA");
BUS bus_1 = BUS(1,"Onibus 1");

List<BUS> BUS_LIST =[bus_1];
List<ROTA> ROTA_LIST = [rota_1];



class _BusSelectPageState extends State<BusSelectPage> {

  @override
  void initState() {
    get_Routes();
    get_Bus();


  }


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
                        items: BUS_LIST.map((BUS items) {
                          return (DropdownMenuItem(
                            value: items.name,
                            child: Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Text(items.name),
                            ),
                          ));
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selected_bus = newValue!;
                            for (var e in BUS_LIST){
                              if(selected_bus == e.name)
                                {
                                  bus_id= e.id;
                                }
                            }

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
                      width: MediaQuery.of(context).size.width * 0.8,
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
                        items: ROTA_LIST.map((ROTA items) {
                          return (DropdownMenuItem(
                            value: items.name,
                            child: Container(

                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width * 0.65,
                              child: Text(items.name,style: TextStyle(
                                fontSize: 18
                              )),
                            ),
                          ));
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selected_route = newValue!;
                            for (var e in ROTA_LIST){
                              if(e.name == selected_route ){
                                route_id = e.id;
                              }
                            }

                          });
                        },
                      )),
                    ),
                    SizedBox(height: 25,),
                    ElevatedButton(
                        onPressed: ()  async{
                          bool flag = await set_Route();
                          if (flag){
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return alert_Sucess;
                              },
                            );
                          }
                          else{
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return alert_Fail;
                              },
                            );
                          }
                        },
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

Future<Map<String, dynamic>> get_Routes() async{
  SharedPreferences sharedPreferences= await SharedPreferences.getInstance();
  var url= Uri.parse('http://67.205.172.182:3333/listRoutes');

  var response = await http.get(url);

  if(response.statusCode == 200){
    Map<String, dynamic> data = json.decode(response.body);

    // Obtém a lista de rotas
    List<dynamic> rotes = data['routes'];

    // Limpa o vetor de rotas
    ROTA_LIST.clear();

    // Itera sobre a lista de rotas e armazena  no vetor

    for (var route in rotes) {
      ROTA_LIST.add(ROTA(route['id'], route['name'], route['letter'], route['hour'],route['from'], route['to']));

    }
    print(ROTA_LIST[0].id);


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

    // Limpa o vetor BUS LIST
    BUS_LIST.clear();
    // Itera sobre a lista de ônibus e armazena  no vetor
    for (var bus in buses) {
      BUS_LIST.add(BUS(bus['id'],bus['name']));

    }


    return jsonDecode(utf8.decode(response.bodyBytes));
  }
  else {
    throw Exception('Erro ao carregar dados do servidor');
  }
}

Future<bool> set_Route() async{
  SharedPreferences sharedPreferences= await SharedPreferences.getInstance();
  var url= Uri.parse('http://67.205.172.182:3333/createActiveRoute'); // LocalizaBUS

  var response= await http.post(url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, int> {
      "bus_id": bus_id,
      "route_id": route_id
    }),

  );
  print(jsonDecode(response.body).toString());
  print(jsonDecode(response.body)['token'].toString());
  if(response.statusCode == 200){
    await sharedPreferences.setString('token','${jsonDecode(response.body)['token']}');

    return true;
  }
  else {
    return false;
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

class ROTA {
  final int id;
  final String name;
  final String letter;
  final int hour;
  final String from;
  final String to;
  ROTA(this.id, this.name, this.letter, this.hour, this.from, this.to);
}

class BUS {
  final int id;
  final String name;
  BUS(this.id, this.name);
}

AlertDialog alert_Fail = AlertDialog(
  title: Text("Error"),
  content: Text("Não foi possível ativar sua rota"),
  backgroundColor: Colors.redAccent[400],
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

  actions: [
  ],
);
AlertDialog alert_Sucess = AlertDialog(
  title: Text("Tudo certo!"),
  content: Text("Sua rota foi ativada"),
  backgroundColor: Colors.green[400],
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  actions: [
  ],
);