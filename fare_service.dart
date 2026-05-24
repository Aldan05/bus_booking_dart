import 'dart:math';

class FareService {
  static const double ratePerKm = 5.5; // ₹5.5 per kilometer

  double calculateDistanceFare(double startLat, double startLng, double endLat, double endLng) {
    var p = 0.017453292519943295;
    var a = 0.5 - cos((endLat - startLat) * p)/2 +
        cos(startLat * p) * cos(endLat * p) * (1 - cos((endLng - startLng) * p))/2;
    double distance = 12742 * asin(sqrt(a)); // Result in km

    return (distance * ratePerKm).roundToDouble();
  }
}