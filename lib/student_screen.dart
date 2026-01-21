import 'package:flutter/material.dart';
import 'package:first_app/student_data_screen.dart';

class StudentScreen extends StatelessWidget {
  const StudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentDataScreen(title: 'Student Panel');
  }
}
