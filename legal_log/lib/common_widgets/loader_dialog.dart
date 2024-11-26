import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// A reusable widget for showing Lottie animations in a dialog.
class CommonLottieDialog extends StatelessWidget {
  final String animationPath; // Path to the Lottie animation asset
  final String message; // Message to display below the animation
  final double width; // Width of the dialog (optional)
  final double height; // Height of the dialog (optional)
  final TextStyle? textStyle; // Customizable text style for the message

  const CommonLottieDialog({
    Key? key,
    required this.animationPath,
    required this.message,
    this.width = 200.0,
    this.height = 200.0,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        width: width,
        height: height + 50,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              animationPath,
              width: width * 0.8,
              height: height * 0.8,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textStyle ??
                  const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
