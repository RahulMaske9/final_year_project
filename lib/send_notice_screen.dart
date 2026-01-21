
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Model for notice data
class Notice {
  String id;
  String title;
  String body;
  DateTime sentDate;

  Notice({required this.id, required this.title, required this.body, required this.sentDate});
}

class SendNoticeScreen extends StatefulWidget {
  const SendNoticeScreen({super.key});

  @override
  State<SendNoticeScreen> createState() => _SendNoticeScreenState();
}

class _SendNoticeScreenState extends State<SendNoticeScreen> {
  // Dummy data
  final List<Notice> _sentNotices = [
    Notice(id: 'N01', title: 'Holiday Declaration', body: 'All students are hereby informed that the college will remain closed tomorrow on account of a local festival.', sentDate: DateTime.now().subtract(const Duration(days: 1))),
    Notice(id: 'N02', title: 'Exam Form Submission', body: 'The last date for exam form submission for the upcoming semester is 30th July. No extensions will be provided.', sentDate: DateTime.now().subtract(const Duration(days: 5))),
  ];

  void _addNotice(Notice notice) {
    setState(() {
      _sentNotices.insert(0, notice); // Add to the top of the list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Notices', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 4,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Previously Sent Notices',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black54),
            ),
          ),
          Expanded(
            child: _sentNotices.isEmpty
                ? _buildEmptyState()
                : _buildNoticeList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNoticeFormDialog(),
        icon: const Icon(Icons.add),
        label: const Text('New Notice'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.announcement_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No notices sent yet',
            style: GoogleFonts.lato(fontSize: 18, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 80),
      itemCount: _sentNotices.length,
      itemBuilder: (context, index) {
        final notice = _sentNotices[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            title: Text(notice.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(notice.body, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: Text(
              DateFormat('dd MMM, yyyy').format(notice.sentDate),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
        );
      },
    );
  }

  void _showNoticeFormDialog() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Compose a New Notice'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                  validator: (value) => (value?.isEmpty ?? true) ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: bodyController,
                  decoration: const InputDecoration(labelText: 'Message', border: OutlineInputBorder()),
                  maxLines: 5,
                  validator: (value) => (value?.isEmpty ?? true) ? 'Please enter a message' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          FilledButton(
            child: const Text('Send'),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;

              final newNotice = Notice(
                id: DateTime.now().toIso8601String(),
                title: titleController.text,
                body: bodyController.text,
                sentDate: DateTime.now(),
              );
              
              _addNotice(newNotice);

              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notice sent successfully.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
