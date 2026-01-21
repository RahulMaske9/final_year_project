import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ParentAttendanceScreen extends StatelessWidget {
  // ✅ ARCHITECTURE FIX: Accepting the studentId to fetch the correct data.
  final String studentId;

  const ParentAttendanceScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Record', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Fetching attendance for Student ID: $studentId'),
      ),
    );
  }
}
