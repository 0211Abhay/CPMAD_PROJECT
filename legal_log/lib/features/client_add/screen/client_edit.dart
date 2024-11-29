import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:legal_log/common_widgets/custom_text_fields.dart';
import 'package:legal_log/features/client_add/controller/client_edit_controller.dart';

class ClientUpdateScreen extends StatelessWidget {
  final ClientEditController controller = Get.put(ClientEditController());

  ClientUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final client = args['client'];
    final documentId = args['documentId'];

    // Set client data for editing
    controller.setClientData(client, documentId);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
          Get.back();
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text('Update Client Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Text(
                    'Update Client Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Edit the client details and save changes',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  // Form Fields
                  CustomTextField(
                    label: 'Name',
                    controller: controller.nameController,
                    prefixIcon: Icon(Icons.person),
                    validator: controller.validateName,
                  ),
                  const SizedBox(height: 10),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CountryCodePicker(
                            onChanged: (CountryCode code) {
                              controller.updateCountryCode(code);
                            },
                            initialSelection: controller.selectedCountryCode.value,
                            favorite: ['+91', 'IN'], // Show India as a favorite
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 5,
                        child: CustomTextField(
                          label: 'Mobile No',
                          controller: controller.phoneNoController,
                          prefixIcon: Icon(Icons.phone),
                          validator: controller.validatePhoneNo,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Email Address',
                    controller: controller.emailController,
                    prefixIcon: Icon(Icons.email),
                    validator: controller.validateEmail,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Address',
                    controller: controller.addressController,
                    prefixIcon: Icon(Icons.house),
                    validator: controller.validateAddress,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Client ID',
                    controller: controller.clientIdController,
                    prefixIcon: Icon(Icons.card_membership),
                    validator: controller.validateClientId,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Case Numbers',
                    controller: controller.caseNolistController,
                    prefixIcon: Icon(Icons.file_copy),
                    validator: controller.validateCaseNos,
                  ),
                  const SizedBox(height: 20),

                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (controller.formKey.currentState?.validate() ?? false) {
                          controller.updateClient();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Update Client',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
