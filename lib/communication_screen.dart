import 'package:flutter/material.dart';

class CommunicationScreen extends StatelessWidget {
  final String userRole;

  const CommunicationScreen({super.key, required this.userRole});

  // Dummy data
  final List<Map<String, String>> remarks = const [
    {
      'faculty': 'Mr. Smith (Math)',
      'remark': 'Alice is showing great improvement in Algebra.',
      'date': '2024-10-25',
    },
    {
      'faculty': 'Mrs. Jones (Physics)',
      'remark': 'Needs to be more attentive during practical sessions.',
      'date': '2024-10-22',
    },
  ];

  final List<Map<String, String>> meetingRequests = const [
    {
      'faculty': 'Mr. Smith (Math)',
      'status': 'Pending',
      'requested_date': '2024-10-28',
    },
    {
      'faculty': 'Mrs. Jones (Physics)',
      'status': 'Confirmed for 2024-11-02 at 3:00 PM',
      'requested_date': '2024-10-29',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Faculty Remarks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...remarks.map((remark) => _buildRemarkCard(context, remark)).toList(),
            const SizedBox(height: 24),
            const Text('Parent-Teacher Meetings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...meetingRequests.map((request) => _buildMeetingRequestCard(context, request)).toList(),
            if (userRole == 'Parent') ...[
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.group_add_outlined),
                  label: const Text('Request New Meeting'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Requesting a new meeting is coming soon!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRemarkCard(BuildContext context, Map<String, String> remark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(remark['faculty']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(remark['remark']!),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(remark['date']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingRequestCard(BuildContext context, Map<String, String> request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text('Request with ${request['faculty']!}'),
        subtitle: Text('Status: ${request['status']!}'),
        trailing: const Icon(Icons.more_vert),
      ),
    );
  }
}
