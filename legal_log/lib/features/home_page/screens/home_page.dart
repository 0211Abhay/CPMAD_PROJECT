import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:legal_log/common_widgets/drawer.dart';
import 'package:legal_log/features/authentication/controller/login_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

      final LoginController loginController =
      Get.find<LoginController>(); // Get the LoginController instance
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal Log'),
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
      drawer: CustomDrawer(), // Use the new CustomDrawer widget here
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
