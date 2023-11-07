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
 

  LatLng initialLocation = const LatLng(-9.401404, -40.503057);
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  /*List<MapMarker> markers = [
    MapMarker(
      name: "Marker 1",
      position: LatLng(-9.412412, -40.505632),
    ),
    MapMarker(
      name: "Marker 2",
      position: LatLng(-9.400176, -40.496104),
    ),
  ];*/

  Set<MapMarker> markers = Set<MapMarker>(); //*
  late GoogleMapController mapController;
  WebSocketChannel? channel; //*


  @override
  void initState() {
    super.initState();
    addCustomIcon(); 
     fetchDataFromHTTP();
  }

  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(), "assets/marker_final.png",
    ).then(
      (icon) {
        setState(() {
          markerIcon = icon;
        });
      },
    );
  }

   void fetchDataFromHTTP() async {
    final response = await http.get(Uri.parse('http://67.205.172.182:3333/listCoordinates'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData.containsKey("coordinates")) {
        List<dynamic> coordinates = jsonData["coordinates"];
        for (var coordinate in coordinates) {
          double lat = double.parse(coordinate["lat"]);
          double lng = double.parse(coordinate["long"]);
          String name = coordinate["id"].toString();
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
    } else {
      print("Failed to fetch data: ${response.statusCode}");
    }
  }

  @override
  void dispose() {
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0049AC),
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
          zoom: 15,
        ),
        markers: Set<Marker>.from(markers.map((marker) {
          return Marker(
            markerId: MarkerId(marker.name),
            position: marker.position,
            icon: markerIcon,
            infoWindow: InfoWindow(
              title: marker.name,
            ),
          );
        }),
      ),
    ),
  );
}
}
