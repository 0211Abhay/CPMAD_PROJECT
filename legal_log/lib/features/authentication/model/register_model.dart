class Advocate {
  final String advocateId;
  final String emailAddress;
  final String name;
  final String password; // Consider not using plaintext passwords in production
  final String phoneNo;

  Advocate({
    required this.advocateId,
    required this.emailAddress,
    required this.name,
    required this.password,
    required this.phoneNo,
  });

  // Convert Advocate object to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'advocate_id': advocateId,
      'email_address': emailAddress,
      'name': name,
      'password': password,
      'phone_no': phoneNo,
    };
  }

  // Create Advocate object from Firestore document
  factory Advocate.fromMap(Map<String, dynamic> map) {
    return Advocate(
      advocateId: map['advocate_id'] ?? '',
      emailAddress: map['email_address'] ?? '',
      name: map['name'] ?? '',
      password: map['password'] ?? '',
      phoneNo: map['phone_no'] ?? '',
    );
  }
}
