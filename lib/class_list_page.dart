
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Dummy data model for a Class Section
class ClassSection {
  final String sectionName;

  ClassSection({required this.sectionName});
}

class ClassListPage extends StatefulWidget {
  final String branch;
  final String year;

  const ClassListPage({super.key, required this.branch, required this.year});

  @override
  State<ClassListPage> createState() => _ClassListPageState();
}

class _ClassListPageState extends State<ClassListPage> {
  // Dummy data for class sections
  final List<ClassSection> _sections = [
    ClassSection(sectionName: 'Section A'),
    ClassSection(sectionName: 'Section B'),
  ];

  void _addSection() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Section'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Section Name'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final sectionName = nameController.text;
                if (sectionName.isNotEmpty) {
                  setState(() {
                    _sections.add(ClassSection(sectionName: sectionName));
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

  void _editSection(ClassSection section) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Editing ${section.sectionName}')));
  }

  void _deleteSection(ClassSection section) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete ${section.sectionName}?'),
          actions: <Widget>[
            TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                setState(() {
                  _sections.remove(section);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${section.sectionName} deleted')));
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
        title: Text('${widget.branch} - ${widget.year} Classes', style: GoogleFonts.lato()),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        itemCount: _sections.length,
        itemBuilder: (context, index) => _buildClassCard(_sections[index]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSection,
        tooltip: 'Add Section',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildClassCard(ClassSection section) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.deepPurple.withOpacity(0.1),
              child: const Icon(Icons.class_, color: Colors.deepPurple),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(section.sectionName, style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _editSection(section), tooltip: 'Edit'),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteSection(section), tooltip: 'Delete'),
          ],
        ),
      ),
    );
  }
}
