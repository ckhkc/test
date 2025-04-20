class GeoPoint {
  double latitude = 0;
  double longitude = 0;

  GeoPoint({required this.latitude, required this.longitude});

  @override
  String toString() => 'GeoPoint(latitude: $latitude, longitude: $longitude)';
}
