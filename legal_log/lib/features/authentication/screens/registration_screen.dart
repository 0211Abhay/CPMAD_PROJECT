import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:legal_log/common_widgets/custom_text_fields.dart';
import 'package:lottie/lottie.dart';
import '../controller/registration_controller.dart';

class RegistrationScreen extends StatelessWidget {
  final RegistrationController controller = Get.put(RegistrationController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double horizontalPadding = screenWidth * 0.05;
    double verticalSpacing = screenHeight * 0.02;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo and Title
                  Image.asset(
                    'assets/images/logo-removebg-preview.png',
                    width: screenWidth * 0.5,
                    height: screenHeight * 0.25,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: verticalSpacing),

                  // Name Field
                  CustomTextField(
                    label: 'Name',
                    prefixIcon: Icon(Icons.person),
                    controller: controller.nameController,
                    validator: controller.validateName,
                  ),
                  SizedBox(height: verticalSpacing),

                  // Email Field
                  CustomTextField(
                    label: 'Email Address',
                    prefixIcon: const Icon(Icons.email_outlined),
                    controller: controller.emailController,
                    validator: controller.validateEmail,
                  ),
                  SizedBox(height: verticalSpacing),

                  // Country Picker with Mobile Number
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
                            initialSelection: 'IN',
                            favorite: ['+91', 'IN'],
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 5,
                        child: CustomTextField(
                          label: 'Mobile Number',
                          prefixIcon: Icon(Icons.phone),
                          controller: controller.mobileController,
                          validator: controller.validateMobile,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: verticalSpacing),

                  // Password Field
                  Obx(() => CustomTextField(
                        label: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        controller: controller.passwordController,
                        obscureText: controller.obscurePassword.value,
                        validator: controller.validatePassword,
                        suffixIcon: IconButton(
                          icon: Icon(controller.obscurePassword.value
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                      )),
                  SizedBox(height: verticalSpacing),

                  // Confirm Password Field
                  Obx(() => CustomTextField(
                        label: 'Confirm Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        controller: controller.confirmPasswordController,
                        obscureText: controller.obscureConfirmPassword.value,
                        validator: controller.validateConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(controller.obscureConfirmPassword.value
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: controller.toggleConfirmPasswordVisibility,
                        ),
                      )),
                  SizedBox(height: verticalSpacing * 1.5),

                  // Terms and Conditions
                  Row(
                    children: [
                      Obx(
                        () => Checkbox(
                          value: controller.agreeToTerms.value,
                          onChanged: (value) {
                            controller.toggleAgreeToTerms();
                          },
                        ),
                      ),
                      Expanded(
                        child: Text('I agree with the terms and conditions'),
                      ),
                    ],
                  ),
                  SizedBox(height: verticalSpacing * 1.5),

                  // Send OTP Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          controller.sendVerificationEmail(controller.emailController.text.trim());
                          Get.toNamed('/verify_otp');
                        }
                      },
                      child: Text('Send OTP'),
                    ),
                  ),
                  SizedBox(height: verticalSpacing),

                  // Already Have an Account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account?'),
                      TextButton(
                        onPressed: () {
                          Get.toNamed('/login');
                        },
                        child: Text('Login'),
                      ),
                    ],
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
