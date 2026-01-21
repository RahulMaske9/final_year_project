import 'package:flutter/material.dart';

class StudentAcademicsScreen extends StatelessWidget {
  const StudentAcademicsScreen({super.key});

  // Dummy data representing the student's academic progress
  final int currentSemester = 4;
  final List<Map<String, dynamic>> subjects = const [
    {
      'name': 'Data Structures & Algorithms',
      'practicals_total': 10,
      'practicals_submitted': 8,
      'assignments_total': 5,
      'assignments_submitted': 5,
    },
    {
      'name': 'Operating Systems',
      'practicals_total': 8,
      'practicals_submitted': 7,
      'assignments_total': 4,
      'assignments_submitted': 3,
    },
    {
      'name': 'Database Management Systems',
      'practicals_total': 12,
      'practicals_submitted': 12,
      'assignments_total': 6,
      'assignments_submitted': 5,
    },
    {
      'name': 'Software Engineering',
      'practicals_total': 5,
      'practicals_submitted': 2,
      'assignments_total': 3,
      'assignments_submitted': 2,
    },
  ];
  final Map<String, String> examSchedule = const {
    'title': 'Mid-Term Examinations',
    'date': 'Starts from 2024-11-10',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSemesterInfoCard(context),
            const SizedBox(height: 24),
            const Text('Subjects & Progress', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...subjects.map((subject) => _buildSubjectCard(context, subject)).toList(),
            const SizedBox(height: 24),
            _buildExamScheduleCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSemesterInfoCard(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.school, size: 40, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current Semester', style: TextStyle(fontSize: 16, color: Colors.black54)),
                Text('$currentSemester', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, Map<String, dynamic> subject) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subject['name'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildProgressIndicator(
              context,
              label: 'Assignments Submitted',
              submitted: subject['assignments_submitted'] as int,
              total: subject['assignments_total'] as int,
            ),
            const SizedBox(height: 12),
            _buildProgressIndicator(
              context,
              label: 'Practicals Submitted',
              submitted: subject['practicals_submitted'] as int,
              total: subject['practicals_total'] as int,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context, {required String label, required int submitted, required int total}) {
    final double progress = total > 0 ? submitted / total : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            Text('$submitted / $total', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }

  Widget _buildExamScheduleCard(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.event_note, size: 40, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(examSchedule['title']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(examSchedule['date']!, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
