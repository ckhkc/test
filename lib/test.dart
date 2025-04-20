import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Walking Path Map',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MapPage(),
    );
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<LatLng> routePoints = [];
  final MapController mapController = MapController();

  // Define start and end coordinates
  final LatLng startCoord = const LatLng(51.5074, -0.1278); // London
  final LatLng endCoord = const LatLng(51.5174, -0.1378); // Slightly north-west

  @override
  void initState() {
    super.initState();
    fetchRoute();
  }

  Future<void> fetchRoute() async {
    const apiKey =
        '5b3ce3597851110001cf6248724e0cc50fa3463a9c41b1707976aae3'; // Replace with your API key
    final url =
        'https://api.openrouteservice.org/v2/directions/foot-walking/geojson';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': apiKey, 'Content-Type': 'application/json'},
      body: json.encode({
        'coordinates': [
          [startCoord.longitude, startCoord.latitude],
          [endCoord.longitude, endCoord.latitude],
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coordinates = data['features'][0]['geometry']['coordinates'];

      setState(() {
        routePoints =
            coordinates
                .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
                .toList();
      });

      // Center map on the route
      if (routePoints.isNotEmpty) {
        mapController.move(
          LatLng(
            (startCoord.latitude + endCoord.latitude) / 2,
            (startCoord.longitude + endCoord.longitude) / 2,
          ),
          14.0,
        );
      }
    } else {
      throw Exception('Failed to load route');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Walking Path')),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(initialCenter: startCoord, initialZoom: 13.0),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: startCoord,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              Marker(
                point: endCoord,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
            ],
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
