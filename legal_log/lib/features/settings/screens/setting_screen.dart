import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Ensure you import GetX package

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removed `const` here
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.toNamed("/home_page"); // Navigate to the home page
          },
          icon: const Icon(Icons.arrow_back), // Icon can remain const
        ),
        title: const Text('Client Registration'), // Title can remain const
      ),
      body: const Center(
        child: Text("This is a Setting Screen"), // Text can remain const
      ),
    );
  }
}
