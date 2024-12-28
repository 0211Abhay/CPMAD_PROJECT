class Case {
  // Properties
  final String advocate_id;
  String? docId; // Firestore document ID (hidden for internal use)
  final String fileNo;
  final String caseNo;
  final String applicantName;
  final List<String?> otherApplicant;
  final String opponentName;
  final List<String?> otherOpponent;
  final String ourClient;
  final String area;
  final String court;
  final String judge;
  final List<String> ourAdvocates;
  final List<String> opponentAdvocates;
  final DateTime dateOfFiling;
  final String stage;
  final String? note;

  // Constructor with required fields
  Case({
    required this.advocate_id,
    this.docId,
    required this.fileNo,
    required this.caseNo,
    required this.applicantName,
    this.otherApplicant = const [],
    required this.opponentName,
    this.otherOpponent = const [],
    required this.ourClient,
    required this.area,
    required this.court,
    required this.judge,
    this.ourAdvocates = const [],
    this.opponentAdvocates = const [],
    required this.dateOfFiling,
    required this.stage,
    required this.note,
  });

  // Convert the object to JSON
  Map<String, dynamic> toJson() {
    return {
      'advocate_id': advocate_id,
      'File_No': fileNo,
      'Case_No': caseNo,
      'Applicant_Name': applicantName,
      'Other_Applicant': otherApplicant,
      'Opponent_Name': opponentName,
      'Other_Opponent': otherOpponent,
      'Our_Client': ourClient,
      'Area': area,
      'Court': court,
      'Judge': judge,
      'Our_Advocates': ourAdvocates,
      'Opponent_Advocates': opponentAdvocates,
      'Date_of_Filing':
          DateTime(dateOfFiling.year, dateOfFiling.month, dateOfFiling.day)
              .toIso8601String(), // Ensures only the date is stored
      'Stage': stage,
      'Note': note,
    };
  }

  // Create an object from JSON
  factory Case.fromJson(Map<String, dynamic> json) {
    // Parse date and strip time if present
    final dateTime = DateTime.parse(json['Date_of_Filing']);
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);

    return Case(
      advocate_id: json['advocate_id'] as String,
      docId: json[
          'docId'], // docId comes from Firestore (used internally) // Assuming 'Case_No' is the primary key
      fileNo: json['File_No'] as String,
      caseNo: json['Case_No'] as String,
      applicantName: json['Applicant_Name'] as String,
      otherApplicant: List<String>.from(json['Other_Applicant'] ?? []),
      opponentName: json['Opponent_Name'] as String,
      otherOpponent: List<String>.from(json['Other_Opponent'] ?? []),
      ourClient: json['Our_Client'] as String,
      area: json['Area'] as String,
      court: json['Court'] as String,
      judge: json['Judge'] as String,
      ourAdvocates: List<String>.from(json['Our_Advocates'] ?? []),
      opponentAdvocates: List<String>.from(json['Opponent_Advocates'] ?? []),
      dateOfFiling: dateOnly, // Store only the date part
      stage: json['Stage'] as String,
      note: json['Note'] as String,
    );
  }
}
