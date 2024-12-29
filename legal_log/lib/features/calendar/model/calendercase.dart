class Calendercase {
  String? docId; // Firestore document ID (hidden for internal use)
  final String fileNo;
  final String caseNo;
  final String ourClient;
  final String court;
  final String judge;
  final DateTime startTime; // New property
  final DateTime endTime; // New property

  Calendercase({
    this.docId,
    required this.fileNo,
    required this.caseNo,
    required this.ourClient,
    required this.court,
    required this.judge,
    required this.startTime, // Required for calendar events
    required this.endTime, // Required for calendar events
  });

  // Convert the object to JSON
  Map<String, dynamic> toJson() {
    return {
      'File_No': fileNo,
      'Case_No': caseNo,
      'Our_Client': ourClient,
      'Court': court,
      'Judge': judge,
      'StartTime': startTime.toIso8601String(),
      'EndTime': endTime.toIso8601String(),
    };
  }

  // Create an object from JSON
  factory Calendercase.fromJson(Map<String, dynamic> json) {
    return Calendercase(
      docId: json['docId'],
      fileNo: json['File_No'] as String,
      caseNo: json['Case_No'] as String,
      ourClient: json['Our_Client'] as String,
      court: json['Court'] as String,
      judge: json['Judge'] as String,
      startTime: DateTime.parse(json['StartTime']),
      endTime: DateTime.parse(json['EndTime']),
    );
  }
}
