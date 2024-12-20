import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:legal_log/features/client_add/controller/client_add_controller.dart';
import 'package:legal_log/features/client_add/model/client.dart';
import 'package:legal_log/features/client_add/services/client_firebase_services.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final ClientFirebaseServices _clientFirebaseServices =
      ClientFirebaseServices();

  final ClientAddController controller = Get.put(ClientAddController());
  late String user_id; // Declare without initialization
  GetStorage storage = GetStorage();
  @override
  void initState() {
    super.initState();
    user_id = storage.read('user')['advocate_id'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _clientFirebaseServices.fetchClientsByID(user_id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error fetching clients"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No clients found"));
          }

          final clients = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Client.fromJson(data)
              ..docId = doc.id; // Store doc.id in the hidden field
          }).toList();

          return ListView.builder(
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return Dismissible(
                key: ValueKey(client.docId), // Use the docId as the key
                background: Container(
                  color: Colors.green,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.edit, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    // Confirmation for delete action
                    final shouldDelete =
                        await _showConfirmationDialog(context, "Delete");
                    if (shouldDelete ?? false) {
                      // Proceed with deletion
                      _clientFirebaseServices.deleteClient(client.docId);
                      return true;
                    }
                    // Cancel the dismissal
                    return false;
                  } else if (direction == DismissDirection.startToEnd) {
                    // Confirmation for update action
                    final shouldUpdate =
                        await _showConfirmationDialog(context, "Update");
                    if (shouldUpdate ?? false) {
                      // Navigate to update screen
                      Get.toNamed('/client_update', arguments: {
                        'client': client,
                        'documentId': client.docId,
                      });
                    }
                    // Cancel the dismissal
                    return false;
                  }
                  return false; // Default case: no dismissal
                },
                onDismissed: (direction) {
                  if (direction == DismissDirection.endToStart) {
                    // This block will execute only after confirmDismiss returns true
                    setState(() {
                      // Remove the client from the local list
                    });
                  }
                },
                child: ClientCard(
                  client: client,
                  width: MediaQuery.of(context).size.width,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<bool?> _showConfirmationDialog(BuildContext context, String action) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action Client'),
        content: Text('Are you sure you want to $action this client?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class ClientCard extends StatelessWidget {
  final Client client;
  final double width;

  const ClientCard({super.key, required this.client, required this.width});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4.0,
      child: Container(
        width: width, // Set width dynamically
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Client ID: ${client.clientId}", // Only display the client information, not docId
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Name: ${client.name}"),
            Text("Email: ${client.email}"),
            Text("Phone No: ${client.phoneNo}"),
            Text("Address: ${client.address}"),
          ],
        ),
      ),
    );
  }
}
