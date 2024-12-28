import 'package:country_code_picker/country_code_picker.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:legal_log/features/client_add/model/client.dart';
import 'package:legal_log/features/client_add/services/client_firebase_services.dart';

class ClientEditController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final GetStorage storage = GetStorage();

  // Document ID of the client being updated
  String? documentId;

  // Observable variables for the form fields
  final selectedCountryCode = '+91'.obs;
  final name = ''.obs;
  final address = ''.obs;
  final phoneNo = ''.obs;
  final email = ''.obs;
  final clientId = ''.obs;
  final caseNos = <String>[].obs;

  // TextEditingControllers for each field
  late final TextEditingController nameController;
  late final TextEditingController addressController;
  late final TextEditingController phoneNoController;
  late final TextEditingController emailController;
  late final TextEditingController clientIdController;
  late final TextEditingController caseNolistController;

  // Initialize controllers and set client data for editing
  void setClientData(Client client, String? docId) {
    documentId = docId;
    name.value = client.name;
    address.value = client.address;
    phoneNo.value = client.phoneNo;
    email.value = client.email;
    clientId.value = client.clientId;
    caseNos.value = client.caseNos;

    nameController.text = client.name;
    addressController.text = client.address;
    phoneNoController.text = client.phoneNo;
    emailController.text = client.email;
    clientIdController.text = client.clientId;
    caseNolistController.text = client.caseNos.join(', ');
  }

  @override
  void onInit() {
    super.onInit();

    // Initialize controllers
    nameController = TextEditingController();
    addressController = TextEditingController();
    phoneNoController = TextEditingController();
    emailController = TextEditingController();
    clientIdController = TextEditingController();
    caseNolistController = TextEditingController();

    // Add listeners to update Rx variables
    nameController.addListener(() => name.value = nameController.text);
    addressController.addListener(() => address.value = addressController.text);
    phoneNoController.addListener(() => phoneNo.value = phoneNoController.text);
    emailController.addListener(() => email.value = emailController.text);
    clientIdController
        .addListener(() => clientId.value = clientIdController.text);
    caseNolistController.addListener(() {
      caseNos.value = caseNolistController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    });
  }

  void Clear_Controllers() {
    nameController.clear();
    addressController.clear();
    phoneNoController.clear();
    emailController.clear();
    clientIdController.clear();
    caseNolistController.clear();    
  }
  
  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    phoneNoController.dispose();
    emailController.dispose();
    clientIdController.dispose();
    caseNolistController.dispose();
    super.onClose();
  }

  // ---------------- Validation Methods ----------------
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return "Name cannot be empty.";
    if (value.trim().length < 3) return "Name must be at least 3 characters.";
    return null;
  }

  void updateCountryCode(CountryCode code) {
    selectedCountryCode.value = code.dialCode!;
  }

  String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty)
      return "Address cannot be empty.";
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

  String? validateCaseNos(String? value) {
    if (value == null || value.trim().isEmpty)
      return "Case Numbers cannot be empty.";
    return null;
  }

  // ---------------- Update Client Logic ----------------
  Future<void> updateClient() async {
    if (formKey.currentState?.validate() ?? false) {
      try {
        final updatedClient = Client(
          advocate_id: storage.read('user')['advocate_id'],
          name: name.value,
          address: address.value,
          phoneNo: phoneNo.value,
          email: email.value,
          clientId: clientId.value,
          caseNos: caseNos.toList(),
        );

        if (documentId == null) throw "Document ID is required for updating.";

        await ClientFirebaseServices().updateClient(updatedClient, documentId);

        Get.snackbar(
          'Success',
          'Client updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.toNamed("/home_page");
      } catch (e) {
        Get.snackbar(
          'Error',
          'An error occurred while updating client: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}
