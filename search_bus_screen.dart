import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';
import '../utils/routes.dart';

class SearchBusScreen extends StatefulWidget {
  const SearchBusScreen({super.key});

  @override
  State<SearchBusScreen> createState() => _SearchBusScreenState();
}

class _SearchBusScreenState extends State<SearchBusScreen> {
  String? selectedSource;
  String? selectedDestination;
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppConstants.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Your Bus"),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Source Selection
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: DropdownButtonFormField<String>(
                  value: selectedSource,
                  decoration: const InputDecoration(
                    labelText: "From (Source)",
                    prefixIcon: Icon(Icons.my_location, color: Colors.green),
                    border: InputBorder.none,
                  ),
                  hint: const Text("Select District"),
                  items: AppConstants.tnDistricts.map((district) {
                    return DropdownMenuItem(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSource = value;
                    });
                  },
                ),
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Icon(Icons.swap_vert, size: 32, color: Colors.grey),
            ),
            
            // Destination Selection
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: DropdownButtonFormField<String>(
                  value: selectedDestination,
                  decoration: const InputDecoration(
                    labelText: "To (Destination)",
                    prefixIcon: Icon(Icons.location_on, color: Colors.red),
                    border: InputBorder.none,
                  ),
                  hint: const Text("Select District"),
                  items: AppConstants.tnDistricts.map((district) {
                    return DropdownMenuItem(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDestination = value;
                    });
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // Date Selection
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppConstants.primaryColor),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Travel Date", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(
                            DateFormat('EEE, dd MMM yyyy').format(selectedDate),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.edit, size: 18, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            ElevatedButton(
              onPressed: () {
                if (selectedSource == null || selectedDestination == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select both source and destination")),
                  );
                  return;
                }
                
                if (selectedSource == selectedDestination) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Source and Destination cannot be the same")),
                  );
                  return;
                }

                Navigator.pushNamed(
                  context, 
                  AppRoutes.busList,
                  arguments: {
                    'source': selectedSource!,
                    'destination': selectedDestination!,
                    'date': DateFormat('yyyy-MM-dd').format(selectedDate),
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Search Buses", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}
