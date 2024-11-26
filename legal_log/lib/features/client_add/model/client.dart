class Client {
  // Properties
  final String name;
  final String address;
  final String phoneNo;
  final String email;
  final String clientId;
  final List<String> caseNos;

  // Constructor with required fields
  Client({
    required this.name,
    required this.address,
    required this.phoneNo,
    required this.email,
    required this.clientId,
    this.caseNos = const [],
  });

  // Convert the object to JSON
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

  // Create an object from JSON
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      name: json['Name'] as String,
      address: json['Address'] as String,
      phoneNo: json['Phone_No'] as String,
      email: json['Email'] as String,
      clientId: json['Client_ID'] as String,
      caseNos: List<String>.from(json['Case_Nos'] ?? []),
    );
  }
}
