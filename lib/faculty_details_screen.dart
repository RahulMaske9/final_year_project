import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_app/edit_faculty_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FacultyDetailsScreen extends StatelessWidget {
  final String facultyId;

  const FacultyDetailsScreen({super.key, required this.facultyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Faculty Details', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Fetch the latest data before editing
              final doc = await FirebaseFirestore.instance.collection('faculty').doc(facultyId).get();
              if (doc.exists && context.mounted) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EditFacultyScreen(
                    facultyId: facultyId,
                    initialData: doc.data(),
                  ),
                ));
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('faculty').doc(facultyId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Faculty member not found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final isActive = data['isActive'] ?? true;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildDetailRow('Name', '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'),
              _buildDetailRow('Email', data['email'] ?? 'N/A'),
              _buildDetailRow('Department', data['department'] ?? 'N/A'),
              _buildDetailRow('Status', isActive ? 'Active' : 'Inactive'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Logic to toggle active status
                  FirebaseFirestore.instance.collection('faculty').doc(facultyId).update({'isActive': !isActive});
                },
                icon: Icon(isActive ? Icons.toggle_off : Icons.toggle_on),
                label: Text(isActive ? 'Deactivate' : 'Reactivate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.lato(fontSize: 12, color: Colors.grey.shade600)),
          Text(value, style: GoogleFonts.lato(fontSize: 16)),
          const Divider(),
        ],
      ),
    );
  }
}
