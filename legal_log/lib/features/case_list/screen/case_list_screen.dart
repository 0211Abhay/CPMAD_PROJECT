import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:legal_log/features/case_add/controller/case_add_controller.dart';
import 'package:legal_log/features/case_add/model/case.dart'; // Adjust import path as needed
import 'package:legal_log/features/case_add/services/case_firebase_services.dart';
import 'package:legal_log/features/case_list/case_details.dart'; // Adjust import path as needed

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
            return Case.fromJson(data)
              ..docId = doc.id; // Ensure your model conversion is correct
          }).toList();

          return ListView.builder(
            itemCount: cases.length,
            itemBuilder: (context, index) {
              final legalCase = cases[index];
              return Dismissible(
                key: ValueKey(legalCase.docId),
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
                    final shouldDelete =
                        await _showConfirmationDialog(context, "Delete");
                    if (shouldDelete ?? false) {
                      _caseFirebaseServices.deleteLegalCase(legalCase.docId);
                      return true;
                    }
                    return false;
                  } else if (direction == DismissDirection.startToEnd) {
                    final shouldUpdate =
                        await _showConfirmationDialog(context, "Update");
                    if (shouldUpdate ?? false) {
                      Get.toNamed('/case_update', arguments: {
                        'case': legalCase,
                        'documentId': legalCase.docId,
                      });
                    }
                    return false;
                  }
                  return false;
                },
                onDismissed: (direction) {
                  if (direction == DismissDirection.endToStart) {
                    // This block will execute only after confirmDismiss returns true
                    setState(() {
                      // Remove the client from the local list
                    });
                  }
                },
                child: CaseCard(
                  legalCase: legalCase,
                  width: MediaQuery.of(context).size.width,
                  onUpdate: () => _handleUpdate(legalCase),
                  onDelete: () => _handleDelete(legalCase),
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
        title: Text('$action Case'),
        content: Text('Are you sure you want to $action this Case ?'),
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

  void _handleUpdate(Case legalCase) {
    Get.toNamed('/case_update', arguments: {
      'case': legalCase,
      'documentId': legalCase.docId,
    });
  }

  void _handleDelete(Case legalCase) async {
    final shouldDelete = await _showConfirmationDialog(context, "Delete");
    if (shouldDelete ?? false) {
      _caseFirebaseServices.deleteLegalCase(legalCase.docId);
    }
  }
}

// class CaseCard extends StatelessWidget {
//   final Case legalCase;
//   final double width;
//   final VoidCallback onUpdate;
//   final VoidCallback onDelete;

//   const CaseCard({
//     super.key,
//     required this.legalCase,
//     required this.width,
//     required this.onUpdate,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Get.to(
//           () => CaseDetailScreen(),
//           arguments: legalCase, // Pass the case data to the details screen
//         );
//       },
//       child: Container(
//         width: width,
//         child: Card(
//           margin: const EdgeInsets.all(8.0),
//           elevation: 4.0,
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Text(
//                   "Case No: ${legalCase.caseNo ?? "N/A"}",
//                   style: const TextStyle(
//                       fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 Text("File No: ${legalCase.fileNo ?? "N/A"}"),
//                 Text("Applicant: ${legalCase.applicantName ?? "N/A"}"),
//                 Text("Opponent: ${legalCase.opponentName ?? "N/A"}"),
//                 Text("Court: ${legalCase.court ?? "N/A"}"),
//                 Text("Stage: ${legalCase.stage ?? "N/A"}"),
//                 const SizedBox(height: 8),
//                 Text(
//                   "Date of Filing: ${legalCase.dateOfFiling.toLocal().toString().split(' ')[0]}",
//                   style: const TextStyle(color: Colors.grey),
//                 ),
//                 const SizedBox(height: 8),
//                 Text("Note: ${legalCase.note ?? "N/A"}"),
//                 const SizedBox(height: 16),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
class CaseCard extends StatelessWidget {
  final Case legalCase;
  final double width;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const CaseCard({
    super.key,
    required this.legalCase,
    required this.width,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => CaseDetailScreen(),
          arguments: legalCase, // Pass the case data to the details screen
        );
      },
      child: Container(
        width: width,
        child: Card(
          margin: const EdgeInsets.all(8.0),
          elevation: 6.0, // More prominent elevation
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Case Number
                Row(
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      color: Colors.black87,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Case No: ${legalCase.caseNo ?? "N/A"}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const Divider(thickness: 1.0, height: 20.0), // Divider below Case No

                // Case Details
                _buildDetail("File No", legalCase.fileNo, Icons.document_scanner),
                _buildDetail("Applicant", legalCase.applicantName, Icons.person),
                _buildDetail("Opponent", legalCase.opponentName, Icons.person_outline),
                _buildDetail("Court", legalCase.court, Icons.gavel),
                _buildDetail("Stage", legalCase.stage, Icons.timeline),

                const SizedBox(height: 8),

                // Filing Date
                Row(
                  
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.grey,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Date of Filing:",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width:4),
                    Text(
                      legalCase.dateOfFiling.toLocal().toString().split(' ')[0],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Note Section
                Row(
                  children: [
                    Icon(
                      Icons.note_alt_outlined,
                      color: Colors.black87,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Note:",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Text(
                  legalCase.note ?? "N/A",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 16),

                // Action Buttons
                // You can add action buttons here if needed (e.g. Update, Delete)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(String label, String? value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.black87,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value ?? "N/A",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}