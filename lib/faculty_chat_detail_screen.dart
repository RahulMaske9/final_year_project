
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:first_app/faculty_chat_with_parents_screen.dart';

// Models for chat data
enum MessageStatus { sent, delivered, read }

class Message {
  final String text;
  final bool isSentByMe;
  final DateTime timestamp;
  MessageStatus status;

  Message({
    required this.text,
    required this.isSentByMe,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });
}

class FacultyChatDetailScreen extends StatefulWidget {
  final Parent parent;

  const FacultyChatDetailScreen({super.key, required this.parent});

  @override
  State<FacultyChatDetailScreen> createState() => _FacultyChatDetailScreenState();
}

class _FacultyChatDetailScreenState extends State<FacultyChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [
    Message(text: 'Hello! I wanted to discuss Anjali\'s progress.', isSentByMe: false, timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)), status: MessageStatus.read),
    Message(text: 'Of course, I\'m happy to chat.', isSentByMe: true, timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 1)), status: MessageStatus.read),
    Message(text: 'How is she doing in Computer Graphics?', isSentByMe: false, timestamp: DateTime.now().subtract(const Duration(minutes: 30)), status: MessageStatus.read),
    Message(text: 'She is doing great. Her last assignment was excellent.', isSentByMe: true, timestamp: DateTime.now().subtract(const Duration(minutes: 28)), status: MessageStatus.delivered),
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add(Message(
          text: _messageController.text.trim(),
          isSentByMe: true,
          timestamp: DateTime.now(),
        ));
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.parent.name, style: GoogleFonts.lato()),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: GroupedListView(messages: _messages),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.emoji_emotions_outlined), color: Colors.grey.shade600, onPressed: () {}), // Emoji button
          IconButton(icon: const Icon(Icons.attach_file), color: Colors.grey.shade600, onPressed: () {}), // Attachment button
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24.0), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
          ),
          const SizedBox(width: 4),
          FloatingActionButton(onPressed: _sendMessage, mini: true, child: const Icon(Icons.send, size: 20), backgroundColor: Theme.of(context).colorScheme.primary,),
        ],
      ),
    );
  }
}

// Widget to group messages by date
class GroupedListView extends StatelessWidget {
  final List<Message> messages;
  const GroupedListView({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    final groupedMessages = _groupMessagesByDate(messages);

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: groupedMessages.length,
      itemBuilder: (context, index) {
        final date = groupedMessages.keys.elementAt(index);
        final messagesForDate = groupedMessages[date]!;

        return Column(
          children: [
            _buildDateSeparator(date),
            ...messagesForDate.map((message) => MessageBubble(message: message)),
          ],
        );
      },
    );
  }

  Map<DateTime, List<Message>> _groupMessagesByDate(List<Message> messages) {
    final Map<DateTime, List<Message>> grouped = {};
    for (final message in messages) {
      final date = DateTime(message.timestamp.year, message.timestamp.month, message.timestamp.day);
      if (grouped[date] == null) grouped[date] = [];
      grouped[date]!.add(message);
    }
    return grouped;
  }

  Widget _buildDateSeparator(DateTime date) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12.0)),
        child: Text(DateFormat.yMMMd().format(date), style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}

// Bubble for each message
class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isSentByMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 8.0),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).colorScheme.primary.withAlpha(220) : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18.0), topRight: const Radius.circular(18.0),
            bottomLeft: Radius.circular(isMe ? 18.0 : 4.0), bottomRight: Radius.circular(isMe ? 4.0 : 18.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(message.text, style: GoogleFonts.lato(fontSize: 16, color: isMe ? Colors.white : Colors.black87)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(DateFormat.jm().format(message.timestamp), style: GoogleFonts.lato(fontSize: 12, color: isMe ? Colors.white70 : Colors.black54)),
                if (isMe) ...[const SizedBox(width: 6), _buildStatusIcon(message.status)],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(MessageStatus status) {
    IconData iconData;
    Color color;
    switch (status) {
      case MessageStatus.read:
        iconData = Icons.done_all;
        color = Colors.blue;
        break;
      case MessageStatus.delivered:
        iconData = Icons.done_all;
        color = Colors.grey;
        break;
      default:
        iconData = Icons.done;
        color = Colors.grey;
    }
    return Icon(iconData, size: 16, color: color);
  }
}
