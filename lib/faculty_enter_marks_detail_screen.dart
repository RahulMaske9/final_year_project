
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Model for student marks
class StudentMarks {
  final String name;
  final String rollNo;
  final TextEditingController marksController;

  StudentMarks({
    required this.name,
    required this.rollNo,
    String initialMarks = '',
  }) : marksController = TextEditingController(text: initialMarks);
}

class FacultyEnterMarksDetailScreen extends StatefulWidget {
  final String subjectName;

  const FacultyEnterMarksDetailScreen({super.key, required this.subjectName});

  @override
  State<FacultyEnterMarksDetailScreen> createState() =>
      _FacultyEnterMarksDetailScreenState();
}

class _FacultyEnterMarksDetailScreenState
    extends State<FacultyEnterMarksDetailScreen> {
  final List<StudentMarks> _allStudents = [
    StudentMarks(name: 'Anjali Sharma', rollNo: 'CSE-01'),
    StudentMarks(name: 'Karan Verma', rollNo: 'CSE-02'),
    StudentMarks(name: 'Priya Singh', rollNo: 'CSE-03'),
    StudentMarks(name: 'Rahul Gupta', rollNo: 'CSE-04'),
    StudentMarks(name: 'Sneha Reddy', rollNo: 'CSE-05'),
  ];

  List<StudentMarks> _filteredStudents = [];
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
        return student.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    for (var student in _allStudents) {
      student.marksController.dispose();
    }
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subjectName, style: GoogleFonts.lato()),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _filteredStudents.length,
              itemBuilder: (context, index) {
                return StudentMarksCard(student: _filteredStudents[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Logic to save marks
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Marks have been saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
        label: const Text('Save Marks'),
        icon: const Icon(Icons.save),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by student name...',
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

class StudentMarksCard extends StatelessWidget {
  final StudentMarks student;

  const StudentMarksCard({super.key, required this.student});

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
            SizedBox(
              width: 100,
              child: TextField(
                controller: student.marksController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Enter Marks',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
