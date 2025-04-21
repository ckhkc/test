import 'package:flutter/material.dart';
import 'package:test/geo_point.dart';

class BigModel with ChangeNotifier {
  GeoPoint _point = GeoPoint(latitude: 40.7128, longitude: -74.0060);

  GeoPoint get point => _point;

  bool isDialogVisible;

  BigModel({this.isDialogVisible = false});

  List<Map<String, String>> _favorites = [];

  List<Map<String, String>> get favorites => _favorites;

  // List<List<Map<String, dynamic>>> staticPointsList = [];

  List<List<Map<String, dynamic>>> staticPointsList = [
    [
      {'latitude': 22.277559019404148, 'longitude': 114.17313411995005},
      {'latitude': 22.28024358896722, 'longitude': 114.18497713092883},
      {'latitude': 22.28251328662275, 'longitude': 114.19185048857794},
      {'latitude': 22.28790, 'longitude': 114.19361},
    ],
  ];

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
    restaurantPageVisible = true; // Keep restaurant page visible
    notifyListeners();

    // Optional: Show feedback
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Selected: ${restaurant['Name']}')));
  }
}
