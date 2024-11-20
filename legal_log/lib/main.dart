import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legal_log/features/authentication/screens/homeScreen.dart';
import 'package:legal_log/features/authentication/screens/login_screen.dart';
import 'package:legal_log/features/authentication/screens/registration_screen.dart';
import 'package:legal_log/features/authentication/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform).then((value) {
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp( // Use GetMaterialApp for GetX
      title: 'Legal Log',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash', // Define the initial route
      getPages: [
        // Define all routes using GetPage
        GetPage(name: '/splash', page: () => SplashScreen()),
        GetPage(name: '/home', page: () => Homescreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegistrationScreen()),
      ],
    );
  }
}
