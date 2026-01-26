import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Selection state
  String? _selectedClass;
  String? _selectedSection;
  String? _selectedSubject;
  DateTime _selectedDate = DateTime.now();

  // Student data state
  List<DocumentSnapshot> _allStudents = [];
  List<DocumentSnapshot> _filteredStudents = [];
  Map<String, bool> _attendanceState = {};
  bool _isLoadingStudents = false;
  final TextEditingController _searchController = TextEditingController();

  // Theme Colors
  final Color _primaryColor = const Color(0xFF3F51B5);
  final Color _secondaryColor = const Color(0xFFFFC107);
  final Color _backgroundColor = const Color(0xFFF8FAFF);

  // Mock data for dropdowns
  final List<String> _classes = ['First Year', 'Second Year', 'Third Year', 'Final Year'];
  final List<String> _sections = ['Section A', 'Section B', 'Section C'];
  final List<String> _subjects = [
    'Artificial Intelligence',
    'Data Structures',
    'Machine Learning',
    'Cloud Computing',
    'Operating Systems',
    'Computer Networks'
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = _allStudents.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final name = (data['name'] ?? '').toString().toLowerCase();
        final rollNo = (data['rollNo'] ?? '').toString().toLowerCase();
        return name.contains(query) || rollNo.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildSelectionCard()),
          SliverFillRemaining(
            hasScrollBody: true,
            child: _isLoadingStudents
                ? _buildLoadingState()
                : (_selectedClass != null && _selectedSection != null)
                    ? _buildStudentSection()
                    : _buildInitialState(),
          ),
        ],
      ),
      bottomNavigationBar: _allStudents.isNotEmpty ? _buildBottomActionBar() : null,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: _primaryColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Mark Attendance',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_primaryColor, _primaryColor.withOpacity(0.8)],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _selectDate(context),
          icon: const Icon(Icons.calendar_month, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildSelectionCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildCustomDropdown(
                      label: 'Class',
                      icon: Icons.school_outlined,
                      value: _selectedClass,
                      items: _classes,
                      onChanged: (val) {
                        setState(() {
                          _selectedClass = val;
                          _fetchStudents();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCustomDropdown(
                      label: 'Section',
                      icon: Icons.grid_view_outlined,
                      value: _selectedSection,
                      items: _sections,
                      onChanged: (val) {
                        setState(() {
                          _selectedSection = val;
                          _fetchStudents();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildCustomDropdown(
                label: 'Subject',
                icon: Icons.book_outlined,
                value: _selectedSubject,
                items: _subjects,
                onChanged: (val) {
                  setState(() => _selectedSubject = val);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      icon: Icon(Icons.keyboard_arrow_down, color: _primaryColor, size: 20),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.lato(color: Colors.grey[600], fontSize: 13),
        prefixIcon: Icon(icon, color: _primaryColor, size: 18),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item, style: GoogleFonts.lato(fontSize: 14)));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.how_to_reg, size: 80, color: _primaryColor.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            'Select parameters to view students',
            style: GoogleFonts.lato(color: Colors.grey[400], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }

  Widget _buildStudentSection() {
    if (_allStudents.isEmpty) {
      return Center(
        child: Text('No students found for this class/section', style: GoogleFonts.lato(color: Colors.grey)),
      );
    }

    int presentCount = _attendanceState.values.where((v) => v).length;
    double percentage = (_allStudents.isEmpty) ? 0 : (presentCount / _allStudents.length) * 100;

    return Column(
      children: [
        _buildStatisticsBar(presentCount, percentage),
        _buildSearchBar(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            itemCount: _filteredStudents.length,
            itemBuilder: (context, index) {
              final studentDoc = _filteredStudents[index];
              final data = studentDoc.data() as Map<String, dynamic>;
              final studentId = studentDoc.id;
              final isPresent = _attendanceState[studentId] ?? false;

              return _buildStudentCard(studentId, data, isPresent);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsBar(int present, double percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildStatItem('Total', _allStudents.length.toString(), Colors.blue),
          const SizedBox(width: 12),
          _buildStatItem('Present', present.toString(), Colors.green),
          const SizedBox(width: 12),
          _buildStatItem('Percent', '${percent.toStringAsFixed(0)}%', _secondaryColor),
          const Spacer(),
          TextButton(
            onPressed: _markAllPresent,
            child: Text('All Present', style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: _primaryColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.lato(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        Text(value, style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name or roll no...',
          hintStyle: GoogleFonts.lato(fontSize: 14, color: Colors.grey),
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(String id, Map<String, dynamic> data, bool isPresent) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isPresent ? Colors.green.withOpacity(0.3) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: isPresent ? Colors.green.withOpacity(0.1) : Colors.grey[100],
          child: Text(
            data['rollNo']?.toString() ?? '?',
            style: GoogleFonts.lato(
              color: isPresent ? Colors.green : Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        title: Text(
          data['name'] ?? 'No Name',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text('ID: ${data['studentId'] ?? 'N/A'}', style: GoogleFonts.lato(fontSize: 11, color: Colors.grey)),
        trailing: Checkbox(
          value: isPresent,
          activeColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (val) {
            setState(() {
              _attendanceState[id] = val ?? false;
            });
          },
        ),
        onTap: () {
          setState(() {
            _attendanceState[id] = !isPresent;
          });
        },
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Cancel', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _submitAttendance,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text('Submit Attendance', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: _primaryColor, onPrimary: Colors.white, onSurface: Colors.black),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _fetchStudents() async {
    if (_selectedClass == null || _selectedSection == null) return;

    setState(() {
      _isLoadingStudents = true;
      _allStudents = [];
      _filteredStudents = [];
      _attendanceState = {};
    });

    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Student')
          .where('class', isEqualTo: _selectedClass)
          .where('section', isEqualTo: _selectedSection)
          .get();

      setState(() {
        _allStudents = snapshot.docs;
        _filteredStudents = List.from(_allStudents);
        for (var doc in _allStudents) {
          _attendanceState[doc.id] = false;
        }
      });
    } catch (e) {
      debugPrint('Error fetching students: $e');
    } finally {
      setState(() => _isLoadingStudents = false);
    }
  }

  void _markAllPresent() {
    setState(() {
      _attendanceState.updateAll((key, value) => true);
    });
  }

  Future<void> _submitAttendance() async {
    if (_selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subject'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      Map<String, String> attendanceData = {};
      _attendanceState.forEach((id, isPresent) {
        attendanceData[id] = isPresent ? 'Present' : 'Absent';
      });

      await _firestore.collection('attendance').add({
        'date': Timestamp.fromDate(_selectedDate),
        'subject': _selectedSubject,
        'class': _selectedClass,
        'section': _selectedSection,
        'attendanceData': attendanceData,
        'markedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Attendance for $_selectedSubject submitted!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context); // Go back
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
