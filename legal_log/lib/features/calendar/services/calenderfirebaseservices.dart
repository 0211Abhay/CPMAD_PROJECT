import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';

class CalendarCaseFirebaseServices {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final GetStorage storage = GetStorage();
  Future<List<Map<String, dynamic>>> fetchCasesForToday(DateTime date) async {
    // Get the start and end of the day
    DateTime startOfDay = DateTime(date.year, date.month, date.day).toUtc();
    DateTime endOfDay = startOfDay.add(Duration(days: 1)).toUtc();

    // Fetch the advocate_id from storage
    var user = storage.read('user');
    var advocateId = user != null ? user['advocate_id'] : null;

    print("Current advocate_id: $advocateId");

    try {
      QuerySnapshot querySnapshot = await db
          .collection('case_history') // Replace with your collection name
          .where('next_date', isGreaterThanOrEqualTo: startOfDay)
          .where('next_date', isLessThan: endOfDay)
          .where('advocate_id', isEqualTo: advocateId)
          .get();

      List<Map<String, dynamic>> cases = querySnapshot.docs.map((document) {
        return document.data() as Map<String, dynamic>;
      }).toList();

      // Print the cases before returning
      print("Fetched cases for date ${startOfDay.toIso8601String()}: $cases");

      return cases;
    } catch (e) {
      print("Error fetching cases: $e");
      return []; // Return an empty list in case of error
    }
  }
}
