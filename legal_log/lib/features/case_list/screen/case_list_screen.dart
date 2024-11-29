import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:legal_log/features/case_add/controller/case_add_controller.dart';
import 'package:legal_log/features/case_add/model/case.dart'; // Adjust import path as needed
import 'package:legal_log/features/case_add/services/case_firebase_services.dart'; // Adjust import path as needed

class CaseListScreen extends StatefulWidget {
  const CaseListScreen({super.key});

  @override
  State<CaseListScreen> createState() => _CaseListScreenState();
}

class _CaseListScreenState extends State<CaseListScreen> {
  final CaseFirebaseServices _caseFirebaseServices = CaseFirebaseServices();
  final CaseAddController controller = Get.put(CaseAddController());
  late String user_id; // Declare without initialization
  GetStorage storage = GetStorage();
  @override
  void initState() {
    super.initState();
    user_id = storage.read('user')['advocate_id'];
    ; // Initialize in initState
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _caseFirebaseServices.fetchLegalCasesByID(user_id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            print("ConnectionState: Waiting");
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print("Error: ${snapshot.error}");
            return const Center(child: Text("Error fetching cases"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print("No cases found for userId");
            return const Center(child: Text("No cases found"));
          }

          final cases = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            print("Document: ${data}");
            return Case.fromJson(
                data); // Ensure your model conversion is correct
          }).toList();

          return ListView.builder(
            itemCount: cases.length,
            itemBuilder: (context, index) {
              final legalCase = cases[index];
              return CaseCard(
                legalCase: legalCase,
                onUpdate: () => _caseFirebaseServices.updateCase(
                    legalCase, legalCase.case_id), // Pass the update method
                onDelete: () => _caseFirebaseServices.deleteLegalCase(
                    legalCase.case_id), // Pass the delete method
              );
            },
          );
        },
      ),
    );
  }
}

class CaseCard extends StatelessWidget {
  final Case legalCase;
  final VoidCallback onUpdate; // Update method callback
  final VoidCallback onDelete; // Delete method callback

  const CaseCard(
      {super.key,
      required this.legalCase,
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
              "Case No: ${legalCase.caseNo ?? "N/A"}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("File No: ${legalCase.fileNo ?? "N/A"}"),
            Text("Applicant: ${legalCase.applicantName ?? "N/A"}"),
            Text("Opponent: ${legalCase.opponentName ?? "N/A"}"),
            Text("Court: ${legalCase.court ?? "N/A"}"),
            Text("Stage: ${legalCase.stage ?? "N/A"}"),
            const SizedBox(height: 8),
            Text(
              "Date of Filing: ${legalCase.dateOfFiling.toLocal().toString().split(' ')[0]}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text("Note: ${legalCase.note ?? "N/A"}"),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  color: Colors.green,
                  onPressed: onUpdate, // Trigger update when pressed
                  tooltip: 'Update Case',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: onDelete, // Trigger delete when pressed
                  tooltip: 'Delete Case',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
