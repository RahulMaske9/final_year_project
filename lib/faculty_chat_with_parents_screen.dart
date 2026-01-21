
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:first_app/faculty_chat_detail_screen.dart';

// Model for parent data
class Parent {
  final String name;
  final String studentName;
  final String studentRollNo;

  Parent({
    required this.name,
    required this.studentName,
    required this.studentRollNo,
  });
}

class FacultyChatWithParentsScreen extends StatefulWidget {
  const FacultyChatWithParentsScreen({super.key});

  @override
  State<FacultyChatWithParentsScreen> createState() =>
      _FacultyChatWithParentsScreenState();
}

class _FacultyChatWithParentsScreenState
    extends State<FacultyChatWithParentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Parent> _filteredParents = [];

  // Dummy data for parents
  final List<Parent> _allParents = [
    Parent(name: 'Mr. Sharma', studentName: 'Anjali Sharma', studentRollNo: 'CSE-01'),
    Parent(name: 'Mr. Verma', studentName: 'Karan Verma', studentRollNo: 'CSE-02'),
    Parent(name: 'Mrs. Singh', studentName: 'Priya Singh', studentRollNo: 'CSE-03'),
    Parent(name: 'Mr. Gupta', studentName: 'Rahul Gupta', studentRollNo: 'CSE-04'),
    Parent(name: 'Mrs. Reddy', studentName: 'Sneha Reddy', studentRollNo: 'CSE-05'),
  ];

  @override
  void initState() {
    super.initState();
    _filteredParents = _allParents;
    _searchController.addListener(_filterParents);
  }

  void _filterParents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredParents = _allParents.where((parent) {
        return parent.name.toLowerCase().contains(query) ||
            parent.studentName.toLowerCase().contains(query) ||
            parent.studentRollNo.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Parents', style: GoogleFonts.lato()),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              itemCount: _filteredParents.length,
              itemBuilder: (context, index) {
                return ParentCard(
                  parent: _filteredParents[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FacultyChatDetailScreen(
                          parent: _filteredParents[index],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by parent, student, or roll no...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade200,
        ),
      ),
    );
  }
}

class ParentCard extends StatelessWidget {
  final Parent parent;
  final VoidCallback onTap;

  const ParentCard({super.key, required this.parent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Icon(Icons.person_outline, size: 32, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parent.name,
                      style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Student: ${parent.studentName} (${parent.studentRollNo})',
                      style: GoogleFonts.lato(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
