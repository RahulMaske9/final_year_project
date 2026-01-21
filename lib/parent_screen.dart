import 'package:flutter/material.dart';
import 'package:first_app/student_data_screen.dart';

class ParentScreen extends StatelessWidget {
  const ParentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentDataScreen(title: 'Parent Panel');
  }
}
