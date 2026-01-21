import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class FacultyTakeAttendanceScreen extends StatefulWidget {
  final String subjectId;
  final String subjectName;
  final String branch;
  final String semester;

  const FacultyTakeAttendanceScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
    required this.branch,
    required this.semester,
  });

  @override
  State<FacultyTakeAttendanceScreen> createState() => _FacultyTakeAttendanceScreenState();
}

class _FacultyTakeAttendanceScreenState extends State<FacultyTakeAttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  final Map<String, String> _attendanceStatus = {};
  bool _isLoading = false;

  String get _formattedDate => DateFormat('yyyy-MM-dd').format(_selectedDate);

  @override
  void initState() {
    super.initState();
    _loadExistingAttendance();
  }

  Future<void> _loadExistingAttendance() async {
    setState(() => _isLoading = true);
    try {
      final query = await FirebaseFirestore.instance
          .collection('attendance')
          .where('subjectId', isEqualTo: widget.subjectId)
          .where('date', isEqualTo: _formattedDate)
          .get();

      if (query.docs.isNotEmpty) {
        setState(() {
          _attendanceStatus.clear();
          for (var doc in query.docs) {
            final data = doc.data();
            _attendanceStatus[data['studentId']] = data['status'];
          }
        });
      } else {
        setState(() => _attendanceStatus.clear());
      }
    } catch (e) {
      debugPrint('Error loading attendance: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitAttendance() async {
    setState(() => _isLoading = true);
    try {
      final facultyId = FirebaseAuth.instance.currentUser?.uid;
      final batch = FirebaseFirestore.instance.batch();

      _attendanceStatus.forEach((studentId, status) {
        // ID: subjectId_studentId_date
        final docId = '${widget.subjectId}_${studentId}_$_formattedDate';
        final docRef = FirebaseFirestore.instance.collection('attendance').doc(docId);

        batch.set(docRef, {
          'studentId': studentId,
          'subjectId': widget.subjectId,
          'facultyId': facultyId,
          'date': _formattedDate,
          'status': status,
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      await batch.commit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance Submitted Successfully!')));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.subjectName, style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('${widget.branch} • Sem ${widget.semester}', style: GoogleFonts.lato(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
                _loadExistingAttendance();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Date: $_formattedDate', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Total Students: ${_attendanceStatus.length}', style: const TextStyle(color: Colors.blueGrey)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'Student')
                  .where('branch', isEqualTo: widget.branch)
                  .where('semester', isEqualTo: widget.semester)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final students = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index].data() as Map<String, dynamic>;
                    final studentId = students[index].id;
                    final currentStatus = _attendanceStatus[studentId] ?? 'Present';

                    return ListTile(
                      leading: CircleAvatar(child: Text((student['name'] ?? 'S')[0])),
                      title: Text(student['name'] ?? 'Unknown'),
                      subtitle: Text('Roll: ${student['roll'] ?? 'N/A'}'),
                      trailing: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'Present', label: Text('P')),
                          ButtonSegment(value: 'Absent', label: Text('A')),
                        ],
                        selected: {currentStatus},
                        onSelectionChanged: (val) {
                          setState(() {
                            _attendanceStatus[studentId] = val.first;
                          });
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitAttendance,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3F51B5),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: _isLoading 
            ? const CircularProgressIndicator(color: Colors.white) 
            : const Text('Submit Attendance'),
        ),
      ),
    );
  }
}
