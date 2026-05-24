import 'dart:async';
import 'package:flutter/material.dart';
import '../models/bus_model.dart';
import '../utils/constants.dart';

class LiveStatusScreen extends StatefulWidget {
  final BusModel bus;
  const LiveStatusScreen({super.key, required this.bus});

  @override
  State<LiveStatusScreen> createState() => _LiveStatusScreenState();
}

class _LiveStatusScreenState extends State<LiveStatusScreen> {
  late double _currentLat;
  late double _currentLng;
  late double _remainingDistance;
  Timer? _timer;
  int _speed = 45;

  @override
  void initState() {
    super.initState();
    _currentLat = widget.bus.lat;
    _currentLng = widget.bus.lng;
    _remainingDistance = widget.bus.distanceKm;

    // Simulate real-time tracking updates
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Incrementally update coordinates
          _currentLat += 0.0001;
          _currentLng += 0.0001;
          
          // Decrement remaining distance
          if (_remainingDistance > 0.1) {
            _remainingDistance -= 0.0125; // Simulating travel
          }
          
          // Randomly fluctuate speed
          _speed = 40 + (timer.tick % 15);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Live Status: ${widget.bus.busNumber}"),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Live Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: Colors.white, size: 12),
                  SizedBox(width: 8),
                  Text("LIVE TRACKING", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Bus Info
            Text(widget.bus.routeName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(widget.bus.type, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 40),

            // Tracking Data Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.5,
                children: [
                  _buildStatusCard("Latitude", _currentLat.toStringAsFixed(5), Icons.location_on, Colors.blue),
                  _buildStatusCard("Longitude", _currentLng.toStringAsFixed(5), Icons.explore, Colors.green),
                  _buildStatusCard("Current Speed", "$_speed km/h", Icons.speed, Colors.orange),
                  _buildStatusCard("Distance Left", "${_remainingDistance.toStringAsFixed(2)} KM", Icons.trending_down, Colors.red),
                ],
              ),
            ),

            // Arrival Info Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    const Icon(Icons.timer, size: 40, color: AppConstants.primaryColor),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Estimated Time of Arrival", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(widget.bus.travelTime, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Data updates automatically every second",
              style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
