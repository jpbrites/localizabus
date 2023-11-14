import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_marker.dart';
import 'menu.dart';
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

  Timer? timer;
  Set<MapMarker> markers = Set<MapMarker>();
  late GoogleMapController mapController;
 

  @override
  void initState() {
    super.initState();
    addCustomIcon();

    fetchDataFromHTTP();
    timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      //job
      fetchDataFromHTTP();
    });
  }

  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "assets/marker_final.png",
    ).then(
      (icon) {
        setState(() {
          markerIcon = icon;
        });
      },
    );
  }

  void fetchDataFromHTTP({int attemptsLeft = 3}) async {
    var newMarkers = Set<MapMarker>();
    final response =
        await http.get(Uri.parse('http://67.205.172.182:3333/listCoordinates'));

    if(attemptsLeft == 0) {
      print("Failed to fetch 3 times in a row");
      if(markers.isNotEmpty){
        return;
      }
      print("Adding default markers");
      newMarkers.add(
          MapMarker(
            name: "Marker 1",
            position: const LatLng(-9.412412, -40.505632),
          )
      );
      newMarkers.add(
          MapMarker(
            name: "Marker 2",
            position: const LatLng(-9.400176, -40.496104),
          )
      );

      setState(() {
        markers = newMarkers;
      });
      return;
    }

    if (response.statusCode != 200) {
      print("Failed to fetch data: ${response.statusCode}\nBody: ${response.body}");
      sleep(const Duration(seconds: 1));
      fetchDataFromHTTP(attemptsLeft: attemptsLeft - 1);
      return;
    }

    final jsonData = json.decode(response.body);
    if (!jsonData.containsKey("coordinates")) {
      return;
    }

    List<dynamic> coordinates = jsonData["coordinates"];
    for (var coordinate in coordinates) {
      double lat = double.parse(coordinate["lat"]);
      double lng = double.parse(coordinate["long"]);
      String name = coordinate["letter"].toString();
      print("Latitude: $lat, Longitude: $lng, Name: $name ");
      newMarkers.add(
        MapMarker(
          name: name,
          position: LatLng(lat, lng),
        )
      );
    }

    if(newMarkers.isEmpty){
      print("Received empty values");
      sleep(const Duration(seconds: 1));
      fetchDataFromHTTP(attemptsLeft: attemptsLeft - 1);
      return;
    }

    setState(() {
      markers = newMarkers;
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
        markers: Set<Marker>.from(
          markers.map((marker) {
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
