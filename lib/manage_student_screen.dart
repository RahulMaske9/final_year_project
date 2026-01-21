import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_app/bulk_upload_screen.dart';
import 'package:first_app/edit_student_screen.dart'; 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageStudentScreen extends StatelessWidget {
  const ManageStudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Students',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        actions: [
          // ✅ ADDED: Navigation to the Bulk Upload Screen
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Bulk Upload Students',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BulkUploadScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EditStudentScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade100, Colors.blue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('students') 
              .orderBy('name')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school, size: 60, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No students found',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Press the + button to add a new student.',
                      style: GoogleFonts.lato(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            final students = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Added padding for FAB
              itemCount: students.length,
              itemBuilder: (context, index) {
                final studentDoc = students[index];
                final studentData = studentDoc.data() as Map<String, dynamic>;

                final studentName = studentData['name'] ?? 'Unknown';
                final rollNo = studentData['rollNo'] ?? 'N/A';
                final course = studentData['course'] ?? 'N/A';
                final semester = studentData['semester'] ?? '';

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor:
                      const Color(0xFF3F51B5).withOpacity(0.1),
                      child: Text(
                        studentName.isNotEmpty
                            ? studentName[0].toUpperCase()
                            : '?',
                        style: GoogleFonts.lato(
                          color: const Color(0xFF3F51B5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      studentName,
                      style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Roll: $rollNo • $course Sem $semester',
                      style: GoogleFonts.lato(color: Colors.grey.shade700),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditStudentScreen(
                            studentId: studentDoc.id,
                            currentData: studentData,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
