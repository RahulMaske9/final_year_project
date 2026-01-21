
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// A model class for student data
class StudentAssignmentStatus {
  String name;
  String rollNo;
  SubmissionStatus status;

  StudentAssignmentStatus({
    required this.name,
    required this.rollNo,
    this.status = SubmissionStatus.notSubmitted,
  });
}

enum SubmissionStatus { submitted, notSubmitted }

class FacultyManageAssignmentsScreen extends StatefulWidget {
  const FacultyManageAssignmentsScreen({super.key});

  @override
  State<FacultyManageAssignmentsScreen> createState() =>
      _FacultyManageAssignmentsScreenState();
}

class _FacultyManageAssignmentsScreenState
    extends State<FacultyManageAssignmentsScreen> {
  // Dummy data for students
  final List<StudentAssignmentStatus> _allStudents = [
    StudentAssignmentStatus(name: 'Anjali Sharma', rollNo: 'CSE-01'),
    StudentAssignmentStatus(name: 'Karan Verma', rollNo: 'CSE-02', status: SubmissionStatus.submitted),
    StudentAssignmentStatus(name: 'Priya Singh', rollNo: 'CSE-03'),
    StudentAssignmentStatus(name: 'Rahul Gupta', rollNo: 'CSE-04'),
    StudentAssignmentStatus(name: 'Sneha Reddy', rollNo: 'CSE-05', status: SubmissionStatus.submitted),
    StudentAssignmentStatus(name: 'Amit Kumar', rollNo: 'CSE-06'),
    StudentAssignmentStatus(name: 'Pooja Desai', rollNo: 'CSE-07'),
    StudentAssignmentStatus(name: 'Rohit Patil', rollNo: 'CSE-08'),
    StudentAssignmentStatus(name: 'Natasha Mehta', rollNo: 'CSE-09', status: SubmissionStatus.submitted),
    StudentAssignmentStatus(name: 'Sandeep Jain', rollNo: 'CSE-10'),
  ];

  List<StudentAssignmentStatus> _filteredStudents = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredStudents = _allStudents;
    _searchController.addListener(_filterStudents);
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = _allStudents.where((student) {
        return student.name.toLowerCase().contains(query) ||
               student.rollNo.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Assignments', style: GoogleFonts.lato()),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              itemCount: _filteredStudents.length,
              itemBuilder: (context, index) {
                return StudentAssignmentCard(
                  student: _filteredStudents[index],
                  onStatusChanged: (status) {
                    setState(() {
                      _filteredStudents[index].status = status;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Logic to save the updated statuses
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Assignment statuses saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
        label: const Text('Save Status'),
        icon: const Icon(Icons.save),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name or roll number...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade200,
        ),
      ),
    );
  }
}

class StudentAssignmentCard extends StatelessWidget {
  final StudentAssignmentStatus student;
  final ValueChanged<SubmissionStatus> onStatusChanged;

  const StudentAssignmentCard({
    super.key,
    required this.student,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              student.name,
              style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Roll No: ${student.rollNo}',
              style: GoogleFonts.lato(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilterChip(
                  label: const Text('Submitted'),
                  selected: student.status == SubmissionStatus.submitted,
                  onSelected: (selected) {
                    if (selected) onStatusChanged(SubmissionStatus.submitted);
                  },
                  selectedColor: Colors.green.shade100,
                  checkmarkColor: Colors.green.shade900,
                  labelStyle: TextStyle(
                    color: student.status == SubmissionStatus.submitted ? Colors.green.shade900 : Colors.black54,
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Not Submitted'),
                  selected: student.status == SubmissionStatus.notSubmitted,
                  onSelected: (selected) {
                    if (selected) onStatusChanged(SubmissionStatus.notSubmitted);
                  },
                  selectedColor: Colors.red.shade100,
                  checkmarkColor: Colors.red.shade900,
                   labelStyle: TextStyle(
                    color: student.status == SubmissionStatus.notSubmitted ? Colors.red.shade900 : Colors.black54,
                     fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
