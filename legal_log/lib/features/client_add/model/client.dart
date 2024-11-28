class Client {
  // Properties
  String? docId;  // Firestore document ID (hidden for internal use)
  final String name;
  final String address;
  final String phoneNo;
  final String email;
  final String clientId; // Unique client identifier (visible to the user)
  final List<String> caseNos;

  // Constructor with required fields
  Client({
    this.docId,  // Document ID can be null as it's not passed in the constructor
    required this.name,
    required this.address,
    required this.phoneNo,
    required this.email,
    required this.clientId,
    this.caseNos = const [],
  });

  // Convert the object to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Address': address,
      'Phone_No': phoneNo,
      'Email': email,
      'Client_ID': clientId,
      'Case_Nos': caseNos,
    };
  }

  // Create an object from Firestore JSON data
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      docId: json['docId'],  // docId comes from Firestore (used internally)
      name: json['Name'] as String,
      address: json['Address'] as String,
      phoneNo: json['Phone_No'] as String,
      email: json['Email'] as String,
      clientId: json['Client_ID'] as String,
      caseNos: List<String>.from(json['Case_Nos'] ?? []),
    );
  }
}
