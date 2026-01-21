import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_app/edit_student_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentDetailsScreen extends StatelessWidget {
  final String studentId;
  final String viewerRole; // 'Admin', 'Faculty', 'Parent'

  const StudentDetailsScreen({
    super.key,
    required this.studentId,
    required this.viewerRole,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Student Profile', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('students').doc(studentId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Student profile not found.'));
          }

          final studentData = snapshot.data!.data() as Map<String, dynamic>;
          final studentName = studentData['name'] ?? 'Unknown Student';

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(studentName, studentData),
                const SizedBox(height: 16),
                if (viewerRole == 'Admin')
                  _buildAdminActions(context, studentData),
                const SizedBox(height: 16),
                _buildInfoSection('Academic Details', [
                  _buildInfoRow(Icons.confirmation_number_outlined, 'Roll Number', studentData['rollNo'] ?? 'N/A'),
                  _buildInfoRow(Icons.school_outlined, 'Course', studentData['course'] ?? 'N/A'),
                  _buildInfoRow(Icons.calendar_today_outlined, 'Semester', studentData['semester'] ?? 'N/A'),
                ]),
                 const SizedBox(height: 16),
                 _buildInfoSection('Contact Information', [
                   _buildInfoRow(Icons.email_outlined, 'Email', studentData['email'] ?? 'N/A'),
                 ]),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(String name, Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // ✅ HERO TAG FIX
          Hero(
            tag: 'student_avatar_$studentId',
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: GoogleFonts.lato(fontSize: 40, fontWeight: FontWeight.bold, color: const Color(0xFF3F51B5)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(name, style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            'Roll: ${data['rollNo'] ?? 'N/A'} • ${data['course'] ?? ''}',
            style: GoogleFonts.lato(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActions(BuildContext context, Map<String, dynamic> currentData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditStudentScreen(
                studentId: studentId,
                currentData: currentData,
              ),
            ),
          );
        },
        icon: const Icon(Icons.edit_outlined, size: 18),
        label: const Text('Edit Student Profile'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF3F51B5),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 1,
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(title, style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF3F51B5))),
          ),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade500),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.lato(fontSize: 12, color: Colors.grey.shade500)),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.lato(fontSize: 16, color: Colors.grey.shade800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
