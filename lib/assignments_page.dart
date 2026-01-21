import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AssignmentsPage extends StatelessWidget {
  const AssignmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assignments', style: GoogleFonts.lato()),
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
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            _buildAssignmentCard(
              'Mathematics',
              'Chapter 5: Linear Equations',
              'Due on: 25 Oct 2023',
              'Submitted',
              Colors.green,
            ),
            _buildAssignmentCard(
              'Science',
              'Lab Report: Photosynthesis',
              'Due on: 28 Oct 2023',
              'Pending',
              Colors.orange,
            ),
            _buildAssignmentCard(
              'History',
              'Essay: The Roman Empire',
              'Due on: 02 Nov 2023',
              'Pending',
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(String subject, String title, String dueDate, String status, Color color) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 20.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subject,
              style: GoogleFonts.lato(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: color
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.lato(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dueDate,
                  style: GoogleFonts.lato(fontSize: 14, color: Colors.grey.shade600),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: status == 'Submitted' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.lato(
                      color: status == 'Submitted' ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
