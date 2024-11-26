import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:legal_log/features/client_add/model/client.dart';
import 'package:legal_log/features/client_add/services/client_firebase_services.dart'; // Import your Firebase service file

/// Controller for managing client registration logic and form validation.
class ClientAddController extends GetxController {
  // Observable variables for the form fields
  final name = ''.obs;
  final address = ''.obs;
  final phoneNo = ''.obs;
  final email = ''.obs;
  final clientId = ''.obs;
  final caseNos = <String>[].obs; // List for associated case numbers

  // ----------------------------- Validation Methods -----------------------------

  String? validateName() {
    if (name.value.trim().isEmpty) return "Name cannot be empty.";
    if (name.value.trim().length < 3) {
      return "Name must be at least 3 characters.";
    }
    return null;
  }

  String? validateAddress() {
    if (address.value.trim().isEmpty) return "Address cannot be empty.";
    return null;
  }

  String? validatePhoneNo() {
    if (phoneNo.value.trim().isEmpty) return "Phone number cannot be empty.";
    final regex = RegExp(r"^\d{10}$");
    if (!regex.hasMatch(phoneNo.value.trim())) {
      return "Enter a valid 10-digit phone number.";
    }
    return null;
  }

  String? validateEmail() {
    if (email.value.trim().isEmpty) return "Email cannot be empty.";
    final regex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (!regex.hasMatch(email.value.trim())) {
      return "Enter a valid email address.";
    }
    return null;
  }

  String? validateClientId() {
    if (clientId.value.trim().isEmpty) return "Client ID cannot be empty.";
    return null;
  }

  // -------------------------- Form-wide Validation ------------------------------

  /// Validates all fields and returns a list of error messages.
  List<String> validateAllFields() {
    List<String> errors = [];

    final validations = [
      validateName(),
      validateAddress(),
      validatePhoneNo(),
      validateEmail(),
      validateClientId(),
    ];

    for (var validation in validations) {
      if (validation != null) errors.add(validation);
    }

    return errors;
  }

  // ------------------------- Registration Logic -----------------------------

  /// Attempts to register a client after validating all fields.
  Future<void> registerClient() async {
    final errors = validateAllFields();

    if (errors.isEmpty) {
      try {
        // Prepare client data
        final clientData = Client(
          name: name.value,
          address: address.value,
          phoneNo: phoneNo.value,
          email: email.value,
          clientId: clientId.value,
          caseNos: caseNos.toList(),
        );

        // Call the Firebase service to add the client
        await ClientFirebaseServices().addClient(clientData);

        // Show success message
        Get.snackbar(
          'Success',
          'Client Registered Successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (error) {
        // Handle Firebase errors
        Get.snackbar(
          'Error',
          'Failed to register client. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      // Show all validation errors
      Get.snackbar(
        'Error',
        errors.join("\n"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
