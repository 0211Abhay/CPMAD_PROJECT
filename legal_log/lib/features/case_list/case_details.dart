import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:legal_log/common_widgets/show_loader.dart';
import 'package:legal_log/features/case_add/model/case.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:legal_log/features/case_list/view_case_files.dart';
import 'package:legal_log/features/case_notes/case_note_controller.dart';
import 'package:legal_log/features/case_notes/case_note_model.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:legal_log/features/case_notes/case_notes_view.dart'; // Adjust the import based on the location of CaseNotesView
import 'package:intl/intl.dart';

class CaseDetailScreen extends StatelessWidget {
  CaseDetailScreen({Key? key}) : super(key: key);
  final GetStorage storage = GetStorage();
  final CaseNoteController caseNoteController = Get.put(CaseNoteController());

  @override
  Widget build(BuildContext context) {
    final Case? legalCase = Get.arguments;
    String userName = storage.read('user')['name'];

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
      body: FutureBuilder<List<CaseNote>>(
        future: _fetchCaseNotes(legalCase!.docId ?? ""),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final notes = snapshot.data ?? [];
            return SingleChildScrollView(
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
                              "Case ID", legalCase.docId ?? "N/A", context),
                          _buildTableRow("Advocate Name", userName, context),
                          _buildTableRow(
                              "Case No", legalCase.caseNo ?? "N/A", context),
                          _buildTableRow(
                              "File No", legalCase.fileNo ?? "N/A", context),
                          _buildTableRow("Applicant",
                              legalCase.applicantName ?? "N/A", context),
                          _buildTableRow(
                              "Other Applicant",
                              _formatList(legalCase.otherApplicant) ?? "N/A",
                              context),
                          _buildTableRow("Opponent",
                              legalCase.opponentName ?? "N/A", context),
                          _buildTableRow(
                              "Other Opponent",
                              _formatList(legalCase.otherOpponent) ?? "N/A",
                              context),
                          _buildTableRow(
                              "Client", legalCase.ourClient ?? "N/A", context),
                          _buildTableRow(
                              "Area", legalCase.area ?? "N/A", context),
                          _buildTableRow(
                              "Court", legalCase.court ?? "N/A", context),
                          _buildTableRow(
                              "Judge", legalCase.judge ?? "N/A", context),
                          _buildTableRow(
                              "Our Advocates",
                              _formatStringList(legalCase.ourAdvocates) ??
                                  "N/A",
                              context),
                          _buildTableRow(
                              "Opponent Advocate",
                              _formatStringList(legalCase.opponentAdvocates) ??
                                  "N/A",
                              context),
                          _buildTableRow(
                              "Stage", legalCase.stage ?? "N/A", context),
                          _buildTableRow(
                              "Date of Filing",
                              legalCase.dateOfFiling
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0],
                              context),
                          _buildTableRow(
                              "Note", legalCase.note ?? "N/A", context),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildNotesTimeline(notes), // Add the notes timeline here
                    const SizedBox(height: 20),
                    _buildActionButtons(legalCase, userName),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<List<CaseNote>> _fetchCaseNotes(String caseId) async {
    final notesSnapshot = await FirebaseFirestore.instance
        .collection('cases')
        .doc(caseId)
        .collection(' case_note')
        .orderBy('timestamp', descending: true) // Sort by timestamp
        .get();

    return notesSnapshot.docs
        .map((doc) => CaseNote.fromFirestore(
            doc)) // Assuming you have a fromFirestore method
        .toList();
  }

  Widget _buildNotesTimeline(List<CaseNote> notes) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          title: Text(note.note), // Assuming CaseNote has a content field
          subtitle:
              Text(note.timestamp as String), // Format timestamp as needed
        );
      },
    );
  }

  Widget _buildActionButtons(Case legalCase, String userName) {
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
      showLottieDialog(
        animationPath: 'assets/lottie/generatereport.json',
        message: 'Generating PDF Report',
      );

      // Fetch case notes
      final notesSnapshot = await FirebaseFirestore.instance
          .collection('case')
          .doc(legalCase.docId)
          .collection('case_note')
          .orderBy('timestamp', descending: true)
          .get();

      final logoImage = await _loadLogoImage();
      final logoImageProvider = pw.MemoryImage(logoImage);

      final pdf = pw.Document();

      // Create PDF with multiple pages support
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header: (pw.Context context) {
            if (context.pageNumber == 1) {
              return pw.Column(
                children: [
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
                ],
              );
            }
            return pw.SizedBox(height: 20);
          },
          footer: (pw.Context context) {
            return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 20),
              child: pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: const pw.TextStyle(
                  color: PdfColors.grey,
                  fontSize: 10,
                ),
              ),
            );
          },
          build: (pw.Context context) {
            return [
              _buildPdfTable(legalCase, userName),
              pw.SizedBox(height: 30),
              pw.Header(
                level: 1,
                text: 'Case Notes Timeline',
                textStyle: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              ...notesSnapshot.docs.map((noteDoc) {
                final note = noteDoc.data() as Map<String, dynamic>;
                final timestamp = note['timestamp'] as Timestamp;
                final noteText = note['note'] as String;
                final date = timestamp.toDate();

                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          width: 100,
                          child: pw.Text(
                            DateFormat('MMM dd, yyyy\nhh:mm a').format(date),
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey600,
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 10),
                        pw.Expanded(
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(10),
                            margin: const pw.EdgeInsets.only(bottom: 10),
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                color: PdfColors.grey300,
                              ),
                              borderRadius: const pw.BorderRadius.all(
                                pw.Radius.circular(5),
                              ),
                            ),
                            child: pw.Text(
                              noteText,
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }).toList(),
              pw.SizedBox(height: 20),
              pw.Text(
                'This is an automatically generated report.',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey,
                ),
              ),
            ];
          },
        ),
      );

      // Rest of the code remains the same
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'case_report_${legalCase.caseNo}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      Get.back();

      Get.snackbar(
        'Success',
        'PDF report generated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      await OpenFile.open(filePath);
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

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

  Future<Uint8List> _loadLogoImage() async {
    final ByteData logoData =
        await rootBundle.load('assets/images/logo-removebg-preview.png');
    return logoData.buffer.asUint8List();
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

  void _viewNotes(Case legalCase) {
    final caseId = legalCase.docId ?? "";
    // Navigate to the CaseNotesView screen
    Get.to(() => CaseNotesView(caseId: caseId));
  }

  String _formatList(List<String?> list) {
    return list.where((item) => item != null).join(',');
  }

  String _formatStringList(List<String> list) {
    return list.join(', ');
  }
}
