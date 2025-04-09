import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to schedule recommender!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Do you want to kill some time today?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Add your button action here
                showDialog(
                  context: context,
                  builder: (context) => const FirstPageDialog(),
               );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text('Trial'),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Add your FAB action here
      //   },
      //   child: Icon(Icons.add),
      // ),
    );
  }
}

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
              'How many text fields do you want on the next page?',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Number of Text Fields',
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

// Second Page: Dynamically generate the number of text fields
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
        title: const Text('Prompt Page'),
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
                'Please fill in the fields below:',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              // Dynamically generate text fields
              ...List.generate(widget.numberOfFields, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: _controllers[index],
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Field ${index + 1}',
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
                      const SnackBar(content: Text('Please fill in all fields')),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MapScreen()),
                  ); 
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OpenStreetMap in Flutter')),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(22.2700000, 114.1750000), // Example: London coordinates
          zoom: 14.0, // Initial zoom level
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app', // Required for OSM usage policy
          ),
        ],
      ),
    );
    
  }
}
