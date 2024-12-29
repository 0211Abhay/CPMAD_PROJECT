import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:legal_log/features/case_add/controller/case_add_controller.dart';
import 'package:legal_log/features/case_add/model/case.dart'; // Adjust import path as needed
import 'package:legal_log/features/case_add/services/case_firebase_services.dart';
import 'package:legal_log/features/case_list/case_card.dart';
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
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    user_id = storage.read('user')['advocate_id'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by Case No',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _caseFirebaseServices.fetchLegalCasesByID(user_id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  print("ConnectionState: Waiting");
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print("Error: \${snapshot.error}");
                  return const Center(child: Text("Error fetching cases"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  print("No cases found for userId");
                  return const Center(child: Text("No cases found"));
                }

                final cases = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  print("Document: \${data}");
                  return Case.fromJson(data)
                    ..docId = doc.id; // Ensure your model conversion is correct
                }).where((legalCase) {
                  return legalCase.caseNo?.toLowerCase().contains(searchQuery) ?? false;
                }).toList();

                if (cases.isEmpty) {
                  return const Center(child: Text("No cases match your search"));
                }

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
                          // final shouldUpdate =
                          //     await _showConfirmationDialog(context, "Update");
                          // if (shouldUpdate ?? false) {
                            Get.toNamed('/case_update', arguments: {
                              'case': legalCase,
                              'documentId': legalCase.docId,
                            });
                          // }
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
          ),
        ],
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
