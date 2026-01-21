import 'package:flutter/material.dart';

class StudentDataScreen extends StatelessWidget {
  final String title;

  const StudentDataScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {'title': 'Marks', 'icon': Icons.bar_chart},
      {'title': 'Attendance', 'icon': Icons.checklist},
      {'title': 'Assignments', 'icon': Icons.assignment},
      {'title': 'Important Updates', 'icon': Icons.update},
      {'title': 'Projects', 'icon': Icons.work},
      {'title': 'Sports', 'icon': Icons.sports_basketball},
      {'title': 'Achievements', 'icon': Icons.emoji_events},
      {'title': 'Timetable', 'icon': Icons.schedule},
      {'title': 'Class Schedule', 'icon': Icons.calendar_today},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView.builder(
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return Card(
            child: ListTile(
              leading: Icon(item['icon'] as IconData?),
              title: Text(item['title'] as String),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item['title']} coming soon!')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
