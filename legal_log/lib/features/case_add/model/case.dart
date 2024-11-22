class Case {
  // Properties
  final String fileNo;
  final String caseNo;
  final String applicantName;
  final String opponentName;
  final String ourClientName;
  final DateTime dateOfFiling;
  final String stage;
  final DateTime previousDate;
  final String area;
  final String court;
  final String caseNote;

  // Constructor with required fields
  Case({
    required this.fileNo,
    required this.caseNo,
    required this.applicantName,
    required this.opponentName,
    required this.ourClientName,
    required this.dateOfFiling,
    required this.stage,
    required this.previousDate,
    required this.area,
    required this.court,
    required this.caseNote,
  });

  // Convert the object to JSON
  Map<String, dynamic> toJson() {
    return {
      'File_No': fileNo,
      'Case_No': caseNo,
      'Applicant_Name': applicantName,
      'Opponent_Name': opponentName,
      'Our_Client_Name': ourClientName,
      'Date_of_Filing': dateOfFiling.toIso8601String(),
      'Stage': stage,
      'Previous_Date': previousDate.toIso8601String(),
      'Area': area,
      'Court': court,
      'Case_Note': caseNote,
    };
  }

  // Create an object from JSON
  factory Case.fromJson(Map<String, dynamic> json) {
    return Case(
      fileNo: json['File_No'] as String,
      caseNo: json['Case_No'] as String,
      applicantName: json['Applicant_Name'] as String,
      opponentName: json['Opponent_Name'] as String,
      ourClientName: json['Our_Client_Name'] as String,
      dateOfFiling: DateTime.parse(json['Date_of_Filing']),
      stage: json['Stage'] as String,
      previousDate: DateTime.parse(json['Previous_Date']),
      area: json['Area'] as String,
      court: json['Court'] as String,
      caseNote: json['Case_Note'] as String,
    );
  }
}
