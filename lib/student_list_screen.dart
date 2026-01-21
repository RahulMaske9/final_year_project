
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Model for student data
class Student {
  String id;
  String name;
  String studentClass;
  String rollNumber;

  Student({
    required this.id,
    required this.name,
    required this.studentClass,
    required this.rollNumber,
  });
}

class StudentListScreen extends StatefulWidget {
  final String branchName;
  final String year;

  const StudentListScreen({super.key, required this.branchName, required this.year});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  // Dummy data
  final List<Student> _allStudents = [
    Student(id: 'S001', name: 'Aarav Sharma', studentClass: '1st Year', rollNumber: '1'),
    Student(id: 'S002', name: 'Vivaan Singh', studentClass: '1st Year', rollNumber: '2'),
    Student(id: 'S007', name: 'Rohan Joshi', studentClass: '2nd Year', rollNumber: '7'),
    Student(id: 'S003', name: 'Aditya Kumar', studentClass: '2nd Year', rollNumber: '3'),
    Student(id: 'S004', name: 'Diya Gupta', studentClass: '3rd Year', rollNumber: '4'),
    Student(id: 'S005', name: 'Ishaan Patel', studentClass: '4th Year', rollNumber: '5'),
  ];

  late List<Student> _filteredStudents;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredStudents = _allStudents.where((student) => student.studentClass == widget.year).toList();
    _searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = _allStudents.where((student) {
        return (student.studentClass == widget.year) &&
               (student.name.toLowerCase().contains(query) || 
               student.rollNumber.toLowerCase().contains(query));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.branchName} - ${widget.year}', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 4,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _filteredStudents.isEmpty
                ? _buildEmptyState()
                : _buildStudentList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name or roll number...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No students found',
            style: GoogleFonts.lato(fontSize: 18, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 80),
      itemCount: _filteredStudents.length,
      itemBuilder: (context, index) {
        final student = _filteredStudents[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              foregroundColor: Theme.of(context).colorScheme.primary,
              child: Text(student.name[0], style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Roll No: ${student.rollNumber}'),
            trailing: IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blue,),
              onPressed: () {
                // TODO: Implement edit functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Editing ${student.name}')),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
