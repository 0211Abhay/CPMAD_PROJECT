import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class UploadFileScreen extends StatefulWidget {
  final String caseId; // Pass the case ID for which the file is being uploaded
  UploadFileScreen({required this.caseId});

  @override
  _UploadFileScreenState createState() => _UploadFileScreenState();
}

class _UploadFileScreenState extends State<UploadFileScreen> {
  File? _selectedFile;
  String? _fileName;
  String? _fileType;
  final _fileDescriptionController = TextEditingController();
  bool _isUploading = false;

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'mp4', 'mp3'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
        _fileType = result.files.single.extension;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null || _fileDescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a file and add a description')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload file to Firebase Storage
      String fileName = "${DateTime.now().millisecondsSinceEpoch}_$_fileName";
      Reference storageRef = _storage.ref().child('case_files/${widget.caseId}/$fileName');
      UploadTask uploadTask = storageRef.putFile(_selectedFile!);

      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Save file details to Firestore
      await _firestore.collection('case_file_upload').add({
        'case_id': widget.caseId,
        'document_id': '', // Update if needed
        'file_description': _fileDescriptionController.text,
        'file_path': downloadUrl,
        'file_name': _fileName,
        'file_type': _fileType,
        'uploaded_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File uploaded successfully')),
      );

      setState(() {
        _selectedFile = null;
        _fileName = null;
        _fileType = null;
        _fileDescriptionController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading file: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Case File')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_selectedFile != null)
              Column(
                children: [
                  if (_fileType == 'jpg' || _fileType == 'jpeg' || _fileType == 'png')
                    Image.file(_selectedFile!, height: 150, width: 150, fit: BoxFit.cover)
                  else if (_fileType == 'mp4')
                    Icon(Icons.video_file, size: 100)
                  else if (_fileType == 'mp3')
                    Icon(Icons.audio_file, size: 100)
                  else if (_fileType == 'pdf')
                    Icon(Icons.picture_as_pdf, size: 100),
                  Text(_fileName ?? 'Selected File'),
                ],
              ),
            TextButton(
              onPressed: _selectFile,
              child: Text('Select File'),
            ),
            TextField(
              controller: _fileDescriptionController,
              decoration: InputDecoration(labelText: 'File Description'),
            ),
            SizedBox(height: 16),
            _isUploading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _uploadFile,
                    child: Text('Upload File'),
                  ),
          ],
        ),
      ),
    );
  }
}
