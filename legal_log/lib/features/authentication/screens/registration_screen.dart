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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate dynamic spacings
    double horizontalPadding = screenWidth * 0.05; // 5% of screen width
    double verticalSpacing = screenHeight * 0.02; // 2% of screen height

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Lottie.asset(
                  "assets/lottie/hammer.json",
                  width: screenWidth * 0.5, // 50% of screen width
                  height: screenHeight * 0.25, // 25% of screen height
                  fit: BoxFit.contain,
                ),
                SizedBox(height: verticalSpacing),

                // Title
                Text(
                  'Legal Log',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.06, // Dynamic font size
                  ),
                ),
                SizedBox(height: verticalSpacing),

                Text(
                  'Register',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.05,
                  ),
                ),
                SizedBox(height: verticalSpacing * 0.5),

                Text(
                  'Enter your details to register',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
                SizedBox(height: verticalSpacing * 1.5),

                // Form Fields
                CustomTextField(label: 'Name'),
                SizedBox(height: verticalSpacing),

                CustomTextField(label: 'Email Address'),
                SizedBox(height: verticalSpacing),

                // Country Picker with Mobile Number
                // Country Picker with Mobile Number
Row(
  children: [
    Expanded(
      flex: 2,
      child: Container(
        height: 50, // Match height with CustomTextField
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CountryCodePicker(
          onChanged: (CountryCode code) {
            controller.updateCountryCode(code);
          },
          initialSelection: 'IN',
          favorite: ['+91', 'IN'],
          showFlag: true,
          showFlagDialog: true,
          showCountryOnly: false,
          showOnlyCountryWhenClosed: true,
          alignLeft: false,
          padding: EdgeInsets.zero, // Remove default padding
          textStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          boxDecoration: BoxDecoration(
            color: Colors.transparent,
          ),
        ),
      ),
    ),
    SizedBox(width: screenWidth * 0.02),
    Expanded(
      flex: 5,
      child: CustomTextField(label: 'Mobile Number'),
    ),
  ],
),
                SizedBox(height: verticalSpacing),

                CustomTextField(label: 'Password', obscureText: true),
                SizedBox(height: verticalSpacing),

                CustomTextField(label: 'Confirm Password', obscureText: true),
                SizedBox(height: verticalSpacing * 1.5),

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
                        style: TextStyle(fontSize: screenWidth * 0.035),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: verticalSpacing * 1.5),

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
                      padding: EdgeInsets.symmetric(
                        vertical: verticalSpacing * 0.8, // Adjust vertical padding
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Next',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045, // Dynamic font size
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: verticalSpacing),

                // Already Have an Account Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(fontSize: screenWidth * 0.04),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.toNamed('/login'); // Navigate to login screen
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(fontSize: screenWidth * 0.04),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
