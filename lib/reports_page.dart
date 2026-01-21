
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = [
      {'title': 'Attendance Reports', 'icon': Icons.check_circle_outline, 'color': Colors.blue.shade700},
      {'title': 'Fee Collection Reports', 'icon': Icons.monetization_on_outlined, 'color': Colors.green.shade700},
      {'title': 'Examination Results', 'icon': Icons.assessment_outlined, 'color': Colors.orange.shade700},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Generate Reports', style: GoogleFonts.lato()),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return _buildReportCard(context, report['title'] as String, report['icon'] as IconData, report['color'] as Color, () {
            // Placeholder for report generation
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Generating ${report['title']}')),
            );
          });
        },
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(title, style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
