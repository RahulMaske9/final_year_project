import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageCourseScreen extends StatefulWidget {
  const ManageCourseScreen({super.key});

  @override
  State<ManageCourseScreen> createState() => _ManageCourseScreenState();
}

class _ManageCourseScreenState extends State<ManageCourseScreen> {
  String? _selectedDept;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Visual Identity (Matching main.dart)
  final Color _primaryIndigo = const Color(0xFF3F51B5);
  final Color _secondaryAmber = const Color(0xFFFFC107);
  final Color _surfaceGrey = const Color(0xFFF5F7FA);

  final List<String> _departments = [
    'Computer Science',
    'IT',
    'Mechanical',
    'Civil',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surfaceGrey,
      appBar: AppBar(
        title: Text(
          'Manage Courses',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _primaryIndigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildDepartmentHeader(),
          Expanded(
            child: _selectedDept == null
                ? _buildInitialState()
                : _buildSubjectStream(_selectedDept!),
          ),
        ],
      ),
      floatingActionButton: _selectedDept != null
          ? FloatingActionButton.extended(
              onPressed: () => _showAddSubjectDialog(_selectedDept!),
              label: Text('Add Subject', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
              icon: const Icon(Icons.add),
              backgroundColor: _primaryIndigo,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildDepartmentHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SIPNA COET - Portal',
            style: GoogleFonts.lato(
              fontSize: 14,
              color: _primaryIndigo,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedDept,
            hint: Text('Select Department', style: GoogleFonts.lato()),
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: _surfaceGrey,
              prefixIcon: Icon(Icons.account_balance, color: _primaryIndigo),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: _departments.map((dept) {
              return DropdownMenuItem(
                value: dept,
                child: Text(dept, style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedDept = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Please select a department to view subjects.',
            style: GoogleFonts.lato(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectStream(String deptId) {
    // Path: departments/{deptId}/subjects
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('departments')
          .doc(deptId)
          .collection('subjects')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final subjects = snapshot.data?.docs ?? [];
        if (subjects.isEmpty) {
          return Center(
            child: Text(
              'No subjects found for $deptId.',
              style: GoogleFonts.lato(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            final doc = subjects[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildSubjectCard(deptId, doc.id, data);
          },
        );
      },
    );
  }

  Widget _buildSubjectCard(String deptId, String subjectId, Map<String, dynamic> data) {
    final facultyName = data['facultyName'] ?? 'Not Assigned';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    data['name'] ?? 'Subject Name',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _primaryIndigo,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _secondaryAmber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    data['code'] ?? 'CODE',
                    style: GoogleFonts.lato(
                      color: Colors.brown[900],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.person_pin, size: 20, color: _secondaryAmber),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Allotted Faculty',
                        style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.bold),
                      ),
                      Text(
                        facultyName,
                        style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: facultyName == 'Not Assigned' ? Colors.red[700] : Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showFacultyPicker(deptId, subjectId),
                  icon: const Icon(Icons.assignment_ind_outlined),
                  color: _primaryIndigo,
                  tooltip: 'Allot Faculty',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSubjectDialog(String deptId) {
    final nameController = TextEditingController();
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Subject', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Subject Name'),
            ),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: 'Subject Code'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _primaryIndigo, foregroundColor: Colors.white),
            onPressed: () async {
              if (nameController.text.isNotEmpty && codeController.text.isNotEmpty) {
                await _firestore
                    .collection('departments')
                    .doc(deptId)
                    .collection('subjects')
                    .add({
                  'name': nameController.text.trim(),
                  'code': codeController.text.trim(),
                  'facultyName': 'Not Assigned',
                  'facultyId': '',
                  'createdAt': FieldValue.serverTimestamp(),
                });
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showFacultyPicker(String deptId, String subjectId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FacultySearchSheet(
        onFacultySelected: (id, name) async {
          try {
            await _firestore
                .collection('departments')
                .doc(deptId)
                .collection('subjects')
                .doc(subjectId)
                .update({
              'facultyId': id,
              'facultyName': name,
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Faculty $name assigned successfully!'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
              );
            }
          }
        },
      ),
    );
  }
}

class _FacultySearchSheet extends StatefulWidget {
  final Function(String id, String name) onFacultySelected;

  const _FacultySearchSheet({required this.onFacultySelected});

  @override
  State<_FacultySearchSheet> createState() => _FacultySearchSheetState();
}

class _FacultySearchSheetState extends State<_FacultySearchSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Select Faculty Member',
              style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF3F51B5)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'Faculty')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                
                final docs = snapshot.data?.docs.where((doc) {
                  final name = (doc.data() as Map<String, dynamic>)['displayName']?.toString().toLowerCase() ?? '';
                  return name.contains(_query);
                }).toList() ?? [];

                if (docs.isEmpty) return const Center(child: Text('No faculty found.'));

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: docs.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final name = data['displayName'] ?? 'Unknown';
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF3F51B5).withOpacity(0.1),
                        child: Text(name[0].toUpperCase(), style: const TextStyle(color: Color(0xFF3F51B5))),
                      ),
                      title: Text(name, style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
                      subtitle: Text(data['email'] ?? ''),
                      onTap: () {
                        widget.onFacultySelected(docs[index].id, name);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
