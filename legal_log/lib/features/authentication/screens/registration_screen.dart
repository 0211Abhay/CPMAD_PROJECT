import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:legal_log/common_widgets/custom_text_fields.dart';
import 'package:legal_log/features/authentication/controller/registration_controller.dart';
import 'package:lottie/lottie.dart';


class RegistrationScreen extends StatelessWidget {
  final RegistrationController controller = Get.put(RegistrationController());

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
                // Logo and Title
                Lottie.asset(
                  "assets/lottie/hammer.json",
                  width: 200, // Adjust the width
                  height: 200, // Adjust the height
                  fit: BoxFit.contain, // Ensure it fits within its bounds
                ),
                const SizedBox(height: 10),
                Text(
                  'Legal Log',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Register',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Enter your details to register',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),

                // Form Fields
                CustomTextField(label: 'Name'),
                const SizedBox(height: 10),
                CustomTextField(label: 'Email Address'),
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
                const SizedBox(height: 10),
                CustomTextField(label: 'Password', obscureText: true),
                const SizedBox(height: 10),
                CustomTextField(label: 'Confirm Password', obscureText: true),
                const SizedBox(height: 20),

                // Terms and Conditions Checkbox
                Row(
                  children: [
                    Obx(
                      () => Checkbox(
                        value: controller.agreeToTerms.value,
                        onChanged: (bool? value) {
                          controller.toggleAgreeToTerms();
                        },
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'I agree with the terms and conditions',
                        style: TextStyle(fontSize: 14),
                      ),
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
                          'Proceeding to the next screen...',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      } else {
                        Get.snackbar(
                          'Error',
                          'Please agree to the terms and conditions.',
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
                      'Next',
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