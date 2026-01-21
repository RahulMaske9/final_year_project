
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:first_app/parent_list_page.dart';

class ParentYearSelectionScreen extends StatelessWidget {
  final String branch;

  const ParentYearSelectionScreen({super.key, required this.branch});

  @override
  Widget build(BuildContext context) {
    final years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];
    final icons = [Icons.looks_one, Icons.looks_two, Icons.looks_3, Icons.looks_4];
    final colors = [Colors.blue.shade700, Colors.green.shade700, Colors.orange.shade700, Colors.red.shade700];

    return Scaffold(
      appBar: AppBar(
        title: Text('$branch - Select Year', style: GoogleFonts.lato()),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        itemCount: years.length,
        itemBuilder: (context, index) {
          final year = years[index];
          return _buildYearListItem(
            context,
            year: year,
            icon: icons[index],
            color: colors[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ParentListPage(branch: branch, year: year),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildYearListItem(BuildContext context, {required String year, required IconData icon, required Color color, required VoidCallback onTap}) {
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
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  year,
                  style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
