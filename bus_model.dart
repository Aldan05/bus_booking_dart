class BusModel {
  final String id;
  final String busNumber;
  final String routeName;
  final String type; // AC, Non-AC, Deluxe
  final double lat;
  final double lng;
  final double fare;
  final int totalSeats;
  final List<bool> seatMap; // true if booked, false if available
  final String travelTime; // Estimated travel duration (e.g., "6h 30m")
  final double distanceKm; // Distance in Kilometers

  BusModel({
    required this.id, 
    required this.busNumber, 
    required this.routeName,
    required this.type, 
    required this.lat, 
    required this.lng,
    required this.fare, 
    required this.totalSeats,
    required this.seatMap,
    required this.travelTime,
    required this.distanceKm,
  });

  int get availableSeatsCount => seatMap.where((booked) => !booked).length;
}
