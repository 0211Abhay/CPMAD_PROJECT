import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

class HomeScreenController extends GetxController {
  var curBottomNavIndex = 0.obs;

  List<List<dynamic>> iconList = [
    [Icons.file_copy, "Case"],
    [Icons.calendar_month, "Calender"],
    [Icons.person, "Client"],
  ];

  var location = ''.obs; // Observable string for location
}
