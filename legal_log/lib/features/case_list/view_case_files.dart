import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ViewCaseFilesScreen extends StatefulWidget {
  final String caseId;

  ViewCaseFilesScreen({required this.caseId});

  @override
  _ViewCaseFilesScreenState createState() => _ViewCaseFilesScreenState();
}

class _ViewCaseFilesScreenState extends State<ViewCaseFilesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  late Stream<QuerySnapshot> _fileStream;

  @override
  void initState() {
    super.initState();
    _fileStream = _firestore
        .collection('case_file_upload')
        .where('case_id', isEqualTo: widget.caseId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Case Files')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fileStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No files found for this case.'));
          }

          final files = snapshot.data!.docs;

          return ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) {
              var file = files[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: 7,
                child: ListTile(
                  leading: _getFileIcon(file['file_type']),
                  title: Text(file['file_name']),
                  subtitle: Text(file['file_description'] ?? 'No description'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteFile(file.id, file['file_path']),
                  ),
                  onTap: () => _openFile(file['file_path'], file['file_type']),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _getFileIcon(String fileType) {
    switch (fileType) {
      case 'pdf':
        return Icon(Icons.picture_as_pdf, color: Colors.red);
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icon(Icons.image, color: Colors.blue);
      default:
        return Icon(Icons.insert_drive_file, color: Colors.grey);
    }
  }

  Future<void> _openFile(String fileUrl, String fileType) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final localFile = File('${tempDir.path}/${fileUrl.split('/').last}');
      if (!localFile.existsSync()) {
        final dio = Dio();
        await dio.download(fileUrl, localFile.path);
      }

      if (fileType == 'pdf') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(filePath: localFile.path),
          ),
        ).then((_) {
          if (localFile.existsSync()) {
            localFile.delete();
          }
        });
      } else if (fileType == 'jpg' || fileType == 'jpeg' || fileType == 'png') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageViewerScreen(imagePath: localFile.path),
          ),
        ).then((_) {
          if (localFile.existsSync()) {
            localFile.delete();
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unsupported file type: $fileType')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: $e')),
      );
    }
  }

  Future<void> _deleteFile(String documentId, String filePath) async {
    try {
      // Delete file from Firestore Storage
      await _storage.refFromURL(filePath).delete();

      // Delete document from Firestore
      await _firestore.collection('case_file_upload').doc(documentId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting file: $e')),
      );
    }
  }
}

class PdfViewerScreen extends StatelessWidget {
  final String filePath;

  PdfViewerScreen({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PDF Viewer')),
      body: PDFView(
        filePath: filePath,
        enableSwipe: true,
        swipeHorizontal: true,
      ),
    );
  }
}

class ImageViewerScreen extends StatelessWidget {
  final String imagePath;

  ImageViewerScreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Viewer')),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
    );
  }
}
