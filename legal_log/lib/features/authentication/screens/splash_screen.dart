import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final GetStorage _storage = GetStorage(); // For session storage
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase authentication instance

  @override
  void initState() {
    super.initState();

    // Start timer and handle session
    Timer(Duration(seconds: 3), _handleSession);
  }

  // Session handling logic
  void _handleSession() async {
    try {
      // Check for locally stored user session
      final storedUser = _storage.read('user');

      if (storedUser != null) {
        // Verify Firebase authentication session
        User? firebaseUser = _auth.currentUser;
        if (firebaseUser != null && firebaseUser.email == storedUser['email_address']) {
          // Valid session, navigate to home page
          Get.offNamed('/home_page');
        } else {
          // Invalid session, clear storage and navigate to login
          _storage.erase();
          Get.offNamed('/login');
        }
      } else {
        // No session found, navigate to login
        Get.offNamed('/login');
      }
    } catch (e) {
      // Handle errors and navigate to login
      print('Session Error: $e');
      Get.offNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/logo-removebg-preview.png', // Splash logo
          width: MediaQuery.of(context).size.width * 0.6, // Responsive sizing
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
