import 'package:flutter/material.dart';
import 'package:test/geo_point.dart';

class BigModel with ChangeNotifier {
  GeoPoint _point = GeoPoint(latitude: 40.7128, longitude: -74.0060);

  GeoPoint get point => _point;

  bool isDialogVisible;

  BigModel({this.isDialogVisible = false});

  List<Map<String, String>> _favorites = [];

  List<Map<String, String>> get favorites => _favorites;

  List<List<Map<String, dynamic>>> staticPointsList = [];

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
}
