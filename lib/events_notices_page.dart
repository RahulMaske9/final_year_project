import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventsNoticesPage extends StatelessWidget {
  const EventsNoticesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notices = [
      {
        'title': 'Parent-Teacher Meeting',
        'date': 'November 15, 2023',
        'description': 'A meeting to discuss the mid-term progress of students.',
      },
      {
        'title': 'Annual Sports Day',
        'date': 'December 02, 2023',
        'description': 'All parents are invited to cheer for our young athletes.',
      },
      {
        'title': 'Winter Vacation',
        'date': 'December 22, 2023 - January 05, 2024',
        'description': 'The school will remain closed for the winter break.',
      },
      {
        'title': 'Science Fair',
        'date': 'January 15, 2024',
        'description': 'Exhibition of science projects by students of all grades.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Events & Notices', style: GoogleFonts.lato()),
        backgroundColor: const Color(0xFF3F51B5), // Indigo
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFFF5F7FA), const Color(0xFFE9EBEE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(20.0),
          itemCount: notices.length,
          itemBuilder: (context, index) {
            final notice = notices[index];
            return _buildNoticeCard(notice['title']!, notice['date']!, notice['description']!);
          },
        ),
      ),
    );
  }

  Widget _buildNoticeCard(String title, String date, String description) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3F51B5),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  date,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: GoogleFonts.lato(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
