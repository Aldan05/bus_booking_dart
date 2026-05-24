import '../models/bus_model.dart';

class FirestoreService {
  Future<List<BusModel>> fetchBuses() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      BusModel(
          id: "B1",
          busNumber: "TN-01-2026",
          routeName: "Chennai - Madurai",
          type: "Sleeper AC",
          lat: 13.0827,
          lng: 80.2707,
          fare: 850.0,
          totalSeats: 32,
          seatMap: List.generate(32, (index) => index < 10), // First 10 seats booked
          travelTime: "7h 15m",
          distanceKm: 460.0
      ),
      BusModel(
          id: "B2",
          busNumber: "TN-33-1122",
          routeName: "Erode - Kovai",
          type: "Classic",
          lat: 11.3410,
          lng: 77.7172,
          fare: 150.0,
          totalSeats: 40,
          seatMap: List.generate(40, (index) => index < 20), // First 20 seats booked
          travelTime: "2h 30m",
          distanceKm: 120.0
      ),
    ];
  }
}
