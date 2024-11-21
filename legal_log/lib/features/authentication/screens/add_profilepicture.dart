import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddProfilepicture extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Legal Log'),
        leading: Icon(Icons.arrow_back),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Register',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), 
            ),
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              child: Icon(Icons.person,size: 85,color: Colors.white,),
              backgroundColor: Colors.blueGrey[100],
            ),
            SizedBox(height: 20),
            Text('Take photo with camera'),
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              child: Icon(Icons.upload_file,size: 85,color: Colors.white,),
              backgroundColor: Colors.blueGrey[100],

            ),
            SizedBox(height: 20),
            Text('Upload Photo from your phone'),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Get.toNamed('home_page');
                  },
                  child: Text('Upload'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Get.toNamed('home_page');
                  },
                  child: Text('Skip'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}