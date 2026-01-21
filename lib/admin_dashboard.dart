
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:first_app/branch_selection_screen.dart';
import 'package:first_app/manage_faculty_screen.dart';
import 'package:first_app/post_notice_screen.dart';
import 'package:first_app/department_selection_page.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard', style: GoogleFonts.lato()),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        children: [
          AdminCard(
            title: 'Manage Student',
            icon: Icons.group,
            color: Colors.blue.shade700,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BranchSelectionScreen()),
              );
            },
          ),
          AdminCard(
            title: 'Manage Faculty',
            icon: Icons.person,
            color: Colors.green.shade700,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageFacultyScreen()),
              );
            },
          ),
          AdminCard(
            title: 'Manage Course',
            icon: Icons.book,
            color: Colors.purple.shade700,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DepartmentSelectionPage()),
              );
            },
          ),
          AdminCard(
            title: 'Post Notice',
            icon: Icons.campaign,
            color: Colors.orange.shade700,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PostNoticeScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AdminCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const AdminCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

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
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
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
