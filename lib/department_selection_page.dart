import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:first_app/manage_course.dart';

class DepartmentSelectionPage extends StatefulWidget {
  const DepartmentSelectionPage({super.key});

  @override
  State<DepartmentSelectionPage> createState() => _DepartmentSelectionPageState();
}

class _DepartmentSelectionPageState extends State<DepartmentSelectionPage> {
  final List<Map<String, dynamic>> _departments = [
    {'name': 'Computer Science', 'icon': Icons.computer, 'color': Colors.indigo},
    {'name': 'IT', 'icon': Icons.laptop, 'color': Colors.blue},
    {'name': 'Mechanical', 'icon': Icons.settings, 'color': Colors.orange},
    {'name': 'Civil', 'icon': Icons.construction, 'color': Colors.green},
    {'name': 'Electronics', 'icon': Icons.memory, 'color': Colors.red},
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredDepts = _departments.where((dept) {
      return dept['name'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Select Department', 
          style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: filteredDepts.length,
              itemBuilder: (context, index) {
                final dept = filteredDepts[index];
                return _buildDepartmentCard(dept['name'], dept['icon'], dept['color']);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF3F51B5),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SIPNA COET Portal',
            style: GoogleFonts.lato(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage Courses & Faculty',
            style: GoogleFonts.lato(
              color: Colors.white, 
              fontSize: 24, 
              fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search departments...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF3F51B5)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildDepartmentCard(String name, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManageCourseScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'View Subjects',
              style: GoogleFonts.lato(
                fontSize: 12, 
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
