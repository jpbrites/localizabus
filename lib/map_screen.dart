import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng initialLocation = const LatLng(-9.401404, -40.503057);
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    addCustomIcon();
    super.initState();
  }

  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), "assets/onibus3.png")
        .then(
      (icon) {
        setState(() {
          markerIcon = icon;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialLocation,
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: const MarkerId("marker1"),
            position: const LatLng(-9.412412, -40.505632),
            draggable: true,
            onDragEnd: (value) {
              // value is the new position
            },
            icon: markerIcon,
          ),
          Marker(
            markerId: const MarkerId("marker2"),
            position: const LatLng(-9.400176, -40.496104

),
          ),
        },
      ),
    );
  }
}