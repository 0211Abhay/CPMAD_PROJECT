import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legal_log/common_widgets/custom_text_fields.dart';
import 'package:legal_log/features/authentication/controller/login_controller.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>(); // Form key
  final LoginController loginController = Get.put(LoginController()); // Controller

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.02,
          ),
          child: Form( // Form widget to handle validation
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Lottie.asset(
                  "assets/lottie/hammer.json",
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: screenHeight * 0.02),

                const Text(
                  'Legal Log',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: screenHeight * 0.02),

                const Text(
                  'Login',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: screenHeight * 0.01),

                const Text('Enter your username and password to login'),
                SizedBox(height: screenHeight * 0.02),

                // Email Field
                CustomTextField(
                  label: 'Email',
                  controller: emailController,
                  validator: loginController.validateEmail,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                SizedBox(height: screenHeight * 0.02),

                // Password Field with Obx
                Obx(() => CustomTextField(
                      label: 'Password',
                      controller: passwordController,
                      obscureText: loginController.obscurePassword.value,
                      validator: loginController.validatePassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(loginController.obscurePassword.value
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: loginController.togglePasswordVisibility,
                      ),
                    )),

                SizedBox(height: screenHeight * 0.02),

                ElevatedButton(
                  onPressed: () {
                    // Validate the form fields
                    if (formKey.currentState!.validate()) {
                      // Navigate to dashboard if valid
                      Get.toNamed('/dashboard');
                    }
                  },
                  child: const Text('Login'),
                ),

                SizedBox(height: screenHeight * 0.02),
                const Text('Or login with'),
                SizedBox(height: screenHeight * 0.01),

                // Social Login Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Implement Google login
                      },
                      icon: const Icon(Icons.g_mobiledata),
                      label: const Text('Google'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Implement Facebook login
                      },
                      icon: const Icon(Icons.facebook),
                      label: const Text('Facebook'),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Get.toNamed('/register'); // Navigate to registration
                      },
                      child: const Text('Register'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
