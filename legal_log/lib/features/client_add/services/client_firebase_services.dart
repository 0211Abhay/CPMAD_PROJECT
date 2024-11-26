import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:legal_log/features/client_add/model/client.dart'; // Adjust import path as needed

class ClientFirebaseServices {
  var db = FirebaseFirestore.instance;

  // Create - Add a new client
  addClient(Client client) {
    final clientData = client.toJson();

    // Add a new document with a generated ID
    db.collection("clients").add(clientData).then((DocumentReference doc) =>
        // ignore: avoid_print
        print("Client added with ID: ${doc.id}"));
  }

  // Read - Fetch all clients
  Stream<QuerySnapshot> fetchClients() {
    return db.collection('clients').snapshots();
  }

  // Update a client
  updateClient(Client client, String documentId) {
    return db
        .collection("clients")
        .doc(documentId) // Use the specific document ID passed in
        .update(client.toJson()) // Convert Client object to JSON for updating
        // ignore: avoid_print
        .then((value) => print("Client updated"))
        // ignore: avoid_print
        .catchError((error) => print("Failed to update client: $error"));
  }

  // Delete a client by document ID
  deleteClient(String documentId) {
    return db
        .collection("clients")
        .doc(documentId)
        .delete()
        // ignore: avoid_print
        .then((value) => print("Client deleted"))
        // ignore: avoid_print
        .catchError((error) => print("Failed to delete client: $error"));
  }

  // Fetch a specific client by document ID
  Future<Client?> fetchClientById(String documentId) async {
    try {
      DocumentSnapshot doc =
          await db.collection("clients").doc(documentId).get();

      if (doc.exists) {
        // Convert the document data to a map and then to a Client object
        return Client.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (error) {
      // ignore: avoid_print
      print("Failed to fetch client: $error");
      return null;
    }
  }

  // Search clients by various fields
  Stream<QuerySnapshot> searchClients({
    String? name,
    String? phoneNo,
    String? email,
    String? caseNo,
  }) {
    Query query = db.collection("clients");

    // Add filters if provided
    if (name != null && name.isNotEmpty) {
      query = query.where('Name', isEqualTo: name);
    }
    if (phoneNo != null && phoneNo.isNotEmpty) {
      query = query.where('Phone_No', isEqualTo: phoneNo);
    }
    if (email != null && email.isNotEmpty) {
      query = query.where('Email', isEqualTo: email);
    }
    if (caseNo != null && caseNo.isNotEmpty) {
      query = query.where('Case_Nos', arrayContains: caseNo);
    }

    return query.snapshots();
  }
}
