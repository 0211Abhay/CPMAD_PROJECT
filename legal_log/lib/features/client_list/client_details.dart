import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:legal_log/features/client_add/model/client.dart';

class ClientDetailScreen extends StatefulWidget {
  final String clientDocId; // Firestore document ID of the client

  const ClientDetailScreen({required this.clientDocId, Key? key}) : super(key: key);

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  Client? client;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchClientDetails();
  }

  Future<void> fetchClientDetails() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('client')
          .doc(widget.clientDocId)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          client = Client.fromJson(docSnapshot.data() as Map<String, dynamic>)
            ..docId = docSnapshot.id;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client not found.')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Details'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : client == null
              ? const Center(child: Text('No client details available.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          children: [
                            DetailTile(title: 'Name', value: client!.name),
                            DetailTile(title: 'Address', value: client!.address),
                            DetailTile(title: 'Phone No', value: client!.phoneNo),
                            DetailTile(title: 'Email', value: client!.email),
                            DetailTile(title: 'Client ID', value: client!.clientId),
                            DetailTile(title: 'Advocate ID', value: client!.advocate_id),
                            const SizedBox(height: 16),
                            const Text(
                              'Case Numbers:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            ...client!.caseNos.map((caseNo) => ListTile(
                                  title: Text(caseNo),
                                  leading: const Icon(Icons.folder),
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: client != null
                            ? () {
                                // Navigate to the ClientUpdateScreen
                                Get.toNamed('/client_update', arguments: {
                                  'client': client,
                                  'documentId': client!.docId,
                                });
                              }
                            : null,
                        child: const Text('Edit Client Details'),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class DetailTile extends StatelessWidget {
  final String title;
  final String value;

  const DetailTile({required this.title, required this.value, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
