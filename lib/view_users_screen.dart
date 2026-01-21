import 'package:flutter/material.dart';
import 'package:first_app/edit_user_screen.dart';

class ViewUsersScreen extends StatefulWidget {
  const ViewUsersScreen({super.key});

  @override
  State<ViewUsersScreen> createState() => _ViewUsersScreenState();
}

class _ViewUsersScreenState extends State<ViewUsersScreen> {
  final List<Map<String, String>> _allUsers = [
    {'name': 'Alice', 'role': 'Student', 'id': '101'},
    {'name': 'Bob', 'role': 'Student', 'id': '102'},
    {'name': 'Charlie', 'role': 'Student', 'id': '103'},
    {'name': 'Mr. Smith', 'role': 'Faculty', 'id': 'F01'},
    {'name': 'Mrs. Jones', 'role': 'Faculty', 'id': 'F02'},
    {'name': 'Mr. and Mrs. Brown', 'role': 'Parent', 'id': 'P01'},
  ];

  List<Map<String, String>> _filteredUsers = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredUsers = _allUsers;
    _searchController.addListener(() {
      filterUsers();
    });
  }

  void filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        return user['name']!.toLowerCase().contains(query) ||
               user['role']!.toLowerCase().contains(query) ||
               user['id']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View/Edit Users'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by name, role, or ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return Card(
                  child: ListTile(
                    title: Text(user['name']!),
                    subtitle: Text('${user['role']} - ID: ${user['id']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditUserScreen(user: user),
                          ),
                        );
                      },
                    ),
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
