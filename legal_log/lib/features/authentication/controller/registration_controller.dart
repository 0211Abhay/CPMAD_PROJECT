import 'dart:math';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:legal_log/features/authentication/model/advocate_model.dart';

class RegistrationController extends GetxController {
  // Firebase Instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Form controllers
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var mobileController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();

  // Observables for state management
  var selectedCountryCode = '+91'.obs; // Default country code
  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;
  var agreeToTerms = false.obs;
  var generatedOtp = 0.obs;

  // Update the selected country code
  void updateCountryCode(CountryCode code) {
    selectedCountryCode.value = code.dialCode!;
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  // Toggle terms and conditions checkbox
  void toggleAgreeToTerms() {
    agreeToTerms.value = !agreeToTerms.value;
  }

  // Form validation
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    } else if (!GetUtils.isEmail(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    } else if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    } else if (value.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.trim() != passwordController.text.trim()) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Send OTP to email
  Future<void> sendVerificationEmail(String recipientEmail) async {
    final String senderEmail = 'aryan.langhanoja119561@marwadiuniversity.ac.in';
    final String senderPassword = 'dvvm xula uqrn nolx'; // Your email password
    generatedOtp.value = Random().nextInt(900000) + 100000; // Generate a 6-digit OTP

    final smtpServer = gmail(senderEmail, senderPassword);

    final message = Message()
      ..from = Address(senderEmail, 'Legal Log')
      ..recipients.add(recipientEmail)
      ..subject = 'Email Verification'
      ..text = 'Your verification code is ${generatedOtp.value}';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } catch (e) {
      print('Message not sent. Error: $e');
    }
  }

  // Verify OTP
  void verifyOtp(int userInputOtp) {
    if (userInputOtp == generatedOtp.value) {
      print("OTP verified successfully!");
      // Proceed to register the user in Firestore
      registerUser();
    } else {
      Get.snackbar(
        'Error',
        'Invalid OTP. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Register user after OTP verification
  Future<void> registerUser() async {
    if (!agreeToTerms.value) {
      Get.snackbar(
        'Error',
        'Please agree to the terms and conditions.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Concatenate country code with the mobile number
      String fullPhoneNumber = '${selectedCountryCode.value}${mobileController.text.trim()}';

      // Register user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Prepare advocate data
      Advocate advocate = Advocate(
        advocateId: userCredential.user!.uid,
        emailAddress: emailController.text.trim(),
        name: nameController.text.trim(),
        password: passwordController.text.trim(),
        phoneNo: fullPhoneNumber,
      );

      // Store advocate details in Firestore
      await _firestore.collection('advocate').doc(userCredential.user!.uid).set({
        'advocate_id': advocate.advocateId,
        'email_address': advocate.emailAddress,
        'name': advocate.name,
        'password': advocate.password, // Hash this in production!
        'phone_no': advocate.phoneNo,
      });

      Get.snackbar(
        'Success',
        'Registration completed successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.toNamed('/home_page');
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
