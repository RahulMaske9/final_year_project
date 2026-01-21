import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_app/student_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FacultyStudentListScreen extends StatelessWidget {
  final String className; // e.g., "CSE - Sem 1"
  final String subjectName;

  const FacultyStudentListScreen({
    super.key,
    required this.className,
    required this.subjectName,
  });

  @override
  Widget build(BuildContext context) {
    // Split class name back into branch and semester
    final parts = className.split(' - Sem ');
    final branchFilter = parts.isNotEmpty ? parts[0] : '';
    final semesterFilter = parts.length > 1 ? parts[1] : '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subjectName, style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(className, style: GoogleFonts.lato(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'Student')
            .where('branch', isEqualTo: branchFilter)
            .where('semester', isEqualTo: semesterFilter)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No students enrolled in this class.',
                    style: GoogleFonts.lato(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return _buildStudentCard(context, doc.id, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, String studentId, Map<String, dynamic> data) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.blue.shade50,
          child: Text(
            (data['name'] ?? '?')[0].toUpperCase(),
            style: const TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          data['name'] ?? 'Unknown Student',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Roll: ${data['roll'] ?? 'N/A'}',
          style: GoogleFonts.lato(color: Colors.grey.shade600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentDetailsScreen(
                studentId: studentId,
                viewerRole: 'Faculty',
              ),
            ),
          );
        },
      ),
    );
  }
}
