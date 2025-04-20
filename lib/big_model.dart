import 'package:flutter/material.dart';
import 'package:test/geo_point.dart';

class BigModel with ChangeNotifier {
  GeoPoint _point = GeoPoint(latitude: 40.7128, longitude: -74.0060);

  GeoPoint get point => _point;

  void updatePoint(double latitude, double longitude) {
    _point = GeoPoint(latitude: latitude, longitude: longitude);
    notifyListeners();
  }
}
