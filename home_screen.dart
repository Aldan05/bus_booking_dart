import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/booking_controller.dart';
import '../controllers/bus_controller.dart';
import '../models/ticket_model.dart';
import '../services/voice_service.dart';
import '../utils/routes.dart';
import '../utils/constants.dart';
import 'live_status_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final VoiceService _voiceService = VoiceService();
  bool _isListening = false;

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("You will need to enter your OTP again to log back in. Continue?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await authController.logout();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, BookingController controller, TicketModel ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Ticket"),
        content: Text("Are you sure you want to cancel your booking to ${ticket.destination}?"),
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
                SnackBar(
                  content: Container(
                    height: 60,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("✅ Ticket Successfully Cancelled!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(height: 4),
                        Text("Money refund in progress... Expected within 7 bank working days.", style: TextStyle(fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ),
                  backgroundColor: Colors.black87,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  duration: const Duration(seconds: 6),
                  action: SnackBarAction(label: "OK", textColor: Colors.greenAccent, onPressed: () {}),
                ),
              );
            },
            child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _startGlobalVoiceAssistant(BookingController bookingController, BusController busController) async {
    setState(() => _isListening = true);
    await _voiceService.speak("How can I help you?", "en-US");
    
    String? result = await _voiceService.listen();
    setState(() => _isListening = false);

    if (result != null) {
      final query = result.toLowerCase();
      debugPrint("Voice Assistant Query: $query");
      
      // 1. IMPROVED: Live Status Tracking Commands
      if (query.contains("live status") || 
          query.contains("track") || 
          query.contains("where is my bus") || 
          query.contains("status")) {
        
        final confirmedTickets = bookingController.bookedTickets.where((t) => !t.isCancelled).toList();
        
        if (confirmedTickets.isNotEmpty) {
          final ticket = confirmedTickets.last;
          final bus = busController.filteredBuses.firstWhere(
            (b) => b.busNumber == ticket.busNumber,
            orElse: () => busController.filteredBuses[0],
          );
          await _voiceService.speak("Opening live status for your bus to ${ticket.destination}.", "en-US");
          if (mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => LiveStatusScreen(bus: bus)));
          }
        } else {
          await _voiceService.speak("I couldn't find any active bookings to track.", "en-US");
        }
      } 
      // 2. IMPROVED: Call Us / Support Commands
      else if (query.contains("call us") || 
               query.contains("call support") || 
               query.contains("phone") || 
               query.contains("dial")) {
        await _voiceService.speak("Opening the help center so you can call us.", "en-US");
        if (mounted) Navigator.pushNamed(context, AppRoutes.support);
      }
      // 3. General Support / Contact
      else if (query.contains("contact") || query.contains("support") || query.contains("help")) {
        await _voiceService.speak("Opening contact and support details.", "en-US");
        if (mounted) Navigator.pushNamed(context, AppRoutes.support);
      }
      // 4. Live Chat
      else if (query.contains("live chat") || query.contains("message") || query.contains("chat")) {
        await _voiceService.speak("Opening live chat support.", "en-US");
        if (mounted) Navigator.pushNamed(context, AppRoutes.chatSupport);
      } 
      // 5. My Bookings
      else if (query.contains("ticket") || query.contains("history") || query.contains("my booking")) {
        await _voiceService.speak("Showing your booked tickets.", "en-US");
        if (mounted) Navigator.pushNamed(context, AppRoutes.myTickets);
      } 
      // 6. Feedback
      else if (query.contains("feedback") || query.contains("review")) {
        await _voiceService.speak("Opening feedback screen.", "en-US");
        if (mounted) Navigator.pushNamed(context, AppRoutes.feedback);
      } 
      // 7. Booking
      else if (query.contains("book") || query.contains("new journey")) {
        await _voiceService.speak("Opening voice booking assistant.", "en-US");
        if (mounted) Navigator.pushNamed(context, AppRoutes.voiceBooking);
      } 
      // 8. Logout
      else if (query.contains("logout") || query.contains("sign out")) {
        await _voiceService.speak("Do you want to logout?", "en-US");
        if (mounted) {
          final authController = Provider.of<AuthController>(context, listen: false);
          _showLogoutDialog(context, authController);
        }
      } 
      else {
        await _voiceService.speak("I didn't quite get that. Try saying 'track my bus' or 'open call us'.", "en-US");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final bookingController = context.watch<BookingController>();
    final busController = context.watch<BusController>();

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text("SmartBus Home", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(_isListening ? Icons.mic : Icons.mic_none, 
                color: _isListening ? Colors.redAccent : Colors.white),
              onPressed: () => _startGlobalVoiceAssistant(bookingController, busController),
              tooltip: "Voice Assistant",
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _showLogoutDialog(context, authController),
              tooltip: "Logout",
            )
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.voiceBooking),
                  icon: const Icon(Icons.mic, size: 28),
                  label: const Text("Voice Booking Assistance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello, ${authController.userName}!",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const Text("Welcome back to SmartBus TN", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                    child: const Icon(Icons.person, color: AppConstants.primaryColor),
                  )
                ],
              ),
              const SizedBox(height: 30),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    const Text("Book your journey", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.searchBus),
                        icon: const Icon(Icons.search),
                        label: const Text("Search & Book", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 30),
              const Text("Services", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.5,
                children: [
                  _buildQuickCard(Icons.confirmation_number, "My Tickets", () => Navigator.pushNamed(context, AppRoutes.myTickets)),
                  _buildQuickCard(Icons.support_agent, "Help Center", () => Navigator.pushNamed(context, AppRoutes.support)),
                  _buildQuickCard(Icons.feedback, "Feedback", () => Navigator.pushNamed(context, AppRoutes.feedback)),
                  _buildQuickCard(Icons.live_tv, "Live Status", () => Navigator.pushNamed(context, AppRoutes.searchBus)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCard(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppConstants.primaryColor),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
