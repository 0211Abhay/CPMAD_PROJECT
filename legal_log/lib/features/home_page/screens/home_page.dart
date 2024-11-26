import 'package:flutter/material.dart';
import 'package:legal_log/common_widgets/drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal Log'),
      ),
      drawer: const CustomDrawer(), // Use the new CustomDrawer widget here
      body: Center(
        child: const Text('This is A Home Screen.'),
      ),
    );
  }
}
