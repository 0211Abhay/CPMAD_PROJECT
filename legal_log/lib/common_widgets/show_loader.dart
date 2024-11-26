import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legal_log/common_widgets/loader_dialog.dart';


void showLottieDialog({
  required String animationPath,
  required String message,
  bool barrierDismissible = false,
  bool autoClose = false,
  int durationSeconds = 2,
}) {
  Get.dialog(
    CommonLottieDialog(
      animationPath: animationPath,
      message: message,
    ),
    barrierDismissible: barrierDismissible,
  );

  if (autoClose) {
    Future.delayed(Duration(seconds: durationSeconds), () => Get.back());
  }
}
