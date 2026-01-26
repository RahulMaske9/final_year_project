import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageSubjectsScreen extends StatefulWidget {
  const ManageSubjectsScreen({super.key});

  @override
  State<ManageSubjectsScreen> createState() => _ManageSubjectsScreenState();
}

class _ManageSubjectsScreenState extends State<ManageSubjectsScreen> {
  String? _selectedDepartment;
  final List<String> _departments = [
    'Computer Science',
    'IT',
    'Mechanical',
    'Civil',
    'Electrical',
    'Electronics'
  ];

  final Color _primaryColor = const Color(0xFF3F51B5);
  final Color _secondaryColor = const Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Manage Subjects',
            style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: _primaryColor,
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildDepartmentDropdown(),
          Expanded(
            child: _selectedDepartment == null
                ? _buildEmptySelection()
                : _buildSubjectsStream(),
          ),
        ],
      ),
      floatingActionButton: _selectedDepartment != null
          ? FloatingActionButton.extended(
              onPressed: () => _showAddSubjectDialog(),
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: Text('Add Subject', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildDepartmentDropdown() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedDepartment,
        decoration: InputDecoration(
          labelText: 'Select Department',
          labelStyle: GoogleFonts.lato(color: _primaryColor, fontWeight: FontWeight.bold),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _primaryColor, width: 2),
          ),
          prefixIcon: Icon(Icons.business, color: _primaryColor),
          filled: true,
          fillColor: Colors.white,
        ),
        items: _departments.map((String dept) {
          return DropdownMenuItem<String>(
            value: dept,
            child: Text(dept, style: GoogleFonts.lato()),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedDepartment = newValue;
          });
        },
      ),
    );
  }

  Widget _buildEmptySelection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Please select a department to view subjects',
            style: GoogleFonts.lato(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('departments')
          .doc(_selectedDepartment)
          .collection('subjects')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book_outlined, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('No subjects found for this department',
                    style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[600])),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var subjectDoc = snapshot.data!.docs[index];
            var subjectData = subjectDoc.data() as Map<String, dynamic>;
            return _buildSubjectCard(subjectDoc.id, subjectData);
          },
        );
      },
    );
  }

  Widget _buildSubjectCard(String subjectId, Map<String, dynamic> data) {
    String facultyName = data['facultyName'] ?? 'Not Allotted';
    
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['subjectName'] ?? 'No Name',
                          style: GoogleFonts.lato(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _secondaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Code: ${data['subjectCode'] ?? 'N/A'}',
                            style: GoogleFonts.lato(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => _deleteSubject(subjectId, data['subjectName'] ?? 'this subject'),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(height: 1, color: Color(0xFFEEEEEE)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Allotted Faculty',
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[500],
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 16,
                              color: facultyName == 'Not Allotted' ? Colors.orange : Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                facultyName,
                                style: GoogleFonts.lato(
                                  fontSize: 15,
                                  color: facultyName == 'Not Allotted' ? Colors.orange[800] : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showFacultySelectionSheet(subjectId),
                    icon: const Icon(Icons.assignment_ind_outlined, size: 18),
                    label: const Text('Assign'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFacultySelectionSheet(String subjectId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _FacultySearchSheet(
          primaryColor: _primaryColor,
          onFacultySelected: (facultyId, facultyName) {
            _assignFaculty(subjectId, facultyId, facultyName);
          },
        );
      },
    );
  }

  Future<void> _assignFaculty(String subjectId, String facultyId, String facultyName) async {
    try {
      await FirebaseFirestore.instance
          .collection('departments')
          .doc(_selectedDepartment)
          .collection('subjects')
          .doc(subjectId)
          .update({
        'facultyId': facultyId,
        'facultyName': facultyName,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Subject assigned to $facultyName'),
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
  }

  void _showAddSubjectDialog() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add New Subject', 
          style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: _primaryColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Subject Name',
                labelStyle: GoogleFonts.lato(),
                prefixIcon: const Icon(Icons.book),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: 'Subject Code',
                labelStyle: GoogleFonts.lato(),
                prefixIcon: const Icon(Icons.code),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.lato(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty && codeController.text.trim().isNotEmpty) {
                await _addSubject(nameController.text.trim(), codeController.text.trim());
                if (context.mounted) Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter both name and code')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Add', style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _addSubject(String name, String code) async {
    try {
      await FirebaseFirestore.instance
          .collection('departments')
          .doc(_selectedDepartment)
          .collection('subjects')
          .add({
        'subjectName': name,
        'subjectCode': code,
        'facultyId': null,
        'facultyName': 'Not Allotted',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subject added successfully'),
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
  }

  Future<void> _deleteSubject(String subjectId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('departments')
          .doc(_selectedDepartment)
          .collection('subjects')
          .doc(subjectId)
          .delete();
    }
  }
}

class _FacultySearchSheet extends StatefulWidget {
  final Color primaryColor;
  final Function(String id, String name) onFacultySelected;

  const _FacultySearchSheet({
    required this.primaryColor,
    required this.onFacultySelected,
  });

  @override
  State<_FacultySearchSheet> createState() => _FacultySearchSheetState();
}

class _FacultySearchSheetState extends State<_FacultySearchSheet> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

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
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Assign Faculty',
                  style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search by faculty name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear), 
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    ) 
                  : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'Faculty')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var facultyDocs = snapshot.data!.docs.where((doc) {
                  String name = (doc['name'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery);
                }).toList();

                if (facultyDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No faculty members found',
                            style: GoogleFonts.lato(color: Colors.grey[600])),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: facultyDocs.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    var doc = facultyDocs[index];
                    String name = doc['name'] ?? 'Unknown';
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      leading: CircleAvatar(
                        backgroundColor: widget.primaryColor.withOpacity(0.1),
                        child: Icon(Icons.person, color: widget.primaryColor),
                      ),
                      title: Text(name, style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
                      subtitle: Text(doc['email'] ?? '', style: GoogleFonts.lato(fontSize: 13)),
                      trailing: const Icon(Icons.chevron_right, size: 18),
                      onTap: () {
                        widget.onFacultySelected(doc.id, name);
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
