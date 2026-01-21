import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditFacultyScreen extends StatefulWidget {
  final String? facultyId;
  final Map<String, dynamic>? initialData;

  const EditFacultyScreen({super.key, this.facultyId, this.initialData});

  @override
  State<EditFacultyScreen> createState() => _EditFacultyScreenState();
}

class _EditFacultyScreenState extends State<EditFacultyScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _departmentController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.initialData?['firstName'] ?? '');
    _lastNameController = TextEditingController(text: widget.initialData?['lastName'] ?? '');
    _emailController = TextEditingController(text: widget.initialData?['email'] ?? '');
    _departmentController = TextEditingController(text: widget.initialData?['department'] ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _saveFaculty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'department': _departmentController.text.trim(),
      'isActive': widget.initialData?['isActive'] ?? true, // Default to active on creation
      'lastUpdatedAt': FieldValue.serverTimestamp(),
    };

    try {
      if (widget.facultyId == null) {
        // Create new faculty
        await FirebaseFirestore.instance.collection('faculty').add(data);
      } else {
        // Update existing faculty
        await FirebaseFirestore.instance.collection('faculty').doc(widget.facultyId).update(data);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save faculty: $e')),
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
    final isEditing = widget.facultyId != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Faculty' : 'Add Faculty'),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildTextField(_firstNameController, 'First Name', required: true),
            _buildTextField(_lastNameController, 'Last Name', required: true),
            _buildTextField(_emailController, 'Email', keyboardType: TextInputType.emailAddress, required: true),
            _buildTextField(_departmentController, 'Department'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveFaculty,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F51B5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                  : Text(isEditing ? 'Save Changes' : 'Add Faculty'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool required = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }
}
