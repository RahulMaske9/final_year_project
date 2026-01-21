import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_app/subject_allotment_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageCoursesScreen extends StatefulWidget {
  const ManageCoursesScreen({super.key});

  @override
  State<ManageCoursesScreen> createState() => _ManageCoursesScreenState();
}

class _ManageCoursesScreenState extends State<ManageCoursesScreen> {
  final _nameController = TextEditingController();
  String _selectedBranch = 'CSE';
  String _selectedSem = '1';

  final List<String> _branches = ['CSE', 'ECE', 'ME', 'CE', 'IT'];
  final List<String> _semesters = ['1', '2', '3', '4', '5', '6', '7', '8'];

  void _showAddSubjectDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add New Subject', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Subject Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedBranch,
                  decoration: const InputDecoration(labelText: 'Branch', border: OutlineInputBorder()),
                  items: _branches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                  onChanged: (val) => setDialogState(() => _selectedBranch = val!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedSem,
                  decoration: const InputDecoration(labelText: 'Semester', border: OutlineInputBorder()),
                  items: _semesters.map((s) => DropdownMenuItem(value: s, child: Text('Semester $s'))).toList(),
                  onChanged: (val) => setDialogState(() => _selectedSem = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => _saveSubject(),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F51B5), foregroundColor: Colors.white),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSubject() async {
    if (_nameController.text.isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('subjects').add({
        'name': _nameController.text.trim(),
        'branch': _selectedBranch,
        'semester': _selectedSem,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _nameController.clear();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving subject: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Subjects', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // FIXED: Removed the complex orderBy that was causing "buffering" (index error)
        // You can add orderBy back once you create the composite index in Firebase Console
        stream: FirebaseFirestore.instance.collection('subjects').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: ${snapshot.error}\n\nIf this says "The query requires an index", click the link in your IDE debug console to create it.'),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No subjects found. Add one using the button below.', 
                style: GoogleFonts.lato(color: Colors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(data['name'] ?? 'Unknown Subject', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                  subtitle: Text('${data['branch'] ?? 'N/A'} • Semester ${data['semester'] ?? 'N/A'}'),
                  trailing: ElevatedButton.icon(
                    icon: const Icon(Icons.assignment_ind, size: 18),
                    label: const Text('Allot'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubjectAllotmentScreen(
                            subjectId: doc.id,
                            subjectName: data['name'] ?? 'Unknown',
                            branch: data['branch'] ?? 'N/A',
                            semester: data['semester'] ?? 'N/A',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade800,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSubjectDialog,
        backgroundColor: const Color(0xFF3F51B5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
