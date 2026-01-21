import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Model for subject data
class Subject {
  String id;
  String name;
  String subjectCode;
  String department;

  Subject({
    required this.id,
    required this.name,
    required this.subjectCode,
    required this.department,
  });
}

class ManageSubjectsScreen extends StatefulWidget {
  const ManageSubjectsScreen({super.key});

  @override
  State<ManageSubjectsScreen> createState() => _ManageSubjectsScreenState();
}

class _ManageSubjectsScreenState extends State<ManageSubjectsScreen> {
  // Dummy departments
  final List<String> _departments = ['CSE', 'ECE', 'MECH', 'CIVIL', 'IT', 'AI-DS'];

  // Dummy data
  final List<Subject> _allSubjects = [
    Subject(id: 'S01', name: 'Data Structures', subjectCode: 'CS101', department: 'CSE'),
    Subject(id: 'S02', name: 'Thermodynamics', subjectCode: 'ME101', department: 'MECH'),
    Subject(id: 'S03', name: 'Digital Electronics', subjectCode: 'EC101', department: 'ECE'),
    Subject(id: 'S04', name: 'Communication English', subjectCode: 'ENG101', department: 'CSE'),
  ];

  late List<Subject> _filteredSubjects;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredSubjects = List.from(_allSubjects);
    _searchController.addListener(_filterSubjects);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSubjects() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSubjects = _allSubjects.where((s) {
        return s.name.toLowerCase().contains(query) ||
            s.subjectCode.toLowerCase().contains(query) ||
            s.department.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _addSubject(Subject subject) {
    setState(() {
      _allSubjects.add(subject);
      _filterSubjects();
    });
  }

  void _updateSubject(Subject updatedSubject) {
    setState(() {
      final index = _allSubjects.indexWhere((s) => s.id == updatedSubject.id);
      if (index != -1) {
        _allSubjects[index] = updatedSubject;
        _filterSubjects();
      }
    });
  }

  void _deleteSubject(String id) {
    setState(() {
      _allSubjects.removeWhere((s) => s.id == id);
      _filterSubjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Subjects', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _filteredSubjects.isEmpty ? _buildEmptyState() : _buildSubjectList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSubjectFormDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name, code or department...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.shade100,
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
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No subjects found',
            style: GoogleFonts.lato(fontSize: 18, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 80),
      itemCount: _filteredSubjects.length,
      itemBuilder: (context, index) {
        final subject = _filteredSubjects[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF3F51B5).withOpacity(0.1),
              foregroundColor: const Color(0xFF3F51B5),
              child: const Icon(Icons.book_outlined),
            ),
            title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Code: ${subject.subjectCode}'),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    'Dept: ${subject.department}',
                    style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueGrey),
                  onPressed: () => _showSubjectFormDialog(subject: subject),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _showDeleteConfirmationDialog(subject),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(Subject subject) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete ${subject.name}?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
            onPressed: () {
              _deleteSubject(subject.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${subject.name} deleted successfully.'), backgroundColor: Colors.red),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSubjectFormDialog({Subject? subject}) {
    final isEditing = subject != null;
    final nameController = TextEditingController(text: subject?.name ?? '');
    final codeController = TextEditingController(text: subject?.subjectCode ?? '');
    String selectedDept = subject?.department ?? _departments[0];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isEditing ? 'Edit Subject' : 'Add New Subject'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Subject Name', hintText: 'e.g. Data Structures'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(labelText: 'Subject Code', hintText: 'e.g. CS101'),
                  ),
                  const SizedBox(height: 20),
                  const Text('Select Department', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedDept,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: _departments.map((dept) {
                      return DropdownMenuItem(value: dept, child: Text(dept));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedDept = value);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF3F51B5)),
                child: Text(isEditing ? 'Update' : 'Add'),
                onPressed: () {
                  if (nameController.text.isEmpty || codeController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  }

                  final newSubject = Subject(
                    id: subject?.id ?? DateTime.now().toIso8601String(),
                    name: nameController.text,
                    subjectCode: codeController.text,
                    department: selectedDept,
                  );

                  if (isEditing) {
                    _updateSubject(newSubject);
                  } else {
                    _addSubject(newSubject);
                  }

                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Subject ${isEditing ? 'updated' : 'added'} successfully.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
