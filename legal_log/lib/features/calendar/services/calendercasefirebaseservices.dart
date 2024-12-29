import 'package:cloud_firestore/cloud_firestore.dart';

class Calendercasefirebaseservices {
  var db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchCasesForToday() async {
    DateTime today = DateTime.now();
    String todayDateString =
        today.toIso8601String().split('T')[0]; // Get only date part

    QuerySnapshot querySnapshot = await db
        .collection('case_history') // Replace with your collection name
        .where('next_date', isEqualTo: todayDateString)
        .get();

    List<Map<String, dynamic>> cases = [];

    for (DocumentSnapshot document in querySnapshot.docs) {
      cases.add(document.data() as Map<String, dynamic>);
    }

    return cases;
  }
}
