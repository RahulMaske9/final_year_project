import 'package:flutter/material.dart';
import 'package:first_app/button_styles.dart';

class EditUserScreen extends StatefulWidget {
  final Map<String, String> user;

  const EditUserScreen({super.key, required this.user});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  late TextEditingController _nameController;
  late TextEditingController _idController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user['name']);
    _idController = TextEditingController(text: widget.user['id']);
  }

  void _saveUser() {
    // TODO: Implement user update logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User updated successfully!')),
    );
    Navigator.pop(context);
  }

  void _deleteUser() {
    // TODO: Implement user deletion logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User deleted successfully!')),
    );
    // Pop twice to go back to the user list screen
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: const Text('Are you sure you want to delete this user? This action cannot be undone.'),
          actions: <Widget>[
            FilledButton(
              style: ButtonStyles.elevatedButtonStyle(context),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              style: ButtonStyles.elevatedButtonStyle(context).copyWith(
                backgroundColor: MaterialStateProperty.all(Colors.red),
              ),
              child: const Text('Delete'),
              onPressed: () {
                _deleteUser();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.user['name']}'),
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
                labelText: '${widget.user['role']} ID',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 40),
            FilledButton(
              style: ButtonStyles.elevatedButtonStyle(context),
              onPressed: _saveUser,
              child: const Text('Save Changes'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: ButtonStyles.elevatedButtonStyle(context).copyWith(
                backgroundColor: MaterialStateProperty.all(Colors.red),
              ),
              onPressed: _showDeleteConfirmationDialog,
              child: const Text('Delete User'),
            ),
          ],
        ),
      ),
    );
  }
}
