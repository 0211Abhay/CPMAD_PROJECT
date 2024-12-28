class CaseNote {
  final String note;
  final String date;
  final String userId; // Advocate ID
  final String caseId; // Case ID

  CaseNote({
    required this.note,
    required this.date,
    required this.userId,
    required this.caseId,
  });

  // Convert Firestore document to CaseNote object
  factory CaseNote.fromDocument(Map<String, dynamic> doc) {
    return CaseNote(
      note: doc['note'] ?? '',
      date: doc['date'] ?? '',
      userId: doc['userId'] ?? '',
      caseId: doc['caseId'] ?? '',
    );
  }
}
