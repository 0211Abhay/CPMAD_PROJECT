import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Authentication Features
import 'package:legal_log/features/authentication/controller/login_controller.dart';
import 'package:legal_log/features/authentication/screens/add_profilepicture.dart';
import 'package:legal_log/features/authentication/screens/login_screen.dart';
import 'package:legal_log/features/authentication/screens/otp_screen.dart';
import 'package:legal_log/features/authentication/screens/registration_screen.dart';

// Home and Settings Features
import 'package:legal_log/features/home_page/screens/home_page.dart';
import 'package:legal_log/features/settings/screens/setting_screen.dart';

// Client Features
import 'package:legal_log/features/client_add/screen/client_add.dart';
import 'package:legal_log/features/client_add/screen/client_edit.dart';

// Case Features
import 'package:legal_log/features/case_add/screen/case_add.dart';
import 'package:legal_log/features/case_add/screen/case_update.dart';

// File and Drive Integration
import 'package:legal_log/features/file_upload/firebase_fileupload.dart';
import 'package:legal_log/features/future_scope/drive_integration/drive.dart';

// Splash Screen
import 'package:legal_log/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Registering the LoginController with GetX
  Get.put(LoginController());

  runApp(const MyApp());
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
      home: SplashScreen(),
      routes: {
        // Authentication Routes
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegistrationScreen(),
        '/verify_otp': (context) => OtpVerificationScreen(),
        '/add_profilepage': (context) => AddProfilepicture(),

        // Home and Settings
        '/home_page': (context) => HomeScreen(),
        '/settings': (context) => SettingScreen(),

        // Client Routes
        '/client_add': (context) => ClientRegistrationScreen(),
        '/client_update': (context) => ClientUpdateScreen(),

        // Case Routes
        '/case_add': (context) => CaseRegistrationScreen(),
        '/case_update': (context) => CaseUpdateScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/file_upload') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => UploadFileScreen(caseId: args['caseId']),
          );
        }
        if (settings.name == '/drive') {
          return MaterialPageRoute(builder: (context) => DriveScreen());
        }
        return null;
      },
    );
  }
}
