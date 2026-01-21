import 'package:flutter/material.dart';
import 'package:first_app/button_styles.dart';

class CreateUserScreen extends StatefulWidget {
  final String role;

  const CreateUserScreen({super.key, required this.role});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();

  void _createUser() {
    // TODO: Implement user creation logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.role} created successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create ${widget.role}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: '${widget.role} ID',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 40),
            FilledButton(
              style: ButtonStyles.elevatedButtonStyle(context),
              onPressed: _createUser,
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
