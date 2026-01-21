import 'package:first_app/edit_student_screen.dart';
import 'package:flutter/material.dart';

class FacultyScreen extends StatefulWidget {
  const FacultyScreen({super.key});

  @override
  State<FacultyScreen> createState() => _FacultyScreenState();
}

class _FacultyScreenState extends State<FacultyScreen> {
  // Updated to a more structured mock data list
  final List<Map<String, dynamic>> _students = [
    {
      'id': 'mock_student_101',
      'name': 'Alice',
      'roll': '101',
      'email': 'alice@example.com',
      'course': 'Computer Science',
      'year': '2nd Year'
    },
    {
      'id': 'mock_student_102',
      'name': 'Bob',
      'roll': '102',
      'email': 'bob@example.com',
      'course': 'Mechanical Engineering',
      'year': '3rd Year'
    },
    {
      'id': 'mock_student_103',
      'name': 'Charlie',
      'roll': '103',
      'email': 'charlie@example.com',
      'course': 'Civil Engineering',
      'year': '1st Year'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Panel'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView.builder(
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final studentData = _students[index];
          final studentId = studentData['id'] as String;
          final studentDisplayName = '${studentData['name']} (ID: ${studentData['roll']})';

          return Card(
            child: ListTile(
              title: Text(studentDisplayName),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // Correctly passing studentId and currentData
                      builder: (context) => EditStudentScreen(
                        studentId: studentId,
                        currentData: studentData,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
