import 'package:flutter/material.dart';
import '../services/mock_data_service.dart';
import '../widgets/bus_card.dart';
import 'booking_screen.dart';

class BusListScreen extends StatelessWidget {
  final String source;
  final String destination;
  final String? date;

  const BusListScreen({super.key, required this.source, required this.destination, this.date});

  @override
  Widget build(BuildContext context) {
    // Pass source and destination to MockDataService
    final filteredBuses = MockDataService.getAvailableBuses(
      source: source, 
      destination: destination
    ).where((bus) {
      final route = bus.routeName.toLowerCase();
      return route.contains(source.toLowerCase()) && 
             route.contains(destination.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$source to $destination", style: const TextStyle(fontSize: 16)),
            if (date != null) 
              Text(date!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: filteredBuses.isEmpty 
        ? _buildEmptyState(context)
        : ListView.builder(
            itemCount: filteredBuses.length,
            itemBuilder: (context, index) {
              final bus = filteredBuses[index];
              return BusCard(
                bus: bus,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingScreen(bus: bus, travelDate: date),
                    ),
                  );
                },
              );
            }
          ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bus_alert, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            "No buses available for this date.",
            style: TextStyle(
              fontSize: 16, 
              color: Colors.grey[600], 
              fontWeight: FontWeight.w500
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Go Back"),
          )
        ],
      ),
    );
  }
}
