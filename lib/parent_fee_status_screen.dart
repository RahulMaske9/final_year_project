import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ParentFeeStatusScreen extends StatelessWidget {
  // ✅ ARCHITECTURE FIX: Accepting the studentId to fetch the correct data.
  final String studentId;

  const ParentFeeStatusScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fee Status', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Fetching fee status for Student ID: $studentId'),
      ),
    );
  }
}
