
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Model for parent data
class Parent {
  String id;
  String name;
  String studentName;
  String studentId;

  Parent({required this.id, required this.name, required this.studentName, required this.studentId});
}

class ManageParentsScreen extends StatefulWidget {
  const ManageParentsScreen({super.key});

  @override
  State<ManageParentsScreen> createState() => _ManageParentsScreenState();
}

class _ManageParentsScreenState extends State<ManageParentsScreen> {
  // Dummy data
  final List<Parent> _allParents = [
    Parent(id: 'P001', name: 'Mr. Sharma', studentName: 'Aarav Sharma', studentId: 'S001'),
    Parent(id: 'P002', name: 'Mr. Singh', studentName: 'Vivaan Singh', studentId: 'S002'),
    Parent(id: 'P003', name: 'Mr. Kumar', studentName: 'Aditya Kumar', studentId: 'S003'),
    Parent(id: 'P004', name: 'Mrs. Gupta', studentName: 'Diya Gupta', studentId: 'S004'),
  ];

  late List<Parent> _filteredParents;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredParents = _allParents;
    _searchController.addListener(_filterParents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterParents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredParents = _allParents.where((parent) {
        return parent.name.toLowerCase().contains(query) ||
               parent.studentName.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _addParent(Parent parent) {
    setState(() {
      _allParents.add(parent);
      _filterParents();
    });
  }

  void _updateParent(Parent updatedParent) {
    setState(() {
      final index = _allParents.indexWhere((p) => p.id == updatedParent.id);
      if (index != -1) {
        _allParents[index] = updatedParent;
        _filterParents();
      }
    });
  }

  void _deleteParent(String id) {
    setState(() {
      _allParents.removeWhere((parent) => parent.id == id);
      _filterParents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Parents', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 4,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _filteredParents.isEmpty
                ? _buildEmptyState()
                : _buildParentList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showParentFormDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Parent'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by parent or student name...',
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
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No parents found',
            style: GoogleFonts.lato(fontSize: 18, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildParentList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 80), // Space for FAB
      itemCount: _filteredParents.length,
      itemBuilder: (context, index) {
        final parent = _filteredParents[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              foregroundColor: Theme.of(context).colorScheme.primary,
              child: Text(parent.name[0], style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Text(parent.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Student: ${parent.studentName} (ID: ${parent.studentId})'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueGrey),
                  onPressed: () => _showParentFormDialog(parent: parent),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _showDeleteConfirmationDialog(parent),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(Parent parent) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete ${parent.name}?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
            onPressed: () {
              _deleteParent(parent.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${parent.name} deleted successfully.'), backgroundColor: Colors.red),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showParentFormDialog({Parent? parent}) {
    final isEditing = parent != null;
    final nameController = TextEditingController(text: parent?.name ?? '');
    final studentNameController = TextEditingController(text: parent?.studentName ?? '');
    final studentIdController = TextEditingController(text: parent?.studentId ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Edit Parent' : 'Add New Parent'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Parent Name')),
              TextField(controller: studentNameController, decoration: const InputDecoration(labelText: 'Student Name')),
              TextField(controller: studentIdController, decoration: const InputDecoration(labelText: 'Student ID')),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          FilledButton(
            child: Text(isEditing ? 'Update' : 'Add'),
            onPressed: () {
              final newParent = Parent(
                id: parent?.id ?? DateTime.now().toIso8601String(),
                name: nameController.text,
                studentName: studentNameController.text,
                studentId: studentIdController.text,
              );
              
              if (isEditing) {
                _updateParent(newParent);
              } else {
                _addParent(newParent);
              }

              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(
                  content: Text('Parent ${isEditing ? 'updated' : 'added'} successfully.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
