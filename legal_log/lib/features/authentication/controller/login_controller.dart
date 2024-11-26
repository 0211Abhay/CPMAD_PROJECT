import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class LoginController extends GetxController {
  var obscurePassword = true.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();

  final String senderEmail = 'aryan.langhanoja119561@marwadiuniversity.ac.in'; // Replace with your email
  final String senderPassword = 'dvvm xula uqrn nolx';    // Replace with your app password

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
      final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));
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
      final response = await http.get(Uri.parse('http://ip-api.com/json/$ipAddress'));
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

  // Send login notification email
  Future<void> sendLoginNotification(String email, String ipAddress, String location) async {
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

        // Fetch IP and location, then send notification
        final ipAddress = await getIpAddress();
        final location = await getLocationFromIp(ipAddress);
        await sendLoginNotification(email, ipAddress, location);

        Get.toNamed('/home_page');
      } else {
        Get.snackbar('Error', 'User data not found in Firestore');
      }
    } catch (e) {
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
