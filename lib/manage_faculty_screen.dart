
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_app/edit_faculty_screen.dart';
import 'package:first_app/faculty_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageFacultyScreen extends StatelessWidget {
  const ManageFacultyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Faculty', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('faculty').orderBy('firstName').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No faculty members found.'));
          }

          final facultyList = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: facultyList.length,
            itemBuilder: (context, index) {
              final doc = facultyList[index];
              final data = doc.data() as Map<String, dynamic>;
              final isActive = data['isActive'] ?? true;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isActive ? Colors.green.shade100 : Colors.grey.shade300,
                    child: Text(
                      (data['firstName'] ?? '?')[0],
                      style: TextStyle(color: isActive ? Colors.green.shade800 : Colors.grey.shade700),
                    ),
                  ),
                  title: Text(
                    '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}',
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(data['email'] ?? 'No email'),
                  trailing: Icon(
                    Icons.circle,
                    color: isActive ? Colors.green : Colors.red,
                    size: 12,
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => FacultyDetailsScreen(facultyId: doc.id),
                    ));
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const EditFacultyScreen(),
          ));
        },
        backgroundColor: const Color(0xFF3F51B5),
        child: const Icon(Icons.add),
      ),
    );
  }
}
