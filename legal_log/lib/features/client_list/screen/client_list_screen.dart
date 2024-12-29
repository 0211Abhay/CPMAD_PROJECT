import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:legal_log/features/client_add/controller/client_add_controller.dart';
import 'package:legal_log/features/client_add/model/client.dart';
import 'package:legal_log/features/client_add/services/client_firebase_services.dart';
import 'package:legal_log/features/case_notes/client_details.dart';

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
                  onTap: () {
                    // Navigate to ClientDetailScreen using Get
                    Get.to(
                        () => ClientDetailScreen(clientDocId: client.docId!));
                  },
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
  final VoidCallback onTap;

  const ClientCard({
    super.key,
    required this.client,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        child: Card(
          margin: const EdgeInsets.all(8.0),
          elevation: 6.0, // Higher elevation for a more prominent look
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Client ID Text
                Text(
                  "Client ID: ${client.clientId}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // White text for better contrast
                  ),
                ),
                const Divider(
                    thickness: 1.0, height: 20.0), // Divider between sections

                // Client Details
                _buildDetail("Name", client.name),
                _buildDetail("Email", client.email),
                _buildDetail("Phone No", client.phoneNo),
                _buildDetail("Address", client.address),

                const SizedBox(height: 8),

                // Action Buttons (if required in the future)
                // You can add action buttons below if you wish to provide more functionality
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to create a row with label and value
  Widget _buildDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            _getIconForLabel(label),
            color: Colors.blueGrey, // Slightly transparent white for icons
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label: $value",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black, // Consistent white text for readability
              ),
              overflow: TextOverflow.ellipsis, // Handles overflow text
            ),
          ),
        ],
      ),
    );
  }

  // Method to return appropriate icon for each label
  IconData _getIconForLabel(String label) {
    switch (label) {
      case "Name":
        return Icons.person;
      case "Email":
        return Icons.email;
      case "Phone No":
        return Icons.phone;
      case "Address":
        return Icons.location_on;
      default:
        return Icons.info;
    }
  }
}
