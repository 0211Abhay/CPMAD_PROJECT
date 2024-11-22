import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:legal_log/features/case_add/model/case.dart'; // Adjust import path as needed

class CaseFirebaseServices {
  var db = FirebaseFirestore.instance;

  // Create - Add a new legal case 
  addCase(Case legalCase) {
    final legalCaseData =
        legalCase.toJson();

    // Add a new document with a generated ID
    db.collection("case").add(legalCaseData).then((DocumentReference doc) =>
        // ignore: avoid_print
        print("Legal case added with ID: ${doc.id}"));
  }

  // Read - Fetch all legal cases
  Stream<QuerySnapshot> fetchLegalCases() {
    Stream<QuerySnapshot> collectionStream =
        FirebaseFirestore.instance.collection('cases').snapshots();
    return collectionStream;
  }

  // Update a legal case
  updateCase(Case legalCase, String documentId) {
    return db
        .collection("cases")
        .doc(documentId) // Use the specific document ID passed in
        .update(
            legalCase.toJson()) // Convert LegalCase object to JSON for updating
        // ignore: avoid_print
        .then((value) => print("Legal case updated"))
        // ignore: avoid_print
        .catchError((error) => print("Failed to update legal case: $error"));
  }

  // Delete a legal case by document ID
  deleteLegalCase(String documentId) {
    return db
        .collection("cases")
        .doc(documentId)
        .delete()
        // ignore: avoid_print
        .then((value) => print("Legal case deleted"))
        // ignore: avoid_print
        .catchError((error) => print("Failed to delete legal case: $error"));
  }

  // Fetch a specific legal case by document ID
  Future<Case?> fetchCaseById(String documentId) async {
    try {
      DocumentSnapshot doc = await db.collection("case").doc(documentId).get();

      if (doc.exists) {
        // Convert the document data to a map and then to a LegalCase object
        return Case.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (error) {
      // ignore: avoid_print
      print("Failed to fetch legal case: $error");
      return null;
    }
  }

  // Search legal cases by various fields
  Stream<QuerySnapshot> searchCases({
    String? fileNo,
    String? caseNo,
    String? applicantName,
    String? stage,
    String? court,
  }) {
    Query query = db.collection("case");

    // Add filters if provided
    if (fileNo != null && fileNo.isNotEmpty) {
      query = query.where('File_No', isEqualTo: fileNo);
    }
    if (caseNo != null && caseNo.isNotEmpty) {
      query = query.where('Case_No', isEqualTo: caseNo);
    }
    if (applicantName != null && applicantName.isNotEmpty) {
      query = query.where('Applicant_Name', isEqualTo: applicantName);
    }
    if (stage != null && stage.isNotEmpty) {
      query = query.where('Stage', isEqualTo: stage);
    }
    if (court != null && court.isNotEmpty) {
      query = query.where('Court', isEqualTo: court);
    }

    return query.snapshots();
  }
}
