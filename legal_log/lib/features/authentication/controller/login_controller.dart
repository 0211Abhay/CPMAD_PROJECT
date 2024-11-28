import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/widgets/editable_text.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:legal_log/features/home_page/controller/home_screen_controller.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class LoginController extends GetxController {
  var obscurePassword = true.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();
  final homepagecontroller = Get.put(HomeScreenController());

  final String senderEmail =
      'aryan.langhanoja119561@marwadiuniversity.ac.in'; // Replace with your email
  final String senderPassword =
      'dvvm xula uqrn nolx'; // Replace with your app password

  // Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // Validate email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Fetch IP address
  Future<String> getIpAddress() async {
    try {
      final response =
          await http.get(Uri.parse('https://api.ipify.org?format=json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ip'];
      }
    } catch (e) {
      print('Error fetching IP address: $e');
    }
    return 'Unknown IP';
  }

  // Fetch location from IP
  Future<String> getLocationFromIp(String ipAddress) async {
    try {
      final response =
          await http.get(Uri.parse('http://ip-api.com/json/$ipAddress'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final city = data['city'] ?? 'Unknown city';
        final region = data['regionName'] ?? 'Unknown region';
        final country = data['country'] ?? 'Unknown country';
        return '$city, $region, $country';
      }
    } catch (e) {
      print('Error fetching location: $e');
    }
    return 'Location not available';
  }

  // Fetch precise location using Geolocator and Geocoding
  Future<String> getPreciseLocation() async {
    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          return 'Permission denied';
        }
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocode position
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.locality}, ${place.administrativeArea}, ${place.country}';
      } else {
        return 'Location not found';
      }
    } catch (e) {
      print('Error fetching precise location: $e');
      return 'Error fetching precise location';
    }
  }

  // Send login notification email
  Future<void> sendLoginNotification(
      String email, String ipAddress, String location) async {
    final smtpServer = gmail(senderEmail, senderPassword);
    final message = Message()
      ..from = Address(senderEmail, 'Legal Log')
      ..recipients.add(email)
      ..subject = 'Login Notification'
      ..text = '''
        Hello,

        A login to your account was detected from:
        IP Address: $ipAddress
        Location: $location

        If this was you, no action is needed.
        If you did not perform this action, please secure your account immediately.

        Regards,
        Legal Log Team
      ''';

    // homepagecontroller.location = location as RxString;

    try {
      await send(message, smtpServer);
      print('Login notification email sent.');
    } catch (e) {
      print('Error sending email: $e');
    }
  }

  // Login user
  Future<void> loginUser(String email, String password) async {
    try {
      // ignore: unused_local_variable
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user data from Firestore
      QuerySnapshot querySnapshot = await _firestore
          .collection('advocate')
          .where('email_address', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data();
        _storage.write('user', userData); // Store user data locally

        // Fetch IP and location
        final ipAddress = await getIpAddress();
        final locationFromIp = await getLocationFromIp(ipAddress);

        // Fetch precise location
        final preciseLocation = await getPreciseLocation();

        // Choose the most detailed location
        final location = preciseLocation != 'Permission denied'
            ? preciseLocation
            : locationFromIp;

        // Send login notification
        await sendLoginNotification(email, ipAddress, location);

        // Dismiss loader and navigate to home page
        Get.back(); // Close the loader dialog
        Get.toNamed('/home_page');
      } else {
        Get.back(); // Close the loader dialog
        Get.snackbar('Error', 'User data not found in Firestore');
      }
    } catch (e) {
      Get.back(); // Close the loader dialog
      Get.snackbar('Login Error', e.toString());
    }
  }

  // Logout user
  Future<void> logout() async {
    await _auth.signOut();
    _storage.erase(); // Clear locally stored data
    Get.offAllNamed('/login');
  }
}
