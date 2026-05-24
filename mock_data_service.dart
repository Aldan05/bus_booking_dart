import 'dart:math';
import '../models/bus_model.dart';
import '../utils/constants.dart';

class MockDataService {
  static List<BusModel> getAvailableBuses({String? source, String? destination}) {
    List<BusModel> buses = [
      // Chennai Hub
      _bus('1', 'TN-01-AX-1001', 'Chennai - Madurai', 'AC Sleeper', 13.0827, 80.2707, 850.0, 32, "7h 15m", 460.0),
      _bus('2', 'TN-01-BY-2002', 'Chennai - Coimbatore', 'Ultra Deluxe', 13.0827, 80.2707, 750.0, 40, "8h 30m", 510.0),
      _bus('3', 'TN-01-CZ-3003', 'Chennai - Tiruchirappalli', 'Non-AC Deluxe', 13.0827, 80.2707, 450.0, 44, "5h 45m", 330.0),
      _bus('4', 'TN-01-DM-4004', 'Chennai - Salem', 'AC Semi-Sleeper', 13.0827, 80.2707, 550.0, 36, "6h 00m", 345.0),
      _bus('5', 'TN-01-EK-5005', 'Chennai - Tirunelveli', 'AC Sleeper', 13.0827, 80.2707, 950.0, 32, "9h 30m", 620.0),
      
      // Madurai Hub
      _bus('9', 'TN-58-MA-1111', 'Madurai - Kanyakumari', 'AC Sleeper', 9.9252, 78.1198, 450.0, 32, "4h 30m", 245.0),
      _bus('10', 'TN-58-MB-2222', 'Madurai - Chennai', 'Ultra Deluxe', 9.9252, 78.1198, 800.0, 40, "7h 45m", 460.0),
      
      // Coimbatore Hub
      _bus('15', 'TN-37-CA-9999', 'Coimbatore - Chennai', 'AC Sleeper', 11.0168, 76.9558, 900.0, 32, "8h 45m", 510.0),
      
      // Salem Hub
      _bus('20', 'TN-27-SA-1212', 'Salem - Chennai', 'Ultra Deluxe', 11.6643, 78.1460, 500.0, 40, "6h 15m", 345.0),
    ];

    // DYNAMIC INTEGRATION: For search result consistency across TN
    if (source != null && destination != null) {
      bool found = buses.any((b) => 
        b.routeName.toLowerCase().contains(source.toLowerCase()) && 
        b.routeName.toLowerCase().contains(destination.toLowerCase())
      );

      if (!found) {
        // Calculate mock distance and time based on district indices for realism
        int distDiff = (AppConstants.tnDistricts.indexOf(source) - AppConstants.tnDistricts.indexOf(destination)).abs();
        double mockKm = 50.0 + (distDiff * 12.0);
        int hours = (mockKm / 60).floor();
        int minutes = ((mockKm % 60)).floor();
        
        buses.add(_bus(
          'DYN-${source.substring(0,3)}-${destination.substring(0,3)}',
          'TN-${AppConstants.tnDistricts.indexOf(source) + 10}-TN-2024',
          '$source - $destination',
          'TN State Express',
          11.0, 78.0, 
          (mockKm * 1.5), 40,
          "${hours}h ${minutes}m",
          mockKm
        ));
      }
    }

    return buses;
  }

  static BusModel _bus(String id, String num, String route, String type, double lat, double lng, double fare, int totalSeats, String time, double km) {
    // Randomly pre-book some seats for realism
    final random = Random();
    final seatMap = List.generate(totalSeats, (index) => random.nextDouble() < 0.3);

    return BusModel(
      id: id,
      busNumber: num,
      routeName: route,
      type: type,
      lat: lat,
      lng: lng,
      fare: fare,
      totalSeats: totalSeats,
      seatMap: seatMap,
      travelTime: time,
      distanceKm: km,
    );
  }
}
