import 'package:flutter/material.dart';

class ParentProfileScreen extends StatelessWidget {
  final String studentId;
  final Map<String, dynamic> studentData;

  const ParentProfileScreen({
    super.key,
    required this.studentId,
    required this.studentData,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Profile for ${studentData['name'] ?? 'Unknown'}'),
          Text('Student ID: $studentId'),
        ],
      ),
    );
  }
}
