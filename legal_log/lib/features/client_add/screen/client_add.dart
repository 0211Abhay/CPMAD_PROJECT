import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:legal_log/common_widgets/custom_text_fields.dart';
import 'package:legal_log/features/client_add/controller/client_add_controller.dart';

class ClientRegistrationScreen extends StatelessWidget {
  final ClientAddController controller = Get.put(ClientAddController());

  ClientRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    'Register A Client',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Enter clinet details to register',
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
                    children: [
                      Expanded(
                        flex: 2,
                        child: CountryCodePicker(
                          onChanged: (CountryCode code) {
                            controller.updateCountryCode(code);
                          },
                          initialSelection: 'IN', // Default to India
                          favorite: ['+91', 'IN'], // Show India as a favorite
                          showFlag: true,
                          showFlagDialog: true,
                          showCountryOnly: false,
                          showOnlyCountryWhenClosed: false,
                          alignLeft: false,
                        ),
                      ),
                      const SizedBox(width: 10),
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
              
                  // Next Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Check if the form is valid
                        if (controller.formKey.currentState?.validate() ??
                            false) {
                          // If valid, submit the case
                          controller.registerClient();
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
                        'Add Case',
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
