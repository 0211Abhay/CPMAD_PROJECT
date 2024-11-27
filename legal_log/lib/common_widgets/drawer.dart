import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legal_log/features/authentication/controller/login_controller.dart';
import 'package:legal_log/features/home_page/controller/home_screen_controller.dart';

class CustomDrawer extends StatelessWidget {
  final HomeScreenController homeController = Get.find<HomeScreenController>();
  final LoginController logincontroller = Get.find<LoginController>();
  CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey,
              image: DecorationImage(
                image: AssetImage('assets/images/header.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/profile.jpg'),
                ),
                const SizedBox(height: 10),
                const Text(
                  'User Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 3,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => Row(
                      children: [
                        Icon(
                          Icons.location_on, // Location icon
                          color: Colors.white,
                          size: 24,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                        const SizedBox(width: 8), // Space between icon and text
                        Expanded(
                          child: Text(
                            homeController.location
                                .value, // Dynamically updates the value
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              shadows: [
                                Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 3,
                                  color: Colors.black45,
                                ),
                              ],
                            ),
                            overflow: TextOverflow
                                .ellipsis, // Handle long text gracefully
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.home,
              size: 24,
              color: Colors.grey,
            ),
            title: const Text('Home'),
            onTap: () => Get.offNamed('/home'),
          ),
          ListTile(
            leading: Icon(
              Icons.add_box,
              size: 24,
              color: Colors.grey,
            ),
            title: const Text('Add Case'),
            onTap: () => Get.offNamed('/case_add'),
          ),
          ListTile(
            leading: Icon(
              Icons.person_add,
              size: 24,
              color: Colors.grey,
            ),
            title: const Text('Add Client'),
            onTap: () => Get.offNamed('/client_add'),
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              size: 24,
              color: Colors.grey,
            ),
            title: const Text('Settings'),
            onTap: () => Get.offNamed('/settings'),
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
              size: 24,
              color: Colors.grey,
            ),
            title: const Text('Log Out'),
            onTap: () => logincontroller.logout(),
          ),
        ],
      ),
    );
  }
}
