
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:first_app/faculty_take_attendance_detail_screen.dart';
import 'package:first_app/faculty_select_batch_screen.dart';

class FacultySelectSubjectPracticalScreen extends StatelessWidget {
  final String year;
  const FacultySelectSubjectPracticalScreen({super.key, required this.year});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {'name': 'Subject 1', 'icon': Icons.book, 'color': Colors.teal.shade700, 'type': 'subject'},
      {'name': 'Subject 2', 'icon': Icons.book_online, 'color': Colors.blueGrey.shade700, 'type': 'subject'},
      {'name': 'Practical', 'icon': Icons.science, 'color': Colors.lightBlue.shade700, 'type': 'practical'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Select for $year', style: GoogleFonts.lato()),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return CustomCard(
            name: item['name'],
            icon: item['icon'],
            color: item['color'],
            onTap: () {
              if (item['type'] == 'subject') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FacultyTakeAttendanceDetailScreen(
                      year: year,
                      selection: item['name'], // Pass subject name
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FacultySelectBatchScreen(
                      year: year,
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const CustomCard({
    super.key,
    required this.name,
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
                  name,
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
