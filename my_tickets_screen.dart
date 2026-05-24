import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../models/ticket_model.dart';
import '../controllers/booking_controller.dart';
import '../controllers/bus_controller.dart';
import 'ticket_screen.dart';
import 'live_status_screen.dart';

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  void _showCancelDialog(BuildContext context, BookingController controller, TicketModel ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Ticket"),
        content: Text("Are you sure you want to cancel your booking from ${ticket.source} to ${ticket.destination}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              controller.cancelTicket(ticket.ticketId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Ticket Cancelled! Refund process started."),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingController = context.watch<BookingController>();
    final busController = context.watch<BusController>();
    final myBookings = bookingController.bookedTickets;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Booking History"),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: myBookings.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: myBookings.length,
              itemBuilder: (context, index) {
                final ticket = myBookings[myBookings.length - 1 - index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  elevation: 2,
                  color: ticket.isCancelled ? Colors.red[50] : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: ticket.isCancelled ? Colors.red.shade200 : Colors.transparent),
                  ),
                  child: Column(
                    children: [
                      // Status Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: ticket.isCancelled ? Colors.red[400] : Colors.green[500],
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ticket.isCancelled ? "CANCELLED" : "CONFIRMED",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            Text(
                              "₹${ticket.totalFare.toStringAsFixed(0)}",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: ticket.isCancelled ? Colors.red[100] : AppConstants.primaryColor.withOpacity(0.1),
                          child: Icon(Icons.directions_bus, color: ticket.isCancelled ? Colors.red : AppConstants.primaryColor),
                        ),
                        title: Text("${ticket.source} ➔ ${ticket.destination}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Date: ${ticket.travelDate} | Bus: ${ticket.busNumber}"),
                        trailing: !ticket.isCancelled 
                          ? IconButton(
                              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                              onPressed: () => _showCancelDialog(context, bookingController, ticket),
                            )
                          : const Icon(Icons.history, color: Colors.grey),
                      ),

                      if (!ticket.isCancelled)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => TicketScreen(ticket: ticket)),
                                    );
                                  },
                                  icon: const Icon(Icons.qr_code, size: 18),
                                  label: const Text("View Ticket"),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    // FIXED: Changed 'buses' to 'filteredBuses' to resolve compilation error
                                    final bus = busController.filteredBuses.firstWhere(
                                      (b) => b.busNumber == ticket.busNumber,
                                      orElse: () => busController.filteredBuses[0],
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => LiveStatusScreen(bus: bus)),
                                    );
                                  },
                                  icon: const Icon(Icons.gps_fixed, size: 18),
                                  label: const Text("Live Track"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      if (ticket.isCancelled)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          color: Colors.red[50],
                          child: const Text(
                            "Refund of full amount is being processed to your bank account.",
                            style: TextStyle(fontSize: 11, color: Colors.red, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.confirmation_number_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text("No bookings yet.", style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 30),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Go Book Now")),
        ],
      ),
    );
  }
}
