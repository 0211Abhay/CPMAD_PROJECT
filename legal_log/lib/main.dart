import 'package:flutter/material.dart';
import 'package:legal_log/screens/homeScreen.dart';
import 'package:legal_log/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,).then((value){
    print('Firebase app initialized successfully');
  });
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
    routes: {
      '/home': (context) => Homescreen(), // Define your home screen here
    },
  ));
}
