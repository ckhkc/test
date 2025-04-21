import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:test/geo_point.dart';

class BigModel with ChangeNotifier {
  GeoPoint _point = GeoPoint(latitude: 40.7128, longitude: -74.0060);

  GeoPoint get point => _point;

  bool isDialogVisible;

  BigModel({this.isDialogVisible = false});

  List<Map<String, String>> _favorites = [];

  List<Map<String, String>> get favorites => _favorites;

  List<List<Map<String, dynamic>>> staticPointsList = [];

  List<LatLng> pointsList = [];
  List<List<LatLng>> routes = [];

  List<Map<String, dynamic>> restaurants = [];
  bool restaurantPageVisible = false;
  Map<String, dynamic>? selectedRestaurant;

  void updatePoint(double latitude, double longitude) {
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
    if (staticPointsList.isEmpty) {
      hideRouteDialog();
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
    selectedRestaurant = restaurant;
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
    if (pointsList.isEmpty) {
      pointsList.add(newPoint);
    } else {
      final start = pointsList.last;
      final end = newPoint;

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

        final routePoints =
            coordinates
                .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
                .toList();
        routes.add(routePoints);
      }

      pointsList.add(newPoint);
    }
    print(pointsList);
    print(routes);
    notifyListeners();
  }

  void clearPoint() {
    pointsList.clear();
    routes.clear();
    notifyListeners();
  }
}
