import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:test/geo_point.dart';

import 'dart:math';

/// Log-scales an input value to a specified output range, clamping inputs >10000.
///
/// - `input`: Raw input value (0 to infinity, but clamped at 10000).
/// - `minOutput`: Minimum value of the output range (e.g., 1000).
/// - `maxOutput`: Maximum value of the output range (e.g., 3000).
double logScale(
  double input, {
  double minOutput = 1000,
  double maxOutput = 5000,
}) {
  const maxInput = 10000; // Upper bound for input (clamp values beyond this)

  // Clamp input to [0, maxInput]
  final clampedInput = input.clamp(0, maxInput).toDouble();

  // Avoid log(0) by adding 1 (log1p is log(x+1))
  final logInput = log(clampedInput + 1);
  final logMax = log(maxInput + 1);

  // Normalize to [0, 1] and scale to [minOutput, maxOutput]
  final normalized = logInput / logMax;
  return minOutput + normalized * (maxOutput - minOutput);
}

class BigModel with ChangeNotifier {
  GeoPoint _point = GeoPoint(latitude: 40.7128, longitude: -74.0060);

  GeoPoint get point => _point;

  bool isDialogVisible;

  BigModel({this.isDialogVisible = false});

  List<Map<String, String>> _favorites = [];

  List<Map<String, String>> get favorites => _favorites;

  List<List<Map<String, dynamic>>> staticPointsList = [];
  List<String> selectedSP = [];

  List<LatLng> pointsList = [];
  List<List<LatLng>> routes = [];
  List<double> routes_duration = [];

  List<Map<String, dynamic>> restaurants = [];
  bool restaurantPageVisible = false;
  List<Map<String, dynamic>> selectedRestaurant = [];

  double timeCredit = 0;
  int totalK = 0;
  int curK = 0;
  String start = '';
  String end = '';

  LatLng? startLatLng;
  LatLng? endLatLng;

  bool showAdditionalRoutes = false;

  void setTimeCredit(double newTimeCredit) {
    timeCredit = newTimeCredit;
    notifyListeners();
  }

  void setTotalK(int newTotalK) {
    totalK = newTotalK;
    notifyListeners();
  }

  void setCurK(int newCurK) {
    curK = newCurK;
    notifyListeners();
  }

  void pinPoint(double latitude, double longitude) {
    _point = GeoPoint(latitude: latitude, longitude: longitude);
    notifyListeners();
  }

  void addFavorite(Map<String, String> route) {
    if (!_favorites.any((r) => r['name'] == route['name'])) {
      _favorites.add(Map.from(route));
      notifyListeners();
    }
  }

  void removeFavorite(String routeName) {
    _favorites.removeWhere((r) => r['name'] == routeName);
    notifyListeners();
  }

  bool isFavorite(String routeName) {
    return _favorites.any((r) => r['name'] == routeName);
  }

  void showRouteDialog() {
    isDialogVisible = true;
    notifyListeners();
  }

  void hideRouteDialog() {
    isDialogVisible = false;
    staticPointsList.clear();
    notifyListeners();
  }

  void addStaticPoints(List<Map<String, dynamic>> newStaticPointsList) {
    staticPointsList.add(newStaticPointsList);
    notifyListeners();
  }

  void goBackStaticPoints() {
    staticPointsList.removeLast();
    selectedSP.removeLast();
    setCurK(curK - 1);
    removeLastPoint();

    if (staticPointsList.isEmpty) {
      hideRouteDialog();
      clearPoint();
    }
    notifyListeners();
  }

  void setRestaurants(List<Map<String, dynamic>> newRestaurant) {
    restaurants = newRestaurant;
    notifyListeners();
  }

  void showRestaurants() {
    restaurantPageVisible = true;
    notifyListeners();
  }

  void hideRestaurants() {
    restaurantPageVisible = false;
    notifyListeners();
  }

  void onRestaurantSelected(
    BuildContext context,
    Map<String, dynamic> restaurant,
  ) {
    selectedRestaurant.add(restaurant);
    restaurantPageVisible = false; // Keep restaurant page visible
    notifyListeners();

    final coordinates = restaurant['coordinates']; // "22.300688,114.167687"
    final parts = coordinates.split(
      ',',
    ); // Split into ["22.300688", "114.167687"]
    final point = LatLng(
      double.parse(parts[0]), // latitude (22.300688)
      double.parse(parts[1]), // longitude (114.167687)
    );
    addPoint(point);
    notifyListeners();
  }

