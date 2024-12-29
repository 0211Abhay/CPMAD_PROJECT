import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const DriveScreen()),
      ],
    );
  }
}

class DriveScreen extends StatefulWidget {
  const DriveScreen({super.key});

  @override
  State<DriveScreen> createState() => _DriveScreenState();
}

class _DriveScreenState extends State<DriveScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/drive.file'],
  );
  String? accessToken;

  Future<void> signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        accessToken = googleAuth.accessToken;
        Get.snackbar('Sign-In Successful', 'You are signed in to Google Drive!',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign in: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        if (accessToken == null) {
          Get.snackbar(
            'Authentication Required',
            'Please sign in to Google Drive first.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        await uploadFileToDrive(file.path, accessToken!);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick or upload file: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> uploadFileToDrive(String filePath, String accessToken) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart'),
      );
      request.headers['Authorization'] = 'Bearer $accessToken';
      request.fields['name'] = 'uploaded_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
      var multipartFile = await http.MultipartFile.fromPath('file', filePath);
      request.files.add(multipartFile);

      var response = await request.send();
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'PDF uploaded successfully!',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        print('Upload failed: ${response.reasonPhrase}'); // Log the error for debugging
        Get.snackbar('Error', 'Upload failed with status code: ${response.statusCode}',
            snackPosition: SnackPosition.BOTTOM);

        // Consider retrying the upload with error handling and exponential backoff
        if (response.statusCode == 400) {
          // Handle specific 400 errors, e.g., invalid file format, size limit, or API quota
          Get.snackbar('Error', 'Bad Request: Please check file format and size.',
              snackPosition: SnackPosition.BOTTOM);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload file: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Drive Integration'),
        backgroundColor: Colors.grey,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: signInWithGoogle,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Sign In with Google'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickPDF,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Pick and Upload PDF'),
            ),
          ],
        ),
      ),
    );
  }
}