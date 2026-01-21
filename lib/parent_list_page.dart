
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Dummy data model for a Parent-Student link
class ParentStudentLink {
  final String parentName;
  final String studentName;
  final int studentRollNo;

  ParentStudentLink({
    required this.parentName,
    required this.studentName,
    required this.studentRollNo,
  });
}

class ParentListPage extends StatefulWidget {
  final String branch;
  final String year;

  const ParentListPage({super.key, required this.branch, required this.year});

  @override
  State<ParentListPage> createState() => _ParentListPageState();
}

class _ParentListPageState extends State<ParentListPage> {
  // Dummy data for parent-student links
  final List<ParentStudentLink> _allParents = List.generate(
    15,
    (index) => ParentStudentLink(
      parentName: 'Parent of Student ${index + 1}',
      studentName: 'Student ${index + 1}',
      studentRollNo: index + 1,
    ),
  );

  List<ParentStudentLink> _filteredParents = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredParents = _allParents;
    _searchController.addListener(_filterParents);
  }

  void _filterParents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredParents = _allParents.where((link) {
        return link.parentName.toLowerCase().contains(query) ||
            link.studentName.toLowerCase().contains(query) ||
            link.studentRollNo.toString().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addParent() {
    final parentNameController = TextEditingController();
    final studentNameController = TextEditingController();
    final rollNoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Parent-Student Link'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: parentNameController, decoration: const InputDecoration(labelText: 'Parent Name')),
              TextField(controller: studentNameController, decoration: const InputDecoration(labelText: 'Student Name')),
              TextField(controller: rollNoController, decoration: const InputDecoration(labelText: 'Student Roll Number'), keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final parentName = parentNameController.text;
                final studentName = studentNameController.text;
                final rollNo = int.tryParse(rollNoController.text);

                if (parentName.isNotEmpty && studentName.isNotEmpty && rollNo != null) {
                  setState(() {
                    _allParents.add(ParentStudentLink(parentName: parentName, studentName: studentName, studentRollNo: rollNo));
                    _filterParents();
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

  void _editParent(ParentStudentLink link) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Editing ${link.parentName}')));
  }

  void _deleteParent(ParentStudentLink link) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete the record for ${link.parentName}?'),
          actions: <Widget>[
            TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                setState(() {
                  _allParents.remove(link);
                  _filterParents();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Record for ${link.parentName} deleted')));
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
        title: Text('${widget.branch} - ${widget.year} Parents', style: GoogleFonts.lato()),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by parent, student, or roll no...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              itemCount: _filteredParents.length,
              itemBuilder: (context, index) => _buildParentCard(_filteredParents[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addParent,
        tooltip: 'Add Parent',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildParentCard(ParentStudentLink link) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: const Icon(Icons.family_restroom, color: Colors.deepOrange),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(link.parentName, style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Student: ${link.studentName} (Roll: ${link.studentRollNo})', style: GoogleFonts.lato(fontSize: 14, color: Colors.black54)),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _editParent(link), tooltip: 'Edit'),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteParent(link), tooltip: 'Delete'),
          ],
        ),
      ),
    );
  }
}