  Future<void> addPoint(LatLng newPoint) async {
    setCurK(curK + 1);
    LatLng start, end;
    if (pointsList.isEmpty) {
      start = startLatLng!;
      end = newPoint;
    } else {
      start = pointsList.last;
      end = newPoint;
    }

    const apiKey =
        '5b3ce3597851110001cf6248724e0cc50fa3463a9c41b1707976aae3'; // Replace with your API key
    const url =
        'https://api.openrouteservice.org/v2/directions/foot-walking/geojson';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': apiKey, 'Content-Type': 'application/json'},
      body: json.encode({
        'coordinates': [
          [start.longitude, start.latitude],
          [end.longitude, end.latitude],
        ],
      }),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final coordinates = data['features'][0]['geometry']['coordinates'];

      double durationInSeconds =
          data['features'][0]['properties']['segments'][0]['duration'];

      durationInSeconds = logScale(durationInSeconds);

      if (durationInSeconds >= timeCredit) {
        durationInSeconds = timeCredit * curK / totalK;
      }

      routes_duration.add(durationInSeconds);
      timeCredit -= durationInSeconds;

      final routePoints =
          coordinates
              .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
              .toList();
      routes.add(routePoints);

      if (curK > totalK) {
        notifyListeners();
      } else {
        // add new static points list
        // await sendNewStaticPointsRequest();
        sendNewStaticPointsRequest();
      }
    }

    pointsList.add(newPoint);
    notifyListeners();
  }

  Future<void> sendNewStaticPointsRequest() async {
    try {
      // Prepare request data
      final requestData = {
        'current_location': selectedSP.last,
        'destination': end,
        'k': totalK - curK + 2,
        'theta': timeCredit,
      };

      // Create the HTTP request future
      final requestFuture = http.post(
        Uri.parse(
          'http://localhost:5000/reachable_locations',
        ), // Use 10.0.2.2 for Android emulator
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      // Create timeout future
      final timeoutFuture = Future.delayed(Duration(seconds: 3)).then((_) {
        throw TimeoutException('Request timed out after 3 seconds');
      });

      // Race the request against timeout
      final response = await Future.any([requestFuture, timeoutFuture]);

      // Process successful response
      if (response.statusCode == 200) {
        final dynamic decodedJson = json.decode(response.body);
        final List<dynamic> reachableSpList =
            decodedJson['reachable_sp'] as List? ?? [];

        // Convert each item to a strongly-typed Map<String, dynamic>
        final List<Map<String, dynamic>> reachablePoints =
            reachableSpList
                .map(
                  (item) => {
                    'location': item['location'] as String, // Force String
                    'time_required':
                        (item['time_required'] as num).toInt(), // Force int
                  },
                )
                .toList();
        addStaticPoints(reachablePoints);
      }
    } catch (e) {
      print('An error occured: ${e.toString()}');
    }
  }

  void removeLastPoint() {
    if (pointsList.isEmpty) {
      return;
    } else {
      pointsList.removeLast();
      if (routes.isNotEmpty) {
        routes.removeLast();
      }
      if (routes_duration.isNotEmpty) {
        setTimeCredit(timeCredit + routes_duration.last);
        routes_duration.removeLast();
      }
      if (selectedRestaurant.isNotEmpty) {
        selectedRestaurant.removeLast();
      }
    }
    notifyListeners();
  }

  void clearPoint() {
    startLatLng = null;
    endLatLng = null;
    showAdditionalRoutes = false;

    staticPointsList.clear();
    selectedSP.clear();

    pointsList.clear();
    routes.clear();
    routes_duration.clear();

    selectedRestaurant.clear();
    notifyListeners();
  }

  Future<void> onAccept() async {
    LatLng start, end;
    start = pointsList.last;
    end = endLatLng!;

    const apiKey =
        '5b3ce3597851110001cf6248724e0cc50fa3463a9c41b1707976aae3'; // Replace with your API key
    const url =
        'https://api.openrouteservice.org/v2/directions/foot-walking/geojson';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': apiKey, 'Content-Type': 'application/json'},
      body: json.encode({
        'coordinates': [
          [start.longitude, start.latitude],
          [end.longitude, end.latitude],
        ],
      }),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final coordinates = data['features'][0]['geometry']['coordinates'];

      double durationInSeconds =
          data['features'][0]['properties']['segments'][0]['duration'];

      durationInSeconds = logScale(durationInSeconds);

      if (durationInSeconds >= timeCredit) {
        durationInSeconds = timeCredit * curK / totalK;
      }

      routes_duration.add(durationInSeconds);
      timeCredit -= durationInSeconds;

      final routePoints =
          coordinates
              .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
              .toList();
      routes.add(routePoints);

      notifyListeners();
    }

    showAdditionalRoutes = true;
    hideRouteDialog();
    notifyListeners();
  }
}
