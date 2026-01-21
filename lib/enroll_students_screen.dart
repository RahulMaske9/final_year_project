import 'package:flutter/material.dart';

class EnrollStudentsScreen extends StatefulWidget {
  const EnrollStudentsScreen({super.key});

  @override
  State<EnrollStudentsScreen> createState() => _EnrollStudentsScreenState();
}

class _EnrollStudentsScreenState extends State<EnrollStudentsScreen> {
  String? _selectedStudent;
  String? _selectedClass;

  final List<String> _students = ['Alice', 'Bob', 'Charlie'];
  final List<String> _classes = ['10th Grade Math', 'B.Sc. Physics'];

  void _enrollStudent() {
    if (_selectedStudent != null && _selectedClass != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enrolled $_selectedStudent in $_selectedClass')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both a student and a class.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enroll Students'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdown('Select Student', _students, _selectedStudent, (val) => setState(() => _selectedStudent = val)),
            const SizedBox(height: 16),
            _buildDropdown('Select Class', _classes, _selectedClass, (val) => setState(() => _selectedClass = val)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _enrollStudent,
              child: const Text('Enroll Student'),
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
