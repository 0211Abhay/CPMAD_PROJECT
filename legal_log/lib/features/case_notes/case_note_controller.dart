import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:legal_log/features/case_notes/case_note_model.dart';

class CaseNoteController extends GetxController {
  var notes = <CaseNote>[].obs;

  // Method to fetch notes from Firestore
  Future<void> fetchCaseNotes(String advocateId, String caseId) async {
    try {
      // Fetch notes for the given advocateId and caseId
      var querySnapshot = await FirebaseFirestore.instance
          .collection('case_notes')
          .where('userId', isEqualTo: advocateId)
          .where('caseId', isEqualTo: caseId)
          .orderBy('date', descending: true)
          .get();

      notes.clear();
      for (var doc in querySnapshot.docs) {
        notes.add(CaseNote.fromDocument(doc.data()));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch notes: ${e.toString()}');
    }
  }
}
