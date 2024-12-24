import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legal_log/features/case_add/model/case.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:legal_log/features/case_list/view_case_files.dart';

class CaseDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Case legalCase = Get.arguments; // Get the passed case data

    return Scaffold(
      appBar: AppBar(
        title: Text("Case Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Case No: ${legalCase.caseNo ?? "N/A"}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
            ElevatedButton(
              onPressed: () {
                _generateReport(legalCase);
              },
              child: const Text("Generate Report"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _addNote();
              },
              child: const Text("Add Note"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                uploadFile(legalCase); // Pass the legalCase object here
              },
              child: const Text("Upload File"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                viewCaseFiles(legalCase);
              },
              child: const Text("View Case Files"),
            ),
          ],
        ),
      ),
    );
  }

  void _generateReport(Case legalCase) {
    // Add logic to generate a report
    print("Generating report for case: ${legalCase.docId ?? "Unknown DocId"}");
  }

  void _addNote() {
    // Add logic to add a note
    print("Add Note clicked");
  }

  void uploadFile(Case legalCase) {
    // Add logic to upload a file
    print("Upload File clicked");
    Get.toNamed('/file_upload', arguments: {'caseId': legalCase.docId ?? ""});
  }

  void viewCaseFiles(Case legalCase) {
    // Pass the caseId, ensuring it is not null
    final caseId = legalCase.docId ?? "";
    // Navigate to the view case files screen
    Get.to(ViewCaseFilesScreen(caseId: caseId));
  }
}
