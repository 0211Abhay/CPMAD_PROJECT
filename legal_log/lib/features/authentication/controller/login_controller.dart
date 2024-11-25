import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  var obscurePassword = true.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();
  
  // Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // Validate email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Login user
  Future<void> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user data from Firestore
      QuerySnapshot querySnapshot = await _firestore
          .collection('advocate') // The collection name in Firestore
          .where('email_address', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming the first document matches
        var userData = querySnapshot.docs.first.data();
        _storage.write('user', userData); // Store user data locally
        Get.toNamed('/home_page');
      } else {
        Get.snackbar('Error', 'User data not found in Firestore');
      }
    } catch (e) {
      Get.snackbar('Login Error', e.toString());
    }
  }

  // Logout user
  Future<void> logout() async {
    await _auth.signOut();
    _storage.erase(); // Clear locally stored data
    Get.offAllNamed('/login');
  }
}
