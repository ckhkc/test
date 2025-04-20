import 'package:flutter/material.dart';
import 'package:test/big_model.dart';
import 'package:test/geo_point.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPage();
}

class _MapPage extends State<MapPage> {
  final MapController _mapController = MapController();
  final GeoPoint point = GeoPoint(latitude: 0, longitude: 0);
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<BigModel>(context);
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        toolbarHeight: 40,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const LocationDialog(),
              );
            },
            tooltip: 'Search',
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              print('Settings button pressed');
              print('${model.point}');
            },
            tooltip: 'Settings',
          ),
          TextButton(
            onPressed: () {
              print('Text button pressed');
            },
            child: Text('Action', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(22.2700000, 114.1750000),
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                // urlTemplate: 'https://tile.thunderforest.com/transport/{z}/{x}/{y}.png', // for transportation tile
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // for normal tile
                // urlTemplate: 'https://tile.thunderforest.com/cycle/{z}/{x}/{y}.png', // for cycle tile
                // urlTemplate: 'https://tileserver.memomaps.de/tilegen/{z}/{x}/{y}.png', // for public transportation tile
                userAgentPackageName:
                    'com.example.app', // Required for OSM usage policy
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    // point: LatLng(point.latitude, point.longitude),
                    point: LatLng(model.point.latitude, model.point.longitude),
                    width: 60,
                    height: 60,
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.location_pin,
                      size: 30,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(
              child: SizedBox(
                width:
                    MediaQuery.of(context).size.width *
                    0.8, // 80% of screen width
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Get Started pressed!')),
                    );
                    showDialog(
                      context: context,
                      builder: (context) => const FirstPageDialog(),
                    );
                  },
                  child: Text('Get Started'),
                ),
              ),
            ),
          ),
        ],
      ),
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
      appBar: AppBar(title: const Text('Location Coordinates Finder')),
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
    final model = Provider.of<BigModel>(context, listen: false);
    if (location.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a location')));
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
          model.updatePoint(lat, lon);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Location not found')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error fetching location')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
              onPressed: () => {_searchLocation(_locationController.text)},
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

// First Page Dialog: Pop-up dialog to prompt for the user's name and a number
class FirstPageDialog extends StatefulWidget {
  const FirstPageDialog({super.key});

  @override
  State<FirstPageDialog> createState() => _FirstPageDialogState();
}

class _FirstPageDialogState extends State<FirstPageDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          20,
        ), // Rounded corners for a modern look
      ),
      backgroundColor: Colors.white, // Clean background
      title: Row(
        children: [
          Icon(Icons.map_rounded, color: Colors.blueAccent, size: 30),
          const SizedBox(width: 10),
          const Text(
            'Plan Your Adventure',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
              fontSize: 22,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, Traveler! Let’s start planning your itinerary.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            // Name Input
            const Text(
              'Where are you now?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: 'location',
                prefixIcon: Icon(Icons.location_city, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 20),
            // Number of Destinations Input
            const Text(
              'What is your destination?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: 'Destination',
                prefixIcon: Icon(Icons.place, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 20),
            // Time Input
            const Text(
              'How much time do you have for your trip?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _timeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: 'Time (in minutes)',
                prefixIcon: Icon(Icons.timer, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isEmpty ||
                _numberController.text.isEmpty ||
                _timeController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill in all fields to continue.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
              return;
            }

            int? numberOfFields = int.tryParse(_numberController.text);
            if (numberOfFields == null || numberOfFields <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Please enter a valid positive number of destinations.',
                  ),
                  backgroundColor: Colors.redAccent,
                ),
              );
              return;
            }

            // Close the dialog
            Navigator.of(context).pop();

            // // Navigate to the second page and pass the name, number, and time
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => SecondPage(
            //       name: _nameController.text,
            //       numberOfFields: numberOfFields,
            //       time: int.tryParse(_timeController.text) ?? 0,
            //     ),
            //   ),
            // );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text(
            'Start Planning',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
