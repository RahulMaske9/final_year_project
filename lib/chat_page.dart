import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'sender': 'teacher', 'text': "Hello! How can I help you today regarding Ramesh's progress?"},
    {'sender': 'parent', 'text': 'Hi, I wanted to ask about his performance in the recent math test.'},
    {'sender': 'teacher', 'text': 'He did quite well, scoring an A. He seems to have a good grasp of the concepts.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Mrs. Davis', style: GoogleFonts.lato()),
        backgroundColor: const Color(0xFF3F51B5), // Indigo
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message['text']!, message['sender']!);
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, String sender) {
    final isMe = sender == 'parent';
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF3F51B5) : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: GoogleFonts.lato(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file, color: Color(0xFF3F51B5)),
            onPressed: () {
              // TODO: Implement document upload
            },
          ),
          IconButton(
            icon: const Icon(Icons.photo_camera, color: Color(0xFF3F51B5)),
            onPressed: () {
              // TODO: Implement photo upload
            },
          ),
           IconButton(
            icon: const Icon(Icons.videocam, color: Color(0xFF3F51B5)),
            onPressed: () {
              // TODO: Implement video upload
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF3F51B5)),
            onPressed: () {
              // TODO: Implement send message functionality
            },
          ),
        ],
      ),
    );
  }
}
