import 'package:flutter/material.dart';
import 'package:legal_log/features/authentication/screens/homeScreen.dart';
import 'package:legal_log/features/authentication/screens/login_screen.dart';
import 'package:legal_log/features/authentication/screens/registration_screen.dart';
import 'package:legal_log/features/authentication/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform).then((value){
    print('Firebase app initialized successfully');
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Legal Log',
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),  // This will display the splash screen first
      routes: {
        '/home': (context) => Homescreen(), // Define home route for easier navigation
        '/login': (context) => LoginScreen(), 
        '/register': (context) => RegistrationScreen(),
        
      },
    );
  }
}
