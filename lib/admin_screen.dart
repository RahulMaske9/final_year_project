import 'package:flutter/material.dart';
import 'package:first_app/create_user_screen.dart';
import 'package:first_app/view_users_screen.dart';
import 'package:first_app/assign_roles_screen.dart';
import 'package:first_app/manage_courses_screen.dart';
import 'package:first_app/manage_subjects_screen.dart';
import 'package:first_app/enroll_students_screen.dart';
import 'package:first_app/broadcast_announcements_screen.dart';
import 'package:first_app/manage_events_screen.dart';
import 'package:first_app/button_styles.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildFeatureCard(
            context,
            title: 'User Management',
            icon: Icons.people_outline,
            actions: ['Create User', 'View/Edit Users', 'Delete User', 'Assign Roles'],
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            title: 'Academic Structure',
            icon: Icons.school_outlined,
            actions: ['Manage Courses', 'Manage Subjects', 'Enroll Students'],
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            title: 'Communication & Announcements',
            icon: Icons.campaign_outlined,
            actions: ['Broadcast Announcements', 'Manage Events'],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, {required String title, required IconData icon, required List<String> actions}) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: actions.map((action) => _buildActionButton(context, action)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String action) {
    return FilledButton(
      style: ButtonStyles.elevatedButtonStyle(context),
      onPressed: () {
        if (action == 'Create User') {
          _showCreateUserDialog(context);
        } else if (action == 'View/Edit Users') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ViewUsersScreen()),
          );
        } else if (action == 'Assign Roles') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AssignRolesScreen()),
          );
        } else if (action == 'Manage Courses') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ManageCoursesScreen()),
          );
        } else if (action == 'Manage Subjects') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ManageSubjectsScreen()),
          );
        } else if (action == 'Enroll Students') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EnrollStudentsScreen()),
          );
        } else if (action == 'Broadcast Announcements') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const BroadcastAnnouncementsScreen()),
          );
        } else if (action == 'Manage Events') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ManageEventsScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$action coming soon!')),
          );
        }
      },
      child: Text(action),
    );
  }

  void _showCreateUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New User'),
          content: const Text('Which type of user would you like to create?'),
          actions: <Widget>[
            FilledButton(
              style: ButtonStyles.elevatedButtonStyle(context),
              child: const Text('Student'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateUserScreen(role: 'Student')));
              },
            ),
            FilledButton(
              style: ButtonStyles.elevatedButtonStyle(context),
              child: const Text('Parent'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateUserScreen(role: 'Parent')));
              },
            ),
            FilledButton(
              style: ButtonStyles.elevatedButtonStyle(context),
              child: const Text('Faculty'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateUserScreen(role: 'Faculty')));
              },
            ),
          ],
        );
      },
    );
  }
}
