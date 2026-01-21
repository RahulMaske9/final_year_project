import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FacultyEnterMarksScreen extends StatefulWidget {
  const FacultyEnterMarksScreen({super.key});

  @override
  State<FacultyEnterMarksScreen> createState() => _FacultyEnterMarksScreenState();
}

class _FacultyEnterMarksScreenState extends State<FacultyEnterMarksScreen> {
  String? _selectedClass;
  String? _selectedSubject;
  String? _selectedExamType;
  bool _isLoading = false;

  final Map<String, TextEditingController> _marksControllers = {};
  final _formKey = GlobalKey<FormState>();

  // Mock Data - Ideally fetch these from Firestore configuration
  final List<String> _subjects = ['Data Structures', 'Algorithms', 'DBMS', 'OS', 'Networking'];
  final List<String> _examTypes = ['Mid-Term 1', 'Mid-Term 2', 'Final Exam', 'Assignment 1'];

  @override
  void dispose() {
    for (var controller in _marksControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveMarks() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClass == null || _selectedSubject == null || _selectedExamType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Class, Subject, and Exam Type.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final batch = FirebaseFirestore.instance.batch();
      final facultyId = FirebaseAuth.instance.currentUser?.uid;

      _marksControllers.forEach((studentId, controller) {
        if (controller.text.isNotEmpty) {
          final docRef = FirebaseFirestore.instance.collection('marks').doc();
          batch.set(docRef, {
            'studentId': studentId,
            'facultyId': facultyId,
            'className': _selectedClass,
            'subject': _selectedSubject,
            'examType': _selectedExamType,
            'marks': double.tryParse(controller.text) ?? 0,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      });

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Marks saved successfully!'),
            backgroundColor: Colors.green.shade700,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving marks: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Marks', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildFilters(currentUserId),
          Expanded(
            child: _selectedClass == null
                ? const Center(child: Text('Select a Class to continue'))
                : _buildStudentList(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5, offset: const Offset(0, -2))],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveMarks,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3F51B5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
              : const Text('Save Marks'),
        ),
      ),
    );
  }

  Widget _buildFilters(String userId) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('visibleTo.faculty', arrayContains: userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LinearProgressIndicator();
              
              final docs = snapshot.data!.docs;
              final Set<String> classes = {};
              for (var doc in docs) {
                 final data = doc.data() as Map<String, dynamic>;
                 classes.add('${data['course'] ?? ''} - ${data['year'] ?? ''}');
              }
              
              return DropdownButtonFormField<String>(
                value: _selectedClass,
                decoration: const InputDecoration(labelText: 'Select Class', border: OutlineInputBorder()),
                items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedClass = val),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSubject,
                  decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
                  items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) => setState(() => _selectedSubject = val),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedExamType,
                  decoration: const InputDecoration(labelText: 'Exam Type', border: OutlineInputBorder()),
                  items: _examTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => _selectedExamType = val),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    final parts = _selectedClass!.split(' - ');
    final courseFilter = parts.isNotEmpty ? parts[0] : '';
    final yearFilter = parts.length > 1 ? parts[1] : '';

    return Form(
      key: _formKey,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('course', isEqualTo: courseFilter)
            .where('year', isEqualTo: yearFilter)
            .orderBy('rollNo')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('No students found in this class.'));

          final students = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final data = student.data() as Map<String, dynamic>;
              final controller = _marksControllers.putIfAbsent(student.id, () => TextEditingController());

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(data['rollNo'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: Text(data['displayName'] ?? 'Unknown', style: GoogleFonts.lato(fontSize: 16)),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '0-100'),
                          textAlign: TextAlign.center,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final mark = double.tryParse(value);
                              if (mark == null || mark < 0 || mark > 100) return '!';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
