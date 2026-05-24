import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/otp_login.dart';
import 'screens/home_screen.dart';

// Import your Controllers
import 'controllers/auth_controller.dart';
import 'controllers/bus_controller.dart';
import 'controllers/booking_controller.dart';

// Import Utils and Routes
import 'utils/routes.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCtoy3b_WtEfWx6B6fJ9UdvfBehLkJQ6qQ",
          appId: "1:285216282815:android:d184844b6e26dbdc3b8e0a", 
          messagingSenderId: "285216282815",
          projectId: "email-283b0",
          authDomain: "email-283b0.firebaseapp.com",
          storageBucket: "email-283b0.firebasestorage.app",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
    FirebaseAuth.instance;
  } catch (e) {
    debugPrint("Firebase Error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => BusController()),
        ChangeNotifierProvider(create: (_) => BookingController()),
      ],
      child: const BusApp(),
    ),
  );
}

class BusApp extends StatelessWidget {
  const BusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, _) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: AppConstants.primaryColor,
            colorScheme: ColorScheme.fromSeed(seedColor: AppConstants.primaryColor),
            useMaterial3: true,
          ),
          // FIX: Use initialRoute instead of home to avoid conflict with routes map
          initialRoute: auth.isLoggedIn ? AppRoutes.home : AppRoutes.login,
          routes: AppRoutes.getRoutes(),
        );
      }
    );
  }
}
