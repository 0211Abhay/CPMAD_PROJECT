import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, // Adjust padding relative to screen width
            vertical: screenHeight * 0.02, // Adjust vertical padding
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Lottie.asset(
                "assets/lottie/hammer.json",
                width: 200, // Adjust the width
                height: 200, // Adjust the height
                fit: BoxFit.contain, // Ensure it fits within its bounds
              ),

              SizedBox(height: screenHeight * 0.02), // Responsive spacing

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

              // Username Field
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Forgot Username?'),
                  TextButton(
                    onPressed: () {
                      // Implement forgot username functionality
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.01),

              // Password Field
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Forgot Password?'),
                  TextButton(
                    onPressed: () {
                      // Implement forgot password functionality
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.02),

              // Login Button
              ElevatedButton(
                onPressed: () {
                  // Implement login logic using GetX
                  Get.toNamed('/dashboard'); // Navigate to dashboard on successful login
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
                      Get.toNamed('/register'); // Navigate to registration screen
                    },
                    child: const Text('Register'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
