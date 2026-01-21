import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditStudentScreen extends StatefulWidget {
  // Allow null for creating a new student
  final String? studentId;
  final Map<String, dynamic>? currentData;

  const EditStudentScreen({
    super.key,
    this.studentId,
    this.currentData,
  });

  @override
  State<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _rollNoController;
  late TextEditingController _courseController;
  late TextEditingController _semesterController;
  late TextEditingController _emailController;

  // Parent linking
  String? _selectedParentId;

  // Determine if we are in "edit" or "add" mode
  bool get _isEditMode => widget.studentId != null;

  @override
  void initState() {
    super.initState();
    // Use currentData if it exists, otherwise empty strings
    final data = widget.currentData ?? {};
    _nameController = TextEditingController(text: data['name'] ?? '');
    _rollNoController = TextEditingController(text: data['rollNo'] ?? data['roll'] ?? '');
    _courseController = TextEditingController(text: data['course'] ?? '');
    _semesterController = TextEditingController(text: data['semester'] ?? '');
    _emailController = TextEditingController(text: data['email'] ?? '');
    _selectedParentId = data['parentId'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollNoController.dispose();
    _courseController.dispose();
    _semesterController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final timestamp = FieldValue.serverTimestamp();

      Map<String, dynamic> studentData = {
        'name': _nameController.text.trim(),
        'rollNo': _rollNoController.text.trim(),
        'course': _courseController.text.trim(),
        'semester': _semesterController.text.trim(),
        'email': _emailController.text.trim(),
        'lastUpdatedBy': currentUser?.uid,
        'lastUpdatedAt': timestamp,
        'parentId': _selectedParentId,
      };

      if (_isEditMode) {
        // Update existing student
        await FirebaseFirestore.instance
            .collection('students')
            .doc(widget.studentId!)
            .set(studentData, SetOptions(merge: true));
      } else {
        // Create new student (and add creation timestamp)
        studentData['createdAt'] = timestamp;
        await FirebaseFirestore.instance.collection('students').add(studentData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Student profile saved successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Dynamic title
        title: Text(_isEditMode ? 'Edit Student Profile' : 'Add New Student',
            style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _saveProfile,
            icon: _isLoading
                ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('Student Information'),
            _buildTextField('Full Name', _nameController, required: true),
            _buildTextField('Email Address', _emailController,
                keyboardType: TextInputType.emailAddress, required: true),

            _buildSectionHeader('Academic Details'),
            _buildTextField('Roll No.', _rollNoController, required: true),
            Row(
              children: [
                Expanded(
                    child: _buildTextField(
                        'Course (e.g., B.Tech)', _courseController)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildTextField('Semester', _semesterController,
                        keyboardType: TextInputType.number)),
              ],
            ),

            _buildSectionHeader('Link to Parent'),
            _buildParentDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildParentDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Parent')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No parents found. Please create a parent user first.');
        }

        final parents = snapshot.data!.docs;
        final parentIds = parents.map((doc) => doc.id).toList();

        return DropdownButtonFormField<String>(
          value: parentIds.contains(_selectedParentId)
              ? _selectedParentId
              : null,
          decoration: const InputDecoration(
            labelText: 'Assigned Parent',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.family_restroom_outlined),
          ),
          hint: const Text('Select a parent'),
          isExpanded: true,
          items: parents.map((doc) {
            final parentData = doc.data() as Map<String, dynamic>;
            return DropdownMenuItem<String>(
              value: doc.id,
              child: Text(
                parentData['displayName'] ??
                    parentData['name'] ??
                    parentData['email'] ??
                    doc.id,
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedParentId = value;
            });
          },
          // Validator can be optional if a parent isn't required for new students
          // validator: (value) =>
          // value == null ? 'A parent must be assigned.' : null,
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3F51B5)),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        bool required = false,
        TextInputType? keyboardType,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        keyboardType: keyboardType,
        validator: required
            ? (value) =>
        value == null || value.isEmpty ? '$label is required' : null
            : null,
      ),
    );
  }
}
