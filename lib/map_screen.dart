import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_marker.dart';
import 'menu.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng initialLocation = const LatLng(-9.378346, -40.526745);
  Map<String, BitmapDescriptor> markerIcons = {};

  Timer? timer;
  List<Marker> busMarkers = [], stopMarkers = [];
  late GoogleMapController mapController;
  WebSocketChannel? channel;
  int route = 0;

  @override
  void initState() {
    super.initState();
    addCustomIcon();

    fetchDataFromHTTP(false);
    fetchDataFromHTTP(true);
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      //job
      fetchDataFromHTTP(true);
    });
  }

  BitmapDescriptor getIcon(String name){
    var icon = markerIcons[name];
    if(icon == null){
      return markerIcons["MARKER"]??BitmapDescriptor.defaultMarker;
    }

    return icon;
  }

  void addCustomIcon() {
    var list = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "L", "DEFAULT"];

    list.forEach((element) {
      BitmapDescriptor.fromAssetImage(
        ImageConfiguration(),
        'assets/bus_$element.png',
      ).then(
            (icon) {
          setState(() {
            markerIcons[element == "DEFAULT" ? "?" : element] = icon;
          });
        },
      );
    });
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      'assets/marker_final.png',
    ).then(
          (icon) {
        setState(() {
          markerIcons["MARKER"] = icon;
        });
      },
    );
  }

  void fetchDataFromHTTP(bool isCoordinate, { int attemptsLeft = 3  }) async {
    String url = 'http://67.205.172.182:3333/list${isCoordinate ? 'Coordinates' : 'Stops'}';
    List<Marker> newMarkers = [];
    final http.Response response;

    if(route != 0){
      response = await http.post(Uri.parse("${url}Filtered"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "route_id": route
          })
      );
    }else{
      response = await http.get(Uri.parse(url));
    }

    if(attemptsLeft == 0) {
      print("Failed to fetch 3 times in a row");
      if(!isCoordinate || busMarkers.isNotEmpty){
        return;
      }
      print("Adding default markers");
      newMarkers.add(
        Marker(
            markerId: const MarkerId("A"),
            position: const LatLng(-9.400176, -40.496104),
            icon: getIcon("A"),
            infoWindow: const InfoWindow(
                title: "A"
            ),
          onTap: (){
              route = route == 1 ? 0 : 1;
              if(route != 0){
                fetchDataFromHTTP(false);
              }
              setState(() {});
          },
          zIndex: 10
        )
      );
      newMarkers.add(
          Marker(
              markerId: const MarkerId("B"),
              position: const LatLng(-9.412412, -40.505632),
              icon: getIcon("B"),
              infoWindow: const InfoWindow(
                  title: "B"
              ),
              zIndex: 10
          )
      );

      setState(() {
        busMarkers = newMarkers;
      });
      return;
    }

    if (response.statusCode != 200) {
      print("Failed to fetch data: ${response.statusCode}\nBody: ${response.body}");
      sleep(const Duration(seconds: 1));
      fetchDataFromHTTP(isCoordinate, attemptsLeft: attemptsLeft - 1);
      return;
    }

    final jsonData = json.decode(response.body);
    if (!jsonData.containsKey(isCoordinate ? "coordinates" : "stops")) {
      fetchDataFromHTTP(isCoordinate, attemptsLeft: attemptsLeft - 1);
      return;
    }

    List<dynamic> coordinates = jsonData[isCoordinate ? "coordinates" : "stops"];
    for (var coordinate in coordinates) {
      double lat = double.parse(coordinate["lat"]);
      double lng = double.parse(coordinate["long"]);
      String name = coordinate[isCoordinate ? "letter" : "name"].toString();
      String time = coordinate["created_at"].toString();
      int currentRoute = isCoordinate ? coordinate["route_id"]??0 : 0;
      if(!isCoordinate && route != 0){
        name += ' ${coordinate["date"].toString()}';
      }

      print("Latitude: $lat, Longitude: $lng, Name: $name ");
      newMarkers.add(
        Marker(
            markerId: MarkerId(name + time),
            position: LatLng(lat, lng),
            icon: getIcon(name),
            infoWindow: InfoWindow(
                title: name
            ),
          onTap: (){
              if(isCoordinate){
                route = route == currentRoute ? 0 : currentRoute;
                if(route != 0){
                  fetchDataFromHTTP(false);
                }
                setState(() {});
              }
          },
          zIndex: isCoordinate ? 10 : 0
        )
      );
    }

    if(newMarkers.isEmpty){
      print("Received empty values");
      sleep(const Duration(seconds: 1));
      if(isCoordinate){
        fetchDataFromHTTP(isCoordinate, attemptsLeft: attemptsLeft - 1);
      }else{
        setState(() {
          stopMarkers = [];
        });
      }
      return;
    }

    setState(() {
      if(isCoordinate){
        busMarkers = newMarkers;
      }else{
        stopMarkers = newMarkers;
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
  /*void connectToWebSocket() {
    channel = IOWebSocketChannel.connect('67.205.172.182:3333/listCoordinates');
    channel!.stream.listen((message) {
      Map<String, dynamic> jsonData = json.decode(message);
      if (jsonData.containsKey("coordinates")) {
        List<dynamic> coordinates = jsonData["coordinates"];
        for (var coordinate in coordinates) {
          double lat = double.parse(coordinate["lat"]);
          double lng = double.parse(coordinate["long"]);
          String name = coordinate["id"].toString(); // Nome do marcador pode ser o ID
          print("Latitude: $lat, Longitude: $lng, Name: $name");
          setState(() {
            markers.add(
              MapMarker(
                name: name,
                position: LatLng(lat, lng),
              ),
            );
          });
        }
      }
    });
  }

  @override
  void dispose() {
    channel?.sink.close();
    super.dispose();
  }*/

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = <Marker>{};
    if(route != 0){
      for (var element in stopMarkers) {
        markers.add(element);
      }
    }
    for (var element in busMarkers) {
      markers.add(element);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0049AC),
        title: const Text('LocalizaBus'),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, size: 30),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      endDrawerEnableOpenDragGesture: false,
      drawer: MenuLateral(),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: initialLocation,
          zoom: 13,
        ),
        markers: markers,
      ),
    );
  }
}