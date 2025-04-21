import 'package:flutter/material.dart';
import 'package:test/big_model.dart';
import 'package:test/geo_point.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:async';
import 'package:test/pages/restaurants_list_page.dart';

import 'package:test/pages/route_suggestion_dialog.dart';

class MapPage extends StatefulWidget {
  MapPage({super.key});
  // final BigModel model = BigModel();

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final GeoPoint point = GeoPoint(latitude: 0, longitude: 0);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<BigModel>(context);
    return model.restaurantPageVisible
        ? RestaurantListPage()
        : Scaffold(
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
                    builder: (context) => PinLocDialog(_mapController),
                  );
                },
                tooltip: 'Search',
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  print('Settings button pressed');
                },
                tooltip: 'Settings',
              ),
              TextButton(
                onPressed: () {
                  model.clearPoint();
                },
                child: Text(
                  'Clear Route',
                  style: TextStyle(color: Colors.white),
                ),
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
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  // Only rebuild MarkerLayer and PolylineLayer when model changes
                  Consumer<BigModel>(
                    builder: (context, model, child) {
                      return Stack(
                        children: [
                          MarkerLayer(
                            markers: [
                              if (model.startLatLng != null)
                                Marker(
                                  point: model.startLatLng!,
                                  width: 30,
                                  height: 30,
                                  child: Image.asset(
                                    "assets/orange_map_pin.png",
                                  ),
                                ),
                              if (model.endLatLng != null)
                                Marker(
                                  point: model.endLatLng!,
                                  width: 30,
                                  height: 30,
                                  child: Image.asset(
                                    "assets/flat_design_map_pin.png",
                                  ),
                                ),
                            ],
                          ),
                          MarkerLayer(
                            markers:
                                model.pointsList.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final point = entry.value;
                                  return Marker(
                                    point: point,
                                    width: 30,
                                    height: 30,
                                    alignment: Alignment.topCenter,
                                    child: Center(
                                      child: Builder(
                                        builder: (context) {
                                          return Image.asset(
                                            "assets/black_map_pin.png",
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                          PolylineLayer(
                            polylines:
                                model.routes
                                    .map(
                                      (route) => Polyline(
                                        points: route,
                                        strokeWidth: 4.0,
                                        color: Colors.blue,
                                      ),
                                    )
                                    .toList(),
                          ),
                        ],
                      );
                    },
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 16,
                    child: Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: ElevatedButton(
                          onPressed: () {
                            model.hideRouteDialog();
                            model.clearPoint();
                            showDialog(
                              context: context,
                              builder: (context) => PromptDialog(),
                            );
                          },
                          child: Text('Get Started'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              RouteSuggestionDialog(
                isVisible: model.isDialogVisible,
                onClose: () {
                  setState(() {
                    model.hideRouteDialog();
                  });
                },
              ),
            ],
          ),
        );
  }
}

class PinLocDialog extends StatefulWidget {
  final MapController mapController;

  const PinLocDialog(MapController this.mapController, {super.key});

  @override
  _PinLocDialogState createState() => _PinLocDialogState();
}

class _PinLocDialogState extends State<PinLocDialog> {
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
          model.pinPoint(lat, lon);
          widget.mapController.move(LatLng(lat, lon), 18);
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
class PromptDialog extends StatefulWidget {
  const PromptDialog({super.key});

  @override
  State<PromptDialog> createState() => _PromptDialogState();
}

class _PromptDialogState extends State<PromptDialog> {
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _stepsController = TextEditingController();
  final TextEditingController _thetaController = TextEditingController();

  var isProblemInput = false;
  var isProblemPrompt = '';

  @override
  void dispose() {
    _departureController.dispose();
    _destinationController.dispose();
    _stepsController.dispose();
    _thetaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late BigModel model = Provider.of<BigModel>(context, listen: false);
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
              controller: _departureController,
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
              controller: _destinationController,
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
              controller: _thetaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: 'Time budget (mins)',
                prefixIcon: Icon(Icons.timer, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            // Number of steps
            const Text(
              'How many activities you would like to have?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _stepsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: 'Number of activities',
                prefixIcon: Icon(Icons.place, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 20),
            if (isProblemInput)
              Center(
                child: Text(
                  isProblemPrompt,
                  style: TextStyle(color: Colors.red),
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
          onPressed: () async {
            // Input validation (your existing code)
            if (_departureController.text.isEmpty ||
                _destinationController.text.isEmpty ||
                _thetaController.text.isEmpty ||
                _stepsController.text.isEmpty) {
              setState(() {
                isProblemInput = true;
                isProblemPrompt = 'There is some missing fields.';
              });
              return;
            }

            double? theta = double.tryParse(_thetaController.text);
            if (theta == null || theta <= 0) {
              setState(() {
                isProblemInput = true;
                isProblemPrompt = 'Please enter a positive number for time.';
              });
              return;
            }
            theta *= 60;

            int? steps = int.tryParse(_stepsController.text);
            if (steps == null || steps < 0) {
              setState(() {
                isProblemInput = true;
                isProblemPrompt =
                    'Please enter a non-negative number for steps.';
              });
              return;
            }

            // Clear any previous errors
            setState(() {
              isProblemInput = false;
              isProblemPrompt = '';
            });

            // Create a Completer to track when loading dialog is shown
            final loadingCompleter = Completer<void>();
            late BuildContext loadingContext;

            // Show loading indicator
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                loadingContext = context;
                loadingCompleter.complete();
                return AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Finding reachable locations...'),
                    ],
                  ),
                );
              },
            );

            // Wait for dialog to be fully shown
            await loadingCompleter.future;

            try {
              // Prepare request data
              final requestData = {
                'current_location': _departureController.text,
                'destination': _destinationController.text,
                'k': steps + 1,
                'theta': theta,
              };

              // Create the HTTP request future
              final requestFuture = http.post(
                Uri.parse(
                  'http://localhost:5000/starts_travel',
                ), // Use 10.0.2.2 for Android emulator
                headers: {'Content-Type': 'application/json'},
                body: json.encode(requestData),
              );

              // Create timeout future
              final timeoutFuture = Future.delayed(Duration(seconds: 3)).then((
                _,
              ) {
                throw TimeoutException('Request timed out after 3 seconds');
              });

              // Race the request against timeout
              final response = await Future.any([requestFuture, timeoutFuture]);

              // Close loading dialog
              if (Navigator.of(loadingContext).canPop()) {
                Navigator.of(loadingContext).pop();
              }

              // Process successful response
              if (response.statusCode == 200) {
                final dynamic decodedJson = json.decode(response.body);
                final List<dynamic> reachableSpList =
                    decodedJson['reachable_sp'] as List? ?? [];
                Navigator.of(context).pop();

                // Convert each item to a strongly-typed Map<String, dynamic>
                final List<Map<String, dynamic>> reachablePoints =
                    reachableSpList
                        .map(
                          (item) => {
                            'location':
                                item['location'] as String, // Force String
                            'time_required':
                                (item['time_required'] as num)
                                    .toInt(), // Force int
                          },
                        )
                        .toList();

                final startCor = decodedJson['start_lat_lon'].split(',');
                model.startLatLng = LatLng(
                  double.parse(startCor[0]),
                  double.parse(startCor[1]),
                );

                final endCor = decodedJson['end_lat_lon'].split(',');
                model.endLatLng = LatLng(
                  double.parse(endCor[0]),
                  double.parse(endCor[1]),
                );

                model.start = _departureController.text;
                model.end = _destinationController.text;
                model.setCurK(1);
                model.setTotalK(steps);
                model.setTimeCredit(theta);
                model.addStaticPoints(reachablePoints);

                model.showRouteDialog();
              } else {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text('Error'),
                        content: Text(
                          'Server returned error: ${response.statusCode} ${response.body}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('OK'),
                          ),
                        ],
                      ),
                );
              }
            } on TimeoutException {
              if (Navigator.of(loadingContext).canPop()) {
                Navigator.of(loadingContext).pop();
              }
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text('Timeout'),
                      content: Text('Request timed out after 3 seconds'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('OK'),
                        ),
                      ],
                    ),
              );
            } catch (e) {
              if (Navigator.of(loadingContext).canPop()) {
                Navigator.of(loadingContext).pop();
              }
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text('Error'),
                      content: Text('An error occurred: ${e.toString()}'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('OK'),
                        ),
                      ],
                    ),
              );
            }
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
