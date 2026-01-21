import 'package:flutter/material.dart';

class BroadcastAnnouncementsScreen extends StatefulWidget {
  const BroadcastAnnouncementsScreen({super.key});

  @override
  State<BroadcastAnnouncementsScreen> createState() =>
      _BroadcastAnnouncementsScreenState();
}

class _BroadcastAnnouncementsScreenState
    extends State<BroadcastAnnouncementsScreen> {
  final List<Map<String, String>> _announcements = [
    {
      'title': 'School Holiday',
      'message': 'The school will be closed on Monday for a public holiday.',
    },
    {
      'title': 'Parent-Teacher Meeting',
      'message':
          'The parent-teacher meeting will be held on Friday at 5:00 PM.',
    },
  ];
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  void _addAnnouncement() {
    if (_titleController.text.isNotEmpty &&
        _messageController.text.isNotEmpty) {
      setState(() {
        _announcements.add({
          'title': _titleController.text,
          'message': _messageController.text,
        });
        _titleController.clear();
        _messageController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter both a title and a message.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Broadcast Announcements'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addAnnouncement,
                  child: const Text('Broadcast'),
                ),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Recent Announcements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _announcements.length,
              itemBuilder: (context, index) {
                final announcement = _announcements[index];
                return Card(
                  child: ListTile(
                    title: Text(announcement['title']!),
                    subtitle: Text(announcement['message']!),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
