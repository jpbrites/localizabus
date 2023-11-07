import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarker {
  final String name;
  final LatLng position;

  MapMarker({
    required this.name,
    required this.position,
  });
}