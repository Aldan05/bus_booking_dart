class TicketModel {
  final String ticketId;
  final String busNumber;
  final String source;
  final String destination;
  final String travelDate;
  final double totalFare;
  final List<int> seatNumbers;
  bool isCancelled; // Added to track cancellation status

  TicketModel({
    required this.ticketId,
    required this.busNumber,
    required this.source,
    required this.destination,
    required this.travelDate,
    required this.totalFare,
    required this.seatNumbers,
    this.isCancelled = false, // Default is not cancelled
  });

  int get seatCount => seatNumbers.length;

  String get qrData => "TKT:$ticketId|BUS:$busNumber|DATE:$travelDate|SEATS:${seatNumbers.join(',')}";
}
