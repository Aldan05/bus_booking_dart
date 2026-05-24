import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bus_model.dart';
import '../controllers/booking_controller.dart';
import 'ticket_screen.dart';

class BookingScreen extends StatefulWidget {
  final BusModel bus;
  final String? travelDate;
  
  const BookingScreen({super.key, required this.bus, this.travelDate});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  @override
  void initState() {
    super.initState();
    // Clear any previous selections when opening the booking screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingController>(context, listen: false).clearSelection();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingController = Provider.of<BookingController>(context);
    final selectedSeats = bookingController.selectedSeats;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Your Seats"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header Info
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.withOpacity(0.05),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.bus.busNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text("₹${widget.bus.fare}/seat", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(widget.travelDate ?? "Today", style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),

          // Seat Legend
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegend(Icons.event_seat, Colors.grey[300]!, "Available"),
                _buildLegend(Icons.event_seat, Colors.blue, "Selected"),
                _buildLegend(Icons.event_seat, Colors.red[200]!, "Booked"),
              ],
            ),
          ),

          // Seat Map
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: GridView.builder(
                itemCount: widget.bus.totalSeats,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  // Simulate an aisle after 2 seats
                  if (index % 4 == 2) {
                    return const SizedBox.shrink(); // Aisle spacer
                  }
                  
                  bool isBooked = widget.bus.seatMap[index];
                  bool isSelected = selectedSeats.contains(index);

                  return GestureDetector(
                    onTap: isBooked ? null : () {
                      bookingController.toggleSeat(index, widget.bus.fare);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isBooked 
                            ? Colors.red[100] 
                            : isSelected ? Colors.blue : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.event_seat, 
                          color: isBooked 
                              ? Colors.red[400] 
                              : isSelected ? Colors.white : Colors.grey[500],
                          size: 24,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("${selectedSeats.length} Seats Selected", style: const TextStyle(color: Colors.grey)),
                      Text(
                        "₹${bookingController.totalFare.toStringAsFixed(0)}",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedSeats.isEmpty ? Colors.grey : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: selectedSeats.isEmpty ? null : () {
                      final ticket = bookingController.confirmBooking(
                        widget.bus, 
                        widget.travelDate ?? "Today"
                      );
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Successfully booked ${selectedSeats.length} seats!")),
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TicketScreen(ticket: ticket),
                        ),
                      );
                    },
                    child: const Text("Confirm & Pay", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(IconData icon, Color color, String label) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
