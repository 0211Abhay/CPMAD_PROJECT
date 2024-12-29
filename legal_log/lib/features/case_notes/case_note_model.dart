import 'package:cloud_firestore/cloud_firestore.dart';

class CaseNote {
  final String note;
  final DateTime timestamp; // Change to DateTime
  final String userId; // Advocate ID
  final String caseId; // Case ID

  CaseNote({
    required this.note,
    required this.timestamp,
    required this.userId,
    required this.caseId,
  });

  // Convert Firestore document to CaseNote object
  factory CaseNote.fromDocument(Map<String, dynamic> doc) {
    return CaseNote(
      note: doc['note'] ?? '',
      timestamp:
          (doc['timestamp'] as Timestamp).toDate(), // Convert to DateTime
      userId: doc['userId'] ?? '',
      caseId: doc['caseId'] ?? '',
    );
  }

  // Add the fromFirestore method
  factory CaseNote.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CaseNote(
      note: data['note'] ?? '',
      timestamp:
          (data['timestamp'] as Timestamp).toDate(), // Convert to DateTime
      userId: data['userId'] ?? '',
      caseId: data['caseId'] ?? '',
    );
  }
}
