import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/ticket_model.dart';

class TicketScreen extends StatelessWidget {
  final TicketModel? ticket;

  const TicketScreen({super.key, this.ticket});

  @override
  Widget build(BuildContext context) {
    // Fallback data if no ticket is passed
    final String busNumber = ticket?.busNumber ?? "TN-01-AM-2026";
    final String route = ticket != null 
        ? "${ticket!.source} to ${ticket!.destination}" 
        : "Chennai to Madurai";
    final String qrData = ticket?.qrData ?? "BUS-TKT-MDU-10293847";
    final String date = ticket?.travelDate ?? "2024-10-24";
    final String seats = ticket?.seatNumbers.join(", ") ?? "Not Assigned";

    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        title: const Text("Your E-Ticket"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "SCAN AT BOARDING",
                style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const Divider(height: 30),
              QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200.0,
                gapless: false,
              ),
              const SizedBox(height: 20),
              Text(
                "Bus: $busNumber",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text("Route: $route", style: const TextStyle(fontSize: 16)),
              Text("Date: $date", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              
              // NEW: SEAT NUMBERS DISPLAY
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Seats: $seats",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
              
              const SizedBox(height: 20),
              const Text(
                "Ticket is valid for travel overall Tamil Nadu",
                style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                "Keep this QR code ready during inspection",
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
