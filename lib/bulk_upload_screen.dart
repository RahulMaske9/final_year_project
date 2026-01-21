import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BulkUploadScreen extends StatefulWidget {
  const BulkUploadScreen({super.key});

  @override
  State<BulkUploadScreen> createState() => _BulkUploadScreenState();
}

class _BulkUploadScreenState extends State<BulkUploadScreen> {
  bool _isLoading = false;
  String _statusMessage = '';
  PlatformFile? _pickedFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      setState(() {
        _pickedFile = result.files.first;
        _statusMessage = 'File: ${_pickedFile!.name}';
      });
    }
  }

  Future<void> _uploadData() async {
    if (_pickedFile == null) {
      setState(() => _statusMessage = 'Error: Please select a file first.');
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Starting upload...';
    });

    try {
      // Read and decode the file content
      final file = File(_pickedFile!.path!);
      final input = file.openRead();
      final fields = await input
          .transform(utf8.decoder)
          .transform(const CsvToListConverter())
          .toList();

      if (fields.isEmpty) {
        setState(() => _statusMessage = 'Error: CSV file is empty.');
        return;
      }

      final headers = fields.first.map((h) => h.toString().trim()).toList();
      final studentsToUpload = fields.sublist(1);
      final totalStudents = studentsToUpload.length;

      WriteBatch batch = FirebaseFirestore.instance.batch();
      int operations = 0;

      for (int i = 0; i < totalStudents; i++) {
        final row = studentsToUpload[i];
        final studentData = Map<String, dynamic>.fromIterables(headers, row);

        // --- Parent Linking Logic ---
        String? parentId;
        if (studentData['parentEmail'] != null &&
            studentData['parentEmail'].toString().isNotEmpty) {
          final parentQuery = await FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'Parent')
              .where('email', isEqualTo: studentData['parentEmail'])
              .limit(1)
              .get();

          if (parentQuery.docs.isNotEmpty) {
            parentId = parentQuery.docs.first.id;
          }
        }

        final docRef = FirebaseFirestore.instance.collection('students').doc();
        batch.set(docRef, {
          'name': studentData['name'] ?? '',
          'rollNo': studentData['rollNo'] ?? '',
          'email': studentData['email'] ?? '',
          'phone': studentData['phone'] ?? '',
          'course': studentData['course'] ?? '',
          'semester': studentData['semester'] ?? '',
          'parentId': parentId, // Set the linked parent UID
          'createdAt': FieldValue.serverTimestamp(),
        });

        operations++;

        // Firestore batch limit is 500. Commit and create a new batch.
        if (operations >= 499) {
          await batch.commit();
          batch = FirebaseFirestore.instance.batch();
          operations = 0;
        }

        setState(() {
          _statusMessage = 'Processing student ${i + 1} of $totalStudents...';
        });
      }

      if (operations > 0) {
        await batch.commit();
      }

      setState(() =>
          _statusMessage = 'Success! $totalStudents students uploaded.');
    } catch (e) {
      setState(() => _statusMessage = 'An error occurred: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bulk Upload Students', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.upload_file, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 24),
              Text(
                'Upload a CSV file with student data to add multiple students at once.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(fontSize: 16, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Select .CSV File'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_pickedFile != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _uploadData,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Start Upload'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F51B5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              if (_isLoading)
                const CircularProgressIndicator(),
              if (_statusMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
