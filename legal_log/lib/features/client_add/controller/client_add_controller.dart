import 'package:country_code_picker/country_code_picker.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:legal_log/features/client_add/model/client.dart';
import 'package:legal_log/features/client_add/services/client_firebase_services.dart';

/// Controller for managing client registration logic and form validation.
class ClientAddController extends GetxController {
  final GetStorage storage = GetStorage();
  final formKey = GlobalKey<FormState>();

  // Observable variables for the form fields
  final selectedCountryCode = '+91'.obs;
  final name = ''.obs;
  final address = ''.obs;
  final phoneNo = ''.obs;
  final email = ''.obs;
  final clientId = ''.obs;
  final caseNos = <String>[].obs; // List for associated case numbers

  // TextEditingControllers for each field
  late final TextEditingController nameController;
  late final TextEditingController addressController;
  late final TextEditingController phoneNoController;
  late final TextEditingController emailController;
  late final TextEditingController clientIdController;
  late final TextEditingController caseNolistController;
  // late final TextEditingController clientIdController;

  @override
  void onInit() {
    super.onInit();

    // Initialize controllers and sync with observables
    nameController = TextEditingController(text: name.value);
    addressController = TextEditingController(text: address.value);
    phoneNoController = TextEditingController(text: phoneNo.value);
    emailController = TextEditingController(text: email.value);
    clientIdController = TextEditingController(text: clientId.value);
    caseNolistController = TextEditingController(text: caseNos.join(', '));

    // Add listeners to update Rx variables
    nameController.addListener(() => name.value = nameController.text);
    addressController.addListener(() => address.value = addressController.text);
    phoneNoController.addListener(() => phoneNo.value = phoneNoController.text);
    emailController.addListener(() => email.value = emailController.text);
    clientIdController.addListener(() => clientId.value = clientIdController.text);
        caseNolistController.addListener(() {
      caseNos.value = caseNolistController.text
          .split(',')
          .map((e) => e.trim()) // Trim whitespace
          .where((e) => e.isNotEmpty) // Ignore empty strings
          .toList();
    });
  }

  @override
  void onClose() {
    // Dispose controllers to avoid memory leaks
    nameController.dispose();
    addressController.dispose();
    phoneNoController.dispose();
    emailController.dispose();
    clientIdController.dispose();
    caseNolistController.dispose();
    super.onClose();
  }

  void Clear_Controllers() {
    nameController.clear();
    addressController.clear();
    phoneNoController.clear();
    emailController.clear();
    clientIdController.clear();
    caseNolistController.clear();    
  }

  // ----------------------------- Validation Methods -----------------------------
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return "Name cannot be empty.";
    if (value.trim().length < 3) return "Name must be at least 3 characters.";
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty)
      return "Address cannot be empty.";
    return null;
  }

  String? validateCaseNos(String? value) {
    if (value == null || value.trim().isEmpty)
      return "Case Numbers cannot be empty.";
    return null;
  }

  String? validatePhoneNo(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Mobile number is required';
    if (!RegExp(r'^\d{10}$').hasMatch(value.trim()))
      return 'Enter a valid 10-digit mobile number';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return "Email cannot be empty.";
    final regex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (!regex.hasMatch(value.trim())) return "Enter a valid email address.";
    return null;
  }

  String? validateClientId(String? value) {
    if (value == null || value.trim().isEmpty)
      return "Client ID cannot be empty.";
    return null;
  }

  // -------------------------- Form-wide Validation ------------------------------
  /// Validates all fields and returns a list of error messages.
  List<String> validateAllFields() {
    List<String> errors = [];

    // Validate all fields
    final validations = [
      validateName(name.value),
      validateAddress(address.value),
      validatePhoneNo(phoneNo.value),
      validateEmail(email.value),
      validateClientId(clientId.value),
      validateCaseNos(caseNos.join(', ')),
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
          advocate_id: storage.read('user')['advocate_id'],
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

  // Update the selected country code
  void updateCountryCode(CountryCode code) {
    selectedCountryCode.value = code.dialCode!;
  }
}
