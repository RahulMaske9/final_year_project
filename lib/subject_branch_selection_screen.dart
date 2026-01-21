
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:first_app/subject_year_selection_screen.dart';

class SubjectBranchSelectionScreen extends StatelessWidget {
  const SubjectBranchSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final branches = [
      {'name': 'IT', 'icon': Icons.computer, 'color': Colors.blue.shade700},
      {'name': 'CSE', 'icon': Icons.code, 'color': Colors.green.shade700},
      {'name': 'EXTC', 'icon': Icons.router, 'color': Colors.orange.shade700},
      {'name': 'CIVIL', 'icon': Icons.domain, 'color': Colors.red.shade700},
      {'name': 'MECHANICAL', 'icon': Icons.settings, 'color': Colors.purple.shade700},
      {'name': 'AIDS', 'icon': Icons.analytics, 'color': Colors.teal.shade700},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Branch', style: GoogleFonts.lato()),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        itemCount: branches.length,
        itemBuilder: (context, index) {
          final branch = branches[index];
          return _buildBranchListItem(context, branch['name'] as String, branch['icon'] as IconData, branch['color'] as Color, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SubjectYearSelectionScreen(branch: branch['name'] as String)),
            );
          });
        },
      ),
    );
  }

  Widget _buildBranchListItem(BuildContext context, String branchName, IconData icon, Color color, VoidCallback onTap) {
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
                  branchName,
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
