import 'package:flutter/material.dart';

import '../screens/otp_login.dart';
import '../screens/otp_verification_screen.dart'; // NEW
import '../screens/home_screen.dart';
import '../screens/search_bus_screen.dart';
import '../screens/bus_list_screen.dart';
import '../screens/ticket_screen.dart';
import '../screens/my_tickets_screen.dart';
import '../screens/feedback_screen.dart';
import '../screens/support_screen.dart';
import '../screens/chat_support_screen.dart';
import '../screens/voice_booking_screen.dart';
import '../screens/live_status_screen.dart';
import '../models/ticket_model.dart';
import '../models/bus_model.dart';

class AppRoutes {
  static const String login = '/';
  static const String otpVerify = '/otp-verify'; // NEW
  static const String home = '/home';
  static const String searchBus = '/search-bus';
  static const String busList = '/bus-list';
  static const String ticket = '/ticket';
  static const String myTickets = '/my-tickets';
  static const String feedback = '/feedback';
  static const String support = '/support';
  static const String chatSupport = '/chat-support';
  static const String voiceBooking = '/voice-booking';
  static const String liveStatus = '/live-status';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const OtpLogin(),
      otpVerify: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
        return OtpVerificationScreen(
          phoneNumber: args['phoneNumber'],
          verificationId: args['verificationId'],
          confirmationResult: args['confirmationResult'],
        );
      },
      home: (context) => const HomeScreen(),
      searchBus: (context) => const SearchBusScreen(),
      busList: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return BusListScreen(
          source: args?['source'] ?? "Chennai",
          destination: args?['destination'] ?? "Madurai",
          date: args?['date'],
        );
      },
      ticket: (context) {
        final ticket = ModalRoute.of(context)?.settings.arguments as TicketModel?;
        return TicketScreen(ticket: ticket);
      },
      myTickets: (context) => const MyTicketsScreen(),
      feedback: (context) => const FeedbackScreen(),
      support: (context) => const SupportScreen(),
      chatSupport: (context) => const ChatSupportScreen(),
      voiceBooking: (context) => const VoiceBookingScreen(),
      liveStatus: (context) {
        final bus = ModalRoute.of(context)?.settings.arguments as BusModel;
        return LiveStatusScreen(bus: bus);
      },
    };
  }
}
