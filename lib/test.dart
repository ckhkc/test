import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MapScreen());
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapController = MapController(
    initPosition: GeoPoint(latitude: 51.5074, longitude: -0.1278), // London
  );

  @override
  void initState() {
    super.initState();
    _addMarker();
  }

  // Add a marker at the specified location
  void _addMarker() {
    _mapController.addMarker(
      GeoPoint(latitude: 51.5074, longitude: -0.1278),
      markerIcon: const MarkerIcon(
        icon: Icon(Icons.location_pin, color: Colors.red, size: 40),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OSMFlutter(
        controller: _mapController,
        osmOption: const OSMOption(zoomOption: ZoomOption(initZoom: 12)),
      ),
    );
  }
}
