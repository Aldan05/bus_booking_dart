import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String? _userName;
  String get userName => _userName ?? "User";

  String? _pendingPhone;
  String? _lastError;
  String? get lastError => _lastError;

  AuthController() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _userName = prefs.getString('userName');
    notifyListeners();
  }

  /// Simplified check to fix permission errors
  Future<bool> checkPhoneExists(String phone) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final inputPhone = phone.trim();
      debugPrint("Checking Firestore for phone: $inputPhone");

      // Simple query - most likely to succeed with your rules
      final result = await _firestore
          .collection("users")
          .where("phone", isEqualTo: inputPhone)
          .get();

      _isLoading = false;
      
      if (result.docs.isNotEmpty) {
        _pendingPhone = result.docs.first.get('phone');
        notifyListeners();
        return true;
      } else {
        // Try one more time with +91 just in case
        final altResult = await _firestore
            .collection("users")
            .where("phone", isEqualTo: "+91$inputPhone")
            .get();
            
        if (altResult.docs.isNotEmpty) {
          _pendingPhone = altResult.docs.first.get('phone');
          notifyListeners();
          return true;
        }

        _lastError = "Number $inputPhone not found in Firestore.";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _lastError = "Firebase Error: ${e.toString()}";
      debugPrint("Firestore Detail: $e");
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyManualOTP(String otp) async {
    if (_pendingPhone == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _firestore
          .collection("users")
          .where("phone", isEqualTo: _pendingPhone)
          .where("otp", isEqualTo: otp.trim())
          .get();

      _isLoading = false;
      if (result.docs.isNotEmpty) {
        final userData = result.docs.first.data();
        _userName = userData['name'] ?? "User";
        _isLoggedIn = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userName', _userName!);
        notifyListeners();
        return true;
      } else {
        _lastError = "Wrong OTP. Try again.";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _lastError = "Error: ${e.toString()}";
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _userName = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
