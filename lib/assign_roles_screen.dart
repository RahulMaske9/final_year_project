import 'package:flutter/material.dart';

class AssignRolesScreen extends StatefulWidget {
  const AssignRolesScreen({super.key});

  @override
  State<AssignRolesScreen> createState() => _AssignRolesScreenState();
}

class _AssignRolesScreenState extends State<AssignRolesScreen> {
  String? _selectedStudent;
  String? _selectedParent;
  String? _selectedFaculty;
  String? _selectedClass;

  final List<String> _students = ['Alice', 'Bob', 'Charlie'];
  final List<String> _parents = ['Mr. and Mrs. Brown'];
  final List<String> _faculty = ['Mr. Smith', 'Mrs. Jones'];
  final List<String> _classes = ['10th Grade Math', 'B.Sc. Physics'];

  void _assignParentToStudent() {
    if (_selectedStudent != null && _selectedParent != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Assigned Parent: $_selectedParent to Student: $_selectedStudent')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both a student and a parent.')),
      );
    }
  }

  void _assignFacultyToClass() {
    if (_selectedFaculty != null && _selectedClass != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Assigned Faculty: $_selectedFaculty to Class: $_selectedClass')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both a faculty member and a class.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Roles'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Link Student to Parent', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildDropdown('Select Student', _students, _selectedStudent, (val) => setState(() => _selectedStudent = val)),
            const SizedBox(height: 16),
            _buildDropdown('Select Parent', _parents, _selectedParent, (val) => setState(() => _selectedParent = val)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _assignParentToStudent,
              child: const Text('Assign Parent'),
            ),
            const SizedBox(height: 40),
            const Text('Assign Faculty to Class', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildDropdown('Select Faculty', _faculty, _selectedFaculty, (val) => setState(() => _selectedFaculty = val)),
            const SizedBox(height: 16),
            _buildDropdown('Select Class', _classes, _selectedClass, (val) => setState(() => _selectedClass = val)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _assignFacultyToClass,
              child: const Text('Assign Faculty'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint, List<String> items, String? selectedValue, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: hint,
        border: const OutlineInputBorder(),
      ),
      value: selectedValue,
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
