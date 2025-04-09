import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart'; // Ensure this import is correct
import 'package:geocoding/geocoding.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Two-Page Prompt with OSM Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

// Home Page: Contains a button to trigger the pop-up dialog
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Show the pop-up dialog when the button is pressed
            showDialog(
              context: context,
              builder: (context) => const FirstPageDialog(),
            );
          },
          child: const Text('Start Prompt'),
        ),
      ),
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

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Prompt'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please enter your name:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'How many destinations do you want to enter?',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Number of Destinations',
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
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.isEmpty ||
                _numberController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Please enter both your name and a number')),
              );
              return;
            }

            int? numberOfFields = int.tryParse(_numberController.text);
            if (numberOfFields == null || numberOfFields <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Please enter a valid positive number')),
              );
              return;
            }

            // Close the dialog
            Navigator.of(context).pop();

            // Navigate to the second page and pass the name and number
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SecondPage(
                  name: _nameController.text,
                  numberOfFields: numberOfFields,
                ),
              ),
            );
          },
          child: const Text('Next'),
        ),
      ],
    );
  }
}

// Second Page: Dynamically generate text fields for destinations
class SecondPage extends StatefulWidget {
  final String name;
  final int numberOfFields;

  const SecondPage({super.key, required this.name, required this.numberOfFields});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    // Initialize a list of controllers based on the number of fields
    _controllers = List.generate(
      widget.numberOfFields,
      (index) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    // Dispose of all controllers
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Destinations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hello, ${widget.name}!',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              const Text(
                'Please enter your destinations:',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              // Dynamically generate text fields for destinations
              ...List.generate(widget.numberOfFields, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: _controllers[index],
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Destination ${index + 1}',
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Check if any field is empty
                  bool allFieldsFilled = _controllers.every((controller) => controller.text.isNotEmpty);
                  if (!allFieldsFilled) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill in all destinations')),
                    );
                    return;
                  }

                  // Collect all the destination values
                  List<String> destinations = _controllers.map((controller) => controller.text).toList();

                  // Navigate to the map page with the destinations
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapPage(
                        name: widget.name,
                        destinations: destinations,
                      ),
                    ),
                  );
                },
                child: const Text('Show on Map'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Map Page: Display OSM map with pins based on destinations
class MapPage extends StatefulWidget {
  final String name;
  final List<String> destinations;

  const MapPage({super.key, required this.name, required this.destinations});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapController _mapController;
  List<GeoPoint> _markerPoints = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize the MapController with a default position (London)
    _mapController = MapController(
      initPosition: const GeoPoint(latitude: 51.5074, longitude: -0.1278), // Default to London
    );
    _geocodeDestinations();
  }

  Future<void> _geocodeDestinations() async {
    for (String destination in widget.destinations) {
      try {
        // Convert the destination string to latitude and longitude
        List<Location> locations = await locationFromAddress(destination);
        if (locations.isNotEmpty) {
          Location location = locations.first;
          GeoPoint point = GeoPoint(
            latitude: location.latitude,
            longitude: location.longitude,
          );
          _markerPoints.add(point);

          // Add a marker to the map
          await _mapController.addMarker(
            point,
            markerIcon: const MarkerIcon(
              icon: Icon(
                Icons.location_pin,
                color: Colors.blue,
                size: 48,
              ),
            ),
          );
        } else {
          // If no locations are found, show a message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No location found for $destination')),
          );
        }
      } catch (e) {
        // Handle geocoding errors
        print('Error geocoding $destination: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not find location for $destination')),
        );
      }
    }

    // If we have at least one marker, center the map on the first one
    if (_markerPoints.isNotEmpty) {
      await _mapController.goToLocation(_markerPoints.first);
      await _mapController.setZoom(zoomLevel: 10);
    } else {
      // If no markers were added, show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No valid destinations to display on the map')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.name}\'s Destinations Map'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : OSMFlutter(
              controller: _mapController,
              osmOption: const OSMOption(
                zoomOption: ZoomOption(
                  initZoom: 10,
                  minZoomLevel: 3,
                  maxZoomLevel: 19,
                  stepZoom: 1.0,
                ),
                markerOption: MarkerOption(
                  defaultMarker: MarkerIcon(
                    icon: Icon(
                      Icons.location_pin,
                      color: Colors.blue,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}