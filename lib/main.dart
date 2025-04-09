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
      // home: MapScreen(),
      // home: HomePage(),
      home:FirstScreen(),
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
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapScreen()),
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
class FirstScreen extends StatelessWidget {
  // Method to show input dialog and handle navigation
  Future<void> _showInputDialogAndNavigate(BuildContext context) async {
    TextEditingController _controller = TextEditingController();

    String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Your Name'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Type your name'),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog without value
              },
            ),
            TextButton(
              child: Text('Go'),
              onPressed: () {
                Navigator.of(context).pop(_controller.text); // Return entered text
              },
            ),
          ],
        );
      },
    );

    // If user entered something and pressed Go, navigate to SecondScreen
    if (result != null && result.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          // builder: (context) => MapScreen(data: result),
          builder: (context) => MapScreen(),
        ),
      );
    }
  }

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
                'Tell us your destinations and availability',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _showInputDialogAndNavigate(context),
              child: Text('trial'),
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
