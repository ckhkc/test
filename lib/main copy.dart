import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


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
            const SizedBox(height: 20),
            const Text(
              'How much time do you have?',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _timeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'In mintues',
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
                      // builder: (context) => OldMainExample()
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

class _MapPageState extends State<MapPage>{
  final MapController _mapController = MapController();

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text("OpenStreetMap"),
        backgroundColor: Colors.blue,
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
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // for normal tile
                // urlTemplate: 'https://tile.thunderforest.com/cycle/{z}/{x}/{y}.png', // for cycle tile
                // urlTemplate: 'https://tileserver.memomaps.de/tilegen/{z}/{x}/{y}.png', // for public transportation tile
                userAgentPackageName: 'com.example.app', // Required for OSM usage policy
              ),
            ],
          ),
        ],
      ),

    );
  }
}