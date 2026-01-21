import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubjectAllotmentScreen extends StatefulWidget {
  final String subjectId;
  final String subjectName;
  final String branch;
  final String semester;

  const SubjectAllotmentScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
    required this.branch,
    required this.semester,
  });

  @override
  State<SubjectAllotmentScreen> createState() => _SubjectAllotmentScreenState();
}

class _SubjectAllotmentScreenState extends State<SubjectAllotmentScreen> {
  String? _selectedFacultyId;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Allot Subject', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildFacultySelection(),
            const SizedBox(height: 24),
            _buildStudentList(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 0,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.subjectName,
                style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTag(widget.branch),
                const SizedBox(width: 8),
                _buildTag('Semester ${widget.semester}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
    );
  }

  Widget _buildFacultySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Faculty', style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          // FIXED: We now fetch from 'users' where role is 'Faculty' to get correct Auth UIDs
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'Faculty')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LinearProgressIndicator();
            final faculty = snapshot.data!.docs;

            if (faculty.isEmpty) {
              return Text('No registered Faculty found. Ensure they have logged in at least once.', 
                style: TextStyle(color: Colors.red.shade700, fontSize: 12));
            }

            return DropdownButtonFormField<String>(
              value: _selectedFacultyId,
              hint: const Text('Choose Teacher'),
              isExpanded: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: faculty.map((f) {
                final data = f.data() as Map<String, dynamic>;
                return DropdownMenuItem(
                  value: f.id,
                  child: Text(data['displayName'] ?? data['name'] ?? data['email'] ?? 'Faculty'),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedFacultyId = val),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStudentList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Eligible Students', style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Students from ${widget.branch} Semester ${widget.semester} will be allotted automatically.',
            style: GoogleFonts.lato(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'Student')
              .where('branch', isEqualTo: widget.branch)
              .where('semester', isEqualTo: widget.semester)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final students = snapshot.data!.docs;

            if (students.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                child: const Text('No students found for this Branch/Semester.', style: TextStyle(color: Colors.red)),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final data = students[index].data() as Map<String, dynamic>;
                return ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.blue.shade100, child: const Icon(Icons.person, size: 20)),
                  title: Text(data['name'] ?? data['displayName'] ?? 'Unknown'),
                  subtitle: Text('Roll: ${data['roll'] ?? data['rollNo'] ?? 'N/A'}'),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: ElevatedButton(
        onPressed: (_selectedFacultyId == null || _isLoading) ? null : _saveAllotment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3F51B5),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Confirm Allotment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _saveAllotment() async {
    setState(() => _isLoading = true);

    try {
      // 1. Get all eligible students
      final studentsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Student')
          .where('branch', isEqualTo: widget.branch)
          .where('semester', isEqualTo: widget.semester)
          .get();

      final studentIds = studentsSnapshot.docs.map((d) => d.id).toList();

      // 2. Save the allotment record - Use subjectId as doc ID for easy lookup
      await FirebaseFirestore.instance.collection('subject_allotments').doc(widget.subjectId).set({
        'subjectId': widget.subjectId,
        'subjectName': widget.subjectName,
        'facultyId': _selectedFacultyId,
        'branch': widget.branch,
        'semester': widget.semester,
        'studentIds': studentIds,
        'allottedAt': FieldValue.serverTimestamp(),
      });

      // 3. Update student docs in batch to show their allotted faculty
      final batch = FirebaseFirestore.instance.batch();
      for (var sid in studentIds) {
        batch.update(FirebaseFirestore.instance.collection('users').doc(sid), {
          'visibleTo.faculty': FieldValue.arrayUnion([_selectedFacultyId])
        });
      }
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subject Allotted Successfully!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
