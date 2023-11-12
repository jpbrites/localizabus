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
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  Timer? timer;
  Set<MapMarker> busMarkers = <MapMarker>{}, stopMarkers = <MapMarker>{};
  late GoogleMapController mapController;
  WebSocketChannel? channel;
  bool showStops = false;
  int route = 0;

  @override
  void initState() {
    super.initState();
    addCustomIcon();

    fetchDataFromHTTP(false);
    fetchDataFromHTTP(true);
    timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      //job
      fetchDataFromHTTP(true);
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

  void fetchDataFromHTTP(bool isCoordinate, { int attemptsLeft = 3  }) async {
    String url = 'http://67.205.172.182:3333/list${isCoordinate ? 'Coordinates' : 'Stops'}';
    var newMarkers = <MapMarker>{};
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
      if(!isCoordinate && route != 0){
        name += ' ${coordinate["date"].toString()}';
      }

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
      fetchDataFromHTTP(isCoordinate, attemptsLeft: attemptsLeft - 1);
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
    if(showStops){
      for (var element in stopMarkers) {
        markers.add(
            Marker(
              markerId: MarkerId(element.name),
              position: element.position,
              infoWindow: InfoWindow(
                  title: element.name
              ),
            )
        );
      }
    }
    for (var element in busMarkers) {
      markers.add(
        Marker(
          markerId: MarkerId(element.name),
          position: element.position,
          icon: markerIcon,
          infoWindow: InfoWindow(
            title: element.name,
            onTap: (){
              showStops ^= true;
              if(showStops){
                fetchDataFromHTTP(false);
              }else{
                setState(() {});
              }
            }
          ),
          onTap: (){
            print("Clicked");
            route ^= 1;
            fetchDataFromHTTP(false);
          }
        )
      );
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
