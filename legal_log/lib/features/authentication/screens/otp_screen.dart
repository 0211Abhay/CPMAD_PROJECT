import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/registration_controller.dart';

class OtpVerificationScreen extends StatelessWidget {
  final RegistrationController controller = Get.find();

  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OTP Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Enter the OTP sent to your email'),
            TextField(
              controller: otpController,
              decoration: InputDecoration(
                labelText: 'OTP',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                controller.verifyOtp(int.parse(otpController.text));
              },
              child: Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
