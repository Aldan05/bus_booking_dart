import 'package:flutter/material.dart';
import '../models/bus_model.dart';
import '../models/ticket_model.dart';

class BookingController extends ChangeNotifier {
  List<int> _selectedSeats = [];
  double _totalFare = 0.0;
  
  final List<TicketModel> _bookedTickets = [];

  List<int> get selectedSeats => _selectedSeats;
  double get totalFare => _totalFare;
  List<TicketModel> get bookedTickets => _bookedTickets;

  void toggleSeat(int seatIndex, double baseFare) {
    if (_selectedSeats.contains(seatIndex)) {
      _selectedSeats.remove(seatIndex);
    } else {
      _selectedSeats.add(seatIndex);
    }
    _totalFare = _selectedSeats.length * baseFare;
    notifyListeners();
  }

  void clearSelection() {
    _selectedSeats = [];
    _totalFare = 0.0;
    notifyListeners();
  }

  TicketModel confirmBooking(BusModel bus, String date) {
    final String ticketId = "TKT-${DateTime.now().millisecondsSinceEpoch}";
    
    final newTicket = TicketModel(
      ticketId: ticketId,
      busNumber: bus.busNumber,
      source: bus.routeName.split('-')[0].trim(),
      destination: bus.routeName.split('-').length > 1 ? bus.routeName.split('-')[1].trim() : "Destination",
      travelDate: date,
      totalFare: _totalFare,
      seatNumbers: List.from(_selectedSeats.map((i) => i + 1)),
    );

    _bookedTickets.add(newTicket);
    
    for (var index in _selectedSeats) {
      if (index < bus.seatMap.length) {
        bus.seatMap[index] = true;
      }
    }
    
    clearSelection();
    return newTicket;
  }

  // UPDATED: Mark ticket as cancelled instead of deleting
  void cancelTicket(String ticketId) {
    for (var ticket in _bookedTickets) {
      if (ticket.ticketId == ticketId) {
        ticket.isCancelled = true;
        break;
      }
    }
    notifyListeners();
  }
}
