import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ParentMarksScreen extends StatelessWidget {
  final String studentId;

  const ParentMarksScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Marks & Results', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Fetching marks for Student ID: $studentId'),
      ),
    );
  }
}
