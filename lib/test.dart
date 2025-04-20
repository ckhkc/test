import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Class to hold coordinates
class GeoPoint {
  final double latitude;
  final double longitude;

  GeoPoint({required this.latitude, required this.longitude});

  @override
  String toString() => 'GeoPoint(latitude: $latitude, longitude: $longitude)';
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Coordinates Finder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LocationScreen(),
    );
  }
}

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  GeoPoint? _coordinates;

  Future<void> _openLocationDialog(BuildContext context) async {
    final result = await showDialog<GeoPoint>(
      context: context,
      builder: (context) => const LocationDialog(),
    );

    if (result != null) {
      setState(() {
        _coordinates = result;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Coordinates stored: $_coordinates')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Coordinates Finder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _openLocationDialog(context),
              child: const Text('Find Coordinates'),
            ),
            const SizedBox(height: 20),
            Text(
              _coordinates == null
                  ? 'No coordinates stored'
                  : 'Stored: $_coordinates',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class LocationDialog extends StatefulWidget {
  const LocationDialog({super.key});

  @override
  _LocationDialogState createState() => _LocationDialogState();
}

class _LocationDialogState extends State<LocationDialog> {
  final TextEditingController _locationController = TextEditingController();

  // Function to query coordinates from Nominatim API
  Future<void> _searchLocation(String location) async {
    if (location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a location')),
      );
      return;
    }

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$location&format=json&limit=1',
    );

    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'FlutterLocationApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          // Return coordinates and close dialog
          Navigator.of(context).pop(GeoPoint(latitude: lat, longitude: lon));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location not found')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error fetching location')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Find Location Coordinates'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: 'Enter location (e.g., Paris)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _searchLocation(_locationController.text),
              child: const Text('Search'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}