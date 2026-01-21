import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Achievements', style: GoogleFonts.lato()),
        backgroundColor: const Color(0xFF3F51B5), // Indigo
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade50, Colors.grey.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            _buildAchievementSection(
              context,
              'Certificates',
              Icons.verified_outlined,
              [
                {'title': 'Certificate of Excellence in Science', 'date': '20 Oct 2023'},
                {'title': 'Art Competition - 1st Place', 'date': '15 Sep 2023'},
              ],
              Colors.amber.shade800,
            ),
            const SizedBox(height: 20),
            _buildAchievementSection(
              context,
              'Event Participation',
              Icons.event_outlined,
              [
                {'title': 'Annual Day Function - Dance', 'date': '05 Oct 2023'},
                {'title': 'Debate Competition', 'date': '20 Aug 2023'},
              ],
              Colors.teal.shade700,
            ),
            const SizedBox(height: 20),
            _buildAchievementSection(
              context,
              'Sports Achievements',
              Icons.sports_soccer_outlined,
              [
                {'title': 'Inter-School Football - Winners', 'date': '10 Sep 2023'},
                {'title': 'District Level Athletics - Silver', 'date': '02 Aug 2023'},
              ],
              Colors.green.shade700,
            ),
             const SizedBox(height: 20),
            _buildAchievementSection(
              context,
              'Scholar Achievements',
              Icons.school_outlined,
              [
                {'title': 'Scholar Badge for Academic Year', 'date': '30 Mar 2023'},
                {'title': 'Math Olympiad - Rank 5', 'date': '12 Feb 2023'},
              ],
              Colors.purple.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementSection(BuildContext context, String title, IconData icon, List<Map<String, String>> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildAchievementCard(item['title']!, item['date']!, color)).toList(),
      ],
    );
  }

  Widget _buildAchievementCard(String title, String date, Color color) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.lato(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      date,
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
