import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legal_log/features/authentication/controller/login_controller.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final LoginController loginController = Get.find<LoginController>(); // Get the LoginController instance

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Call the logout function when the button is pressed
              loginController.logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("This is the Home Screen"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Call the logout function when the button is pressed
                loginController.logout();
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
