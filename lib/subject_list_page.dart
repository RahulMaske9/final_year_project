
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Dummy data model for a Subject
class Subject {
  final String subjectName;
  final String subjectCode;

  Subject({required this.subjectName, required this.subjectCode});
}

class SubjectListPage extends StatefulWidget {
  final String branch;
  final String year;

  const SubjectListPage({super.key, required this.branch, required this.year});

  @override
  State<SubjectListPage> createState() => _SubjectListPageState();
}

class _SubjectListPageState extends State<SubjectListPage> {
  // Dummy data for subjects
  final List<Subject> _subjects = [
    Subject(subjectName: 'Data Structures', subjectCode: 'CS301'),
    Subject(subjectName: 'Algorithms', subjectCode: 'CS302'),
    Subject(subjectName: 'Database Management', subjectCode: 'CS303'),
    Subject(subjectName: 'Operating Systems', subjectCode: 'CS304'),
  ];

  void _addSubject() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Subject'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Subject Name')),
              TextField(controller: codeController, decoration: const InputDecoration(labelText: 'Subject Code')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final subjectName = nameController.text;
                final subjectCode = codeController.text;

                if (subjectName.isNotEmpty && subjectCode.isNotEmpty) {
                  setState(() {
                    _subjects.add(Subject(subjectName: subjectName, subjectCode: subjectCode));
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editSubject(Subject subject) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Editing ${subject.subjectName}')));
  }

  void _deleteSubject(Subject subject) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete ${subject.subjectName}?'),
          actions: <Widget>[
            TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                setState(() {
                  _subjects.remove(subject);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${subject.subjectName} deleted')));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.branch} - ${widget.year} Subjects', style: GoogleFonts.lato()),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        itemCount: _subjects.length,
        itemBuilder: (context, index) => _buildSubjectCard(_subjects[index]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSubject,
        tooltip: 'Add Subject',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSubjectCard(Subject subject) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.purple.withOpacity(0.1),
              child: const Icon(Icons.subject, color: Colors.purple),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subject.subjectName, style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Code: ${subject.subjectCode}', style: GoogleFonts.lato(fontSize: 14, color: Colors.black54)),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _editSubject(subject), tooltip: 'Edit'),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteSubject(subject), tooltip: 'Delete'),
          ],
        ),
      ),
    );
  }
}
