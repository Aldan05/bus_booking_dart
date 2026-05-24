import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/routes.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Support"),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.support_agent,
                size: 100,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "How can we help you?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const Center(
              child: Text(
                "We are available 24/7 to solve your queries",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 40),
            
            // Contact Options
            _buildSupportCard(
              context,
              icon: Icons.phone,
              title: "Call Us",
              subtitle: "+91 98765 43210",
              onTap: () {
                // In a real app, use url_launcher to dial
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Dialing +91 98765 43210...")),
                );
              },
            ),
            const SizedBox(height: 15),
            _buildSupportCard(
              context,
              icon: Icons.email,
              title: "Email Us",
              subtitle: "support@smartbus.tn",
              onTap: () {
                // In a real app, use url_launcher to open email client
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Opening email to support@smartbus.tn...")),
                );
              },
            ),
            const SizedBox(height: 15),
            _buildSupportCard(
              context,
              icon: Icons.chat,
              title: "Live Chat",
              subtitle: "Instant answers to basic questions",
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.chatSupport);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
          child: Icon(icon, color: AppConstants.primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
