import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:legal_log/features/case_add/model/case.dart';
import 'package:legal_log/features/case_add/services/case_firebase_services.dart'; // Import your Firebase service file

/// Controller for managing case registration logic and form validation.
class RegistrationController extends GetxController {
  // Observable variables for the form fields
  final fileNo = ''.obs;
  final caseNo = ''.obs;
  final applicantName = ''.obs;
  final opponentName = ''.obs;
  final clientName = ''.obs;
  final dateOfFiling = ''.obs;
  final stage = ''.obs;
  final previousDate = ''.obs;
  final area = ''.obs;
  final court = ''.obs;
  final caseNote = ''.obs;
  final mobileNumber = ''.obs;

  // ----------------------------- Validation Methods -----------------------------

  String? validateFileNo() {
    if (fileNo.value.trim().isEmpty) return "File No cannot be empty.";
    return null;
  }

  String? validateCaseNo() {
    if (caseNo.value.trim().isEmpty) return "Case No cannot be empty.";
    return null;
  }

  String? validateApplicantName() {
    if (applicantName.value.trim().isEmpty) {
      return "Applicant Name cannot be empty.";
    }
    if (applicantName.value.trim().length < 3) {
      return "Applicant Name must be at least 3 characters.";
    }
    return null;
  }

  String? validateOpponentName() {
    if (opponentName.value.trim().isEmpty)
      return "Opponent Name cannot be empty.";
    return null;
  }

  String? validateClientName() {
    if (clientName.value.trim().isEmpty) return "Client Name cannot be empty.";
    return null;
  }

  String? validateDateOfFiling() {
    if (dateOfFiling.value.trim().isEmpty) {
      return "Date of Filing cannot be empty.";
    }
    final regex = RegExp(r"^\d{2}/\d{2}/\d{4}$");
    if (!regex.hasMatch(dateOfFiling.value.trim())) {
      return "Enter a valid date in DD/MM/YYYY format.";
    }
    return null;
  }

  String? validateStage() {
    if (stage.value.trim().isEmpty) return "Stage cannot be empty.";
    return null;
  }

  String? validatePreviousDate() {
    if (previousDate.value.trim().isEmpty) {
      return "Previous Date cannot be empty.";
    }
    final regex = RegExp(r"^\d{2}/\d{2}/\d{4}$");
    if (!regex.hasMatch(previousDate.value.trim())) {
      return "Enter a valid date in DD/MM/YYYY format.";
    }
    return null;
  }

  String? validateArea() {
    if (area.value.trim().isEmpty) return "Area cannot be empty.";
    return null;
  }

  String? validateCourt() {
    if (court.value.trim().isEmpty) return "Court cannot be empty.";
    return null;
  }

  String? validateCaseNote() {
    if (caseNote.value.trim().isEmpty) return "Case Note cannot be empty.";
    return null;
  }

  String? validateMobileNumber() {
    if (mobileNumber.value.trim().isEmpty) {
      return "Mobile Number cannot be empty.";
    }
    final regex = RegExp(r"^\d{10}$");
    if (!regex.hasMatch(mobileNumber.value.trim())) {
      return "Enter a valid 10-digit mobile number.";
    }
    return null;
  }

  // -------------------------- Form-wide Validation ------------------------------

  /// Validates all fields and returns a list of error messages.
  List<String> validateAllFields() {
    List<String> errors = [];

    final validations = [
      validateFileNo(),
      validateCaseNo(),
      validateApplicantName(),
      validateOpponentName(),
      validateClientName(),
      validateDateOfFiling(),
      validateStage(),
      validatePreviousDate(),
      validateArea(),
      validateCourt(),
      validateCaseNote(),
      validateMobileNumber(),
    ];

    for (var validation in validations) {
      if (validation != null) errors.add(validation);
    }

    return errors;
  }

  // ------------------------- Registration Logic -----------------------------

  /// Attempts to register a case after validating all fields.
  Future<void> registerCase() async {
    final errors = validateAllFields();

    if (errors.isEmpty) {
      try {
        // Prepare case data
        final caseData = {
          "fileNo": fileNo.value,
          "caseNo": caseNo.value,
          "applicantName": applicantName.value,
          "opponentName": opponentName.value,
          "clientName": clientName.value,
          "dateOfFiling": dateOfFiling.value,
          "stage": stage.value,
          "previousDate": previousDate.value,
          "area": area.value,
          "court": court.value,
          "caseNote": caseNote.value,
          "mobileNumber": mobileNumber.value,
        };

        // Call the Firebase service to add the case
        await CaseFirebaseServices().addCase(caseData as Case);

        // Show success message
        Get.snackbar(
          'Success',
          'Case Registered Successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (error) {
        // Handle Firebase errors
        Get.snackbar(
          'Error',
          'Failed to register case. Please try again.',
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
