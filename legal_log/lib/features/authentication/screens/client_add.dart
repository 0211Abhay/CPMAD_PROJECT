import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:legal_log/common_widgets/custom_text_fields.dart';
import 'package:legal_log/features/authentication/controller/registration_controller.dart';

class ClientRegistrationScreen extends StatelessWidget {
  final RegistrationController controller = Get.put(RegistrationController());

  ClientRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
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
                CustomTextField(label: 'Name'),
                const SizedBox(height: 10),
                CustomTextField(label: 'Email Address'),
                const SizedBox(height: 10),
                CustomTextField(label: 'Address'),
                const SizedBox(height: 10),

                // Country Picker with Mobile Number
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
                      child: CustomTextField(label: 'Mobile Number'),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Next Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.agreeToTerms.value) {
                        Get.snackbar(
                          'Success',
                          'Client Added Sucessfully',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      } else {
                        Get.snackbar(
                          'Error',
                          'Please Enter Every Details',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
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
                      'Add Client',
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
    );
  }
}
