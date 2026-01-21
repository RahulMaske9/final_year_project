import 'package:flutter/material.dart';
import 'package:first_app/communication_screen.dart';

class StudentCommunicationScreen extends StatelessWidget {
  const StudentCommunicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommunicationScreen(userRole: 'Student');
  }
}
