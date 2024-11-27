import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legal_log/common_widgets/custom_text_fields.dart';
import 'package:legal_log/common_widgets/show_loader.dart';
import 'package:legal_log/features/authentication/controller/login_controller.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>(); // Form key
  final LoginController loginController =
      Get.put(LoginController()); // Controller

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
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: screenWidth * 0.9,
                maxHeight: screenHeight * 0.9,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/logo-removebg-preview.png',
                      width: screenWidth * 0.5,
                      height: screenHeight * 0.25,
                      fit: BoxFit.contain,
                    ),

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

                    SizedBox(
                      height: 50, // Set appropriate height for the box
                      width: double.infinity, // Adjust width as per your layout
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            showLottieDialog(
                              animationPath: 'assets/lottie/hammer.json', // Path to your Lottie loader animation
                              message: 'Logging in, please wait...',
                            );
                            // Attempt login
                            await loginController.loginUser(
                              emailController.text.trim(),
                              passwordController.text.trim(),
                            );
                          }
                        },
                        child: const Text('Login'),
                      ),
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
                            Get.toNamed(
                                '/register'); // Navigate to registration
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
        ),
      ),
    );
  }
}
