import 'package:get/get.dart';
import 'package:legal_log/features/case_add/screen/case_update.dart';
import 'package:legal_log/features/client_add/screen/client_edit.dart';
import 'package:legal_log/features/drive_integration/drive.dart';
import 'package:legal_log/features/settings/screens/setting_screen.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:legal_log/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:legal_log/features/case_add/screen/case_add.dart';
import 'package:legal_log/features/home_page/screens/home_page.dart';
import 'package:legal_log/features/client_add/screen/client_add.dart';
import 'package:legal_log/features/authentication/screens/otp_screen.dart';
import 'package:legal_log/features/authentication/screens/login_screen.dart';
import 'package:legal_log/features/authentication/screens/add_profilepicture.dart';
import 'package:legal_log/features/authentication/controller/login_controller.dart';
import 'package:legal_log/features/authentication/screens/registration_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .then((value) {});
  Get.put(LoginController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Legal Log',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // This will display the splash screen first
      routes: {
        // Define home route for easier navigation
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegistrationScreen(),
        '/client_add': (context) => ClientRegistrationScreen(),
        '/case_add': (context) => CaseRegistrationScreen(),
        '/add_profilepage': (context) => AddProfilepicture(),
        '/home_page': (context) => HomeScreen(),
        "/verify_otp": (context) => OtpVerificationScreen(),
        '/settings': (context) => SettingScreen(),
        '/client_update': (context) => ClientUpdateScreen(),

        "/drive" : (context) => DriveScreen(),

        '/case_update': (context) => CaseUpdateScreen(),

      },
    );
  }
}
