
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:first_app/faculty_take_attendance_detail_screen.dart';

class FacultySelectBatchScreen extends StatelessWidget {
  final String year;
  const FacultySelectBatchScreen({super.key, required this.year});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> batches = [
      {'name': 'Batch 1', 'icon': Icons.filter_1, 'color': Colors.purple.shade700},
      {'name': 'Batch 2', 'icon': Icons.filter_2, 'color': Colors.indigo.shade700},
      {'name': 'Batch 3', 'icon': Icons.filter_3, 'color': Colors.blue.shade700},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Batch for $year', style: GoogleFonts.lato()),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        itemCount: batches.length,
        itemBuilder: (context, index) {
          final batch = batches[index];
          return CustomCard(
            name: batch['name'],
            icon: batch['icon'],
            color: batch['color'],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FacultyTakeAttendanceDetailScreen(
                    year: year,
                    selection: batch['name'], // Pass batch name
                  ),
                ),
              );
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
