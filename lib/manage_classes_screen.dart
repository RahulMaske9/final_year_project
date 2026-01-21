
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Model for class data
class SchoolClass {
  String id;
  String name;
  String? roomNumber;

  SchoolClass({required this.id, required this.name, this.roomNumber});
}

class ManageClassesScreen extends StatefulWidget {
  const ManageClassesScreen({super.key});

  @override
  State<ManageClassesScreen> createState() => _ManageClassesScreenState();
}

class _ManageClassesScreenState extends State<ManageClassesScreen> {
  // Dummy data
  final List<SchoolClass> _allClasses = [
    SchoolClass(id: 'C01', name: '10 A', roomNumber: '201'),
    SchoolClass(id: 'C02', name: '10 B', roomNumber: '202'),
    SchoolClass(id: 'C03', name: '12 B (Commerce)', roomNumber: '301'),
    SchoolClass(id: 'C04', name: '11 A (Science)', roomNumber: '305'),
  ];

  late List<SchoolClass> _filteredClasses;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredClasses = _allClasses;
    _searchController.addListener(_filterClasses);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterClasses() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredClasses = _allClasses.where((c) {
        return c.name.toLowerCase().contains(query) || (c.roomNumber?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  void _addClass(SchoolClass schoolClass) {
    setState(() {
      _allClasses.add(schoolClass);
      _filterClasses();
    });
  }

  void _updateClass(SchoolClass updatedClass) {
    setState(() {
      final index = _allClasses.indexWhere((c) => c.id == updatedClass.id);
      if (index != -1) {
        _allClasses[index] = updatedClass;
        _filterClasses();
      }
    });
  }

  void _deleteClass(String id) {
    setState(() {
      _allClasses.removeWhere((c) => c.id == id);
      _filterClasses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Classes', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 4,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _filteredClasses.isEmpty
                ? _buildEmptyState()
                : _buildClassList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showClassFormDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Class'),
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
          hintText: 'Search by class name or room...',
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
            'No classes found',
            style: GoogleFonts.lato(fontSize: 18, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildClassList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 80),
      itemCount: _filteredClasses.length,
      itemBuilder: (context, index) {
        final schoolClass = _filteredClasses[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              foregroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.class_outlined),
            ),
            title: Text(schoolClass.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Room No: ${schoolClass.roomNumber ?? 'N/A'}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueGrey),
                  onPressed: () => _showClassFormDialog(schoolClass: schoolClass),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _showDeleteConfirmationDialog(schoolClass),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(SchoolClass schoolClass) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete ${schoolClass.name}?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
            onPressed: () {
              _deleteClass(schoolClass.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${schoolClass.name} deleted successfully.'), backgroundColor: Colors.red),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showClassFormDialog({SchoolClass? schoolClass}) {
    final isEditing = schoolClass != null;
    final nameController = TextEditingController(text: schoolClass?.name ?? '');
    final roomController = TextEditingController(text: schoolClass?.roomNumber ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Edit Class' : 'Add New Class'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Class Name (e.g., 10 A)')),
              TextField(controller: roomController, decoration: const InputDecoration(labelText: 'Room Number')),
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
              final newClass = SchoolClass(
                id: schoolClass?.id ?? DateTime.now().toIso8601String(),
                name: nameController.text,
                roomNumber: roomController.text,
              );
              
              if (isEditing) {
                _updateClass(newClass);
              } else {
                _addClass(newClass);
              }

              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(
                  content: Text('Class ${isEditing ? 'updated' : 'added'} successfully.'),
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
