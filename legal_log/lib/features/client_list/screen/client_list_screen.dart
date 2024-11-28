import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _clientFirebaseServices.fetchClients(),
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

          // Retrieve clients from snapshot
          final clients = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Client.fromJson(data); // Convert JSON to Client model
          }).toList();

          return ListView.builder(
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return ClientCard(
                client: client,
                onUpdate: () => _clientFirebaseServices.updateClient(
                    client, client.clientId), // Pass the update method
                onDelete: () => _clientFirebaseServices
                    .deleteClient(client.clientId), // Pass the delete method
              );
            },
          );
        },
      ),
    );
  }
}

class ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback onUpdate; // Update method callback
  final VoidCallback onDelete; // Delete method callback

  const ClientCard(
      {super.key,
      required this.client,
      required this.onUpdate,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Client ID: ${client.clientId ?? "N/A"}", // Corrected from legalCase to client
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Name: ${client.name ?? "N/A"}"), // Corrected to client
            Text("Email: ${client.email ?? "N/A"}"), // Corrected to client
            Text("Phone No: ${client.phoneNo ?? "N/A"}"), // Corrected to client
            Text("Address: ${client.address ?? "N/A"}"), // Corrected to client
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  color: Colors.green,
                  onPressed: onUpdate, // Trigger update when pressed
                  tooltip: 'Update Client',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: onDelete, // Trigger delete when pressed
                  tooltip: 'Delete Client',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
