import 'package:flutter/material.dart';
import 'package:first_app/communication_screen.dart';

class ParentCommunicationScreen extends StatelessWidget {
  const ParentCommunicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommunicationScreen(userRole: 'Parent');
  }
}
