import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:legal_log/features/authentication/model/register_model.dart';

class RegistrationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Registers a new advocate
  Future<void> registerAdvocate(Advocate advocate) async {
    try {
      // Create user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: advocate.emailAddress,
        password: advocate.password,
      );

      // Get the user's UID
      String uid = userCredential.user!.uid;

      // Save advocate details to Firestore
      await _firestore.collection('advocate').doc(uid).set(advocate.toMap());
    } catch (e) {
      throw Exception('Failed to register advocate: $e');
    }
  }
}
