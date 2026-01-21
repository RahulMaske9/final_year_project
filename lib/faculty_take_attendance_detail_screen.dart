
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Model for student attendance
class StudentAttendance {
  final String name;
  final String rollNo;
  final String batch;
  AttendanceStatus status;

  StudentAttendance({
    required this.name,
    required this.rollNo,
    required this.batch,
    this.status = AttendanceStatus.present,
  });
}

enum AttendanceStatus { present, absent }

class FacultyTakeAttendanceDetailScreen extends StatefulWidget {
  final String year;
  final String selection;

  const FacultyTakeAttendanceDetailScreen({super.key, required this.year, required this.selection});

  @override
  State<FacultyTakeAttendanceDetailScreen> createState() =>
      _FacultyTakeAttendanceDetailScreenState();
}

class _FacultyTakeAttendanceDetailScreenState
    extends State<FacultyTakeAttendanceDetailScreen> {
  late List<StudentAttendance> _students;

  @override
  void initState() {
    super.initState();
    _students = _getStudentsForSelection();
  }

  List<StudentAttendance> _getStudentsForSelection() {
    final allStudents = [
      StudentAttendance(name: 'Anjali Sharma', rollNo: '1', batch: 'Batch 1'),
      StudentAttendance(name: 'Karan Verma', rollNo: '2', batch: 'Batch 1'),
      StudentAttendance(name: 'Priya Singh', rollNo: '3', batch: 'Batch 1'),
      StudentAttendance(name: 'Rahul Gupta', rollNo: '4', batch: 'Batch 1'),
      StudentAttendance(name: 'Sneha Reddy', rollNo: '5', batch: 'Batch 1'),
      StudentAttendance(name: 'Amit Kumar', rollNo: '6', batch: 'Batch 1'),
      StudentAttendance(name: 'Pooja Desai', rollNo: '7', batch: 'Batch 1'),
      StudentAttendance(name: 'Rohit Patil', rollNo: '8', batch: 'Batch 1'),
      StudentAttendance(name: 'Natasha Mehta', rollNo: '9', batch: 'Batch 1'),
      StudentAttendance(name: 'Sandeep Jain', rollNo: '10', batch: 'Batch 1'),
      StudentAttendance(name: 'Student 11', rollNo: '11', batch: 'Batch 2'),
      StudentAttendance(name: 'Student 12', rollNo: '12', batch: 'Batch 2'),
      StudentAttendance(name: 'Student 13', rollNo: '13', batch: 'Batch 2'),
      StudentAttendance(name: 'Student 14', rollNo: '14', batch: 'Batch 2'),
      StudentAttendance(name: 'Student 15', rollNo: '15', batch: 'Batch 2'),
      StudentAttendance(name: 'Student 16', rollNo: '16', batch: 'Batch 2'),
      StudentAttendance(name: 'Student 17', rollNo: '17', batch: 'Batch 2'),
      StudentAttendance(name: 'Student 18', rollNo: '18', batch: 'Batch 2'),
      StudentAttendance(name: 'Student 19', rollNo: '19', batch: 'Batch 2'),
      StudentAttendance(name: 'Student 20', rollNo: '20', batch: 'Batch 2'),
      StudentAttendance(name: 'Student 21', rollNo: '21', batch: 'Batch 3'),
      StudentAttendance(name: 'Student 22', rollNo: '22', batch: 'Batch 3'),
      StudentAttendance(name: 'Student 23', rollNo: '23', batch: 'Batch 3'),
      StudentAttendance(name: 'Student 24', rollNo: '24', batch: 'Batch 3'),
      StudentAttendance(name: 'Student 25', rollNo: '25', batch: 'Batch 3'),
      StudentAttendance(name: 'Student 26', rollNo: '26', batch: 'Batch 3'),
      StudentAttendance(name: 'Student 27', rollNo: '27', batch: 'Batch 3'),
      StudentAttendance(name: 'Student 28', rollNo: '28', batch: 'Batch 3'),
      StudentAttendance(name: 'Student 29', rollNo: '29', batch: 'Batch 3'),
      StudentAttendance(name: 'Student 30', rollNo: '30', batch: 'Batch 3'),
    ];

    if (widget.selection.startsWith('Batch')) {
      return allStudents.where((s) => s.batch == widget.selection).toList();
    } else {
      // For 'Subject 1' or 'Subject 2', return all students for simplicity
      return allStudents;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.year} - ${widget.selection}', style: GoogleFonts.lato()),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        itemCount: _students.length,
        itemBuilder: (context, index) {
          return StudentAttendanceCard(
            student: _students[index],
            onStatusChanged: (status) {
              setState(() {
                _students[index].status = status;
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Attendance has been saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
        label: const Text('Save Attendance'),
        icon: const Icon(Icons.save),
      ),
    );
  }
}

class StudentAttendanceCard extends StatelessWidget {
  final StudentAttendance student;
  final ValueChanged<AttendanceStatus> onStatusChanged;

  const StudentAttendanceCard({
    super.key,
    required this.student,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name, style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Roll No: ${student.rollNo}', style: GoogleFonts.lato(color: Colors.black54)),
                ],
              ),
            ),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Present'),
                  selected: student.status == AttendanceStatus.present,
                  onSelected: (selected) {
                    if (selected) onStatusChanged(AttendanceStatus.present);
                  },
                  selectedColor: Colors.green.shade100,
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Absent'),
                  selected: student.status == AttendanceStatus.absent,
                  onSelected: (selected) {
                    if (selected) onStatusChanged(AttendanceStatus.absent);
                  },
                  selectedColor: Colors.red.shade100,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
