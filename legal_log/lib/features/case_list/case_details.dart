import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:legal_log/common_widgets/show_loader.dart';
import 'package:legal_log/features/case_add/model/case.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:legal_log/features/case_list/view_case_files.dart';
import 'package:legal_log/features/case_notes/case_note_controller.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:legal_log/features/case_notes/case_notes_view.dart'; // Adjust the import based on the location of CaseNotesView

String _formatList(List<String?> list) {
  return list.where((item) => item != null).join(',');
}

String _formatStringList(List<String> list) {
  return list.join(', ');
}

Future<Uint8List> _loadLogoImage() async {
  final ByteData logoData =
      await rootBundle.load('assets/images/logo-removebg-preview.png');
  return logoData.buffer.asUint8List();
}

class CaseDetailScreen extends StatelessWidget {
  CaseDetailScreen({Key? key}) : super(key: key);
  final GetStorage storage = GetStorage();
  final CaseNoteController caseNoteController = Get.put(CaseNoteController());
  @override
  Widget build(BuildContext context) {
    final Case? legalCase = Get.arguments;
    String userName = storage.read('user')['name'];
    String advocateId =
        storage.read('user')['advocate_id']; // Advocate ID from storage
    return Scaffold(
      appBar: AppBar(
        title: const Text("Case Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareCase(legalCase!),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                child: Table(
                  border: TableBorder.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                  children: [
                    _buildTableRow(
                        "Case ID", legalCase?.docId ?? "N/A", context),
                    _buildTableRow("Advocate Name", userName, context),
                    _buildTableRow(
                        "Case No", legalCase?.caseNo ?? "N/A", context),
                    _buildTableRow(
                        "File No", legalCase?.fileNo ?? "N/A", context),
                    _buildTableRow("Applicant",
                        legalCase?.applicantName ?? "N/A", context),
                    _buildTableRow(
                        "Other Applicant",
                        _formatList(legalCase!.otherApplicant) ?? "N/A",
                        context),
                    _buildTableRow(
                        "Opponent", legalCase?.opponentName ?? "N/A", context),
                    _buildTableRow(
                        "Other Opponent",
                        _formatList(legalCase!.otherOpponent) ?? "N/A",
                        context),
                    _buildTableRow(
                        "Client", legalCase.ourClient ?? "N/A", context),
                    _buildTableRow("Area", legalCase.area ?? "N/A", context),
                    _buildTableRow("Court", legalCase.court ?? "N/A", context),
                    _buildTableRow("Judge", legalCase.judge ?? "N/A", context),
                    _buildTableRow(
                        "Our Advocates",
                        _formatStringList(legalCase.ourAdvocates) ?? "N/A",
                        context),
                    _buildTableRow(
                        "Opponent Advocate",
                        _formatStringList(legalCase.opponentAdvocates) ?? "N/A",
                        context),
                    _buildTableRow("Stage", legalCase.stage ?? "N/A", context),
                    _buildTableRow(
                        "Date of Filing",
                        legalCase.dateOfFiling
                            .toLocal()
                            .toString()
                            .split(' ')[0],
                        context),
                    _buildTableRow("Note", legalCase.note ?? "N/A", context),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildActionButtons(legalCase, userName),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(Case legalCase, userName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () => _generateAndOpenReport(legalCase, userName),
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text("Generate Report"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _uploadFile(legalCase),
          icon: const Icon(Icons.upload_file),
          label: const Text("Upload File"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _viewCaseFiles(legalCase),
          icon: const Icon(Icons.folder_open),
          label: const Text("View Case Files"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _viewNotes(legalCase),
          icon: const Icon(Icons.notes),
          label: const Text("View Notes"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  TableRow _buildTableRow(String title, String value, BuildContext context) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }

  Future<void> _generateAndOpenReport(Case legalCase, String userName) async {
    try {
      // Show loading indicator
      showLottieDialog(
        animationPath:
            'assets/lottie/generatereport.json', // Path to your Lottie loader animation
        message: 'Generating PDF Report',
      );

      final logoImage = await _loadLogoImage();
      final logoImageProvider = pw.MemoryImage(logoImage);

      // Create PDF document
      final pdf = pw.Document();

      // Add page to the PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Stack(
                children: [
                  // Watermark as background
                  pw.Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: pw.Center(
                      child: pw.Opacity(
                        opacity: 0.3,
                        child: pw.Transform.rotate(
                          angle: 0.0,
                          child: pw.Image(logoImageProvider, width: 400),
                        ),
                      ),
                    ),
                  ),

                  // Content on top of watermark
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      // Header with logo
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Case Report',
                                style: pw.TextStyle(
                                  fontSize: 24,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 5),
                              pw.Text(
                                'Generated: ${DateTime.now().toString().split('.')[0]}',
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColors.grey,
                                ),
                              ),
                            ],
                          ),
                          pw.Image(
                            logoImageProvider,
                            width: 60,
                            height: 60,
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 20),

                      // Table content
                      _buildPdfTable(legalCase, userName),

                      pw.SizedBox(height: 20),
                      pw.Text(
                        'This is an automatically generated report.',
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ];
          },
        ),
      );

      // Get directory for saving PDF
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'case_report_${legalCase.caseNo}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${directory.path}/$fileName';

      print('Report is Saved At ${filePath}');

      // Save PDF
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // Close loading dialog
      Get.back();

      // Show success message
      Get.snackbar(
        'Success',
        'PDF report generated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Open the generated PDF
      await OpenFile.open(filePath);
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to generate PDF: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      print('PDF Generation Error: $e');
    }
  }

  pw.Widget _buildPdfTable(Case legalCase, String userName) {
    return pw.Table(
      border: pw.TableBorder.all(width: 1),
      children: [
        _buildPdfTableRow("Case ID", legalCase.docId ?? "N/A"),
        _buildPdfTableRow("Advocate Name", userName),
        _buildPdfTableRow("Case No", legalCase.caseNo),
        _buildPdfTableRow("File No", legalCase.fileNo),
        _buildPdfTableRow("Applicant", legalCase.applicantName),
        _buildPdfTableRow(
            "Other Applicant", _formatList(legalCase.otherApplicant)),
        _buildPdfTableRow("Opponent", legalCase.opponentName),
        _buildPdfTableRow(
            "Other Opponent", _formatList(legalCase.otherOpponent)),
        _buildPdfTableRow("Client", legalCase.ourClient),
        _buildPdfTableRow("Area", legalCase.area),
        _buildPdfTableRow("Court", legalCase.court),
        _buildPdfTableRow("Judge", legalCase.judge),
        _buildPdfTableRow(
            "Our Advocates", _formatStringList(legalCase.ourAdvocates)),
        _buildPdfTableRow("Opponent Advocate",
            _formatStringList(legalCase.opponentAdvocates)),
        _buildPdfTableRow("Stage", legalCase.stage),
        _buildPdfTableRow("Date of Filing",
            legalCase.dateOfFiling.toLocal().toString().split(' ')[0]),
        _buildPdfTableRow("Note", legalCase.note ?? "N/A"),
      ],
    );
  }

  pw.TableRow _buildPdfTableRow(String title, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            title,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }

  void _uploadFile(Case legalCase) {
    Get.toNamed('/file_upload', arguments: {'caseId': legalCase.docId ?? ""});
  }

  void _viewCaseFiles(Case legalCase) {
    final caseId = legalCase.docId ?? "";
    Get.to(() => ViewCaseFilesScreen(caseId: caseId));
  }

  void _shareCase(Case legalCase) {
    // Implement share functionality
  }
}

void _viewNotes(Case legalCase) {
  final caseId = legalCase.docId ?? "";
  // Navigate to the CaseNotesView screen
  Get.to(() => CaseNotesView(caseId: caseId));
}