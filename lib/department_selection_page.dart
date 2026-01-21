import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DepartmentSelectionPage extends StatefulWidget {
  const DepartmentSelectionPage({super.key});

  @override
  State<DepartmentSelectionPage> createState() => _DepartmentSelectionPageState();
}

class _DepartmentSelectionPageState extends State<DepartmentSelectionPage> {
  final List<Map<String, dynamic>> _departments = [
    {'name': 'Computer Science', 'icon': Icons.computer},
    {'name': 'Mechanical Engineering', 'icon': Icons.settings},
    {'name': 'Civil Engineering', 'icon': Icons.construction},
    {'name': 'Electrical Engineering', 'icon': Icons.electrical_services},
    {'name': 'Electronics & Comm.', 'icon': Icons.router},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Department', style: GoogleFonts.lato()),
        backgroundColor: const Color(0xFF3F51B5), // Indigo
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.2,
                ),
                itemCount: _departments.length,
                itemBuilder: (context, index) {
                  final department = _departments[index];
                  return _buildDepartmentCard(department['name']!, department['icon']!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search departments...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDepartmentCard(String name, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to year selection page for this department
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF3F51B5)),
            const SizedBox(height: 12),
            Text(
              name,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
