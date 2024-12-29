import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legal_log/common_widgets/drawer.dart';
import 'package:legal_log/features/authentication/controller/login_controller.dart';
import 'package:legal_log/features/calendar/screen/calender_screen.dart';
import 'package:legal_log/features/case_list/screen/case_list_screen.dart';
import 'package:legal_log/features/client_list/screen/client_list_screen.dart';
import 'package:legal_log/features/home_page/controller/home_screen_controller.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final LoginController loginController =
      Get.put(LoginController()); // Get the LoginController instance
  final HomeScreenController homeScreenController =
      Get.put(HomeScreenController()); // Get the HomeScreenController instance

  final List<Widget> screens = [
    const CaseListScreen(),
    CalendarScreen(),
    const ClientListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal Log'),
      ),
      drawer: CustomDrawer(), // Use the new CustomDrawer widget here
      body: Obx(
        () => IndexedStack(
          index: homeScreenController.curBottomNavIndex.value,
          children: screens,
        ),
      ),
      bottomNavigationBar: Obx(
        () => AnimatedBottomNavigationBar.builder(
          backgroundColor: Colors.white,
          itemCount: homeScreenController.iconList.length,
          activeIndex: homeScreenController.curBottomNavIndex.value,
          onTap: (index) {
            homeScreenController.curBottomNavIndex.value = index;
          },
          splashSpeedInMilliseconds: 300,
          notchSmoothness: NotchSmoothness.defaultEdge,
          gapLocation: GapLocation.none, // No central gap
          tabBuilder: (int index, bool isActive) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16), // Add spacing
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center icon and text vertically
                children: [
                  Icon(
                    homeScreenController.iconList[index][0],
                    size: 24,
                    color: isActive ? Colors.deepPurple : Colors.grey[800],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    homeScreenController.iconList[index][1],
                    style: TextStyle(
                      color: isActive ? Colors.deepPurple : Colors.grey[800],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
