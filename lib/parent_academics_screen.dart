import 'package:flutter/material.dart';

class ParentAcademicsScreen extends StatelessWidget {
  final String studentId;

  const ParentAcademicsScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Academics for student $studentId'),
    );
  }
}
