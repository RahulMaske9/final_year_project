import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TimetableSlot {
  final String subject;
  final String faculty;
  final String? facultyId;
  final String room;
  final Color color;

  TimetableSlot({
    required this.subject,
    required this.faculty,
    this.facultyId,
    required this.room,
    this.color = const Color(0xFF3F51B5),
  });

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'faculty': faculty,
      'facultyId': facultyId,
      'room': room,
      'color': color.value,
    };
  }

  factory TimetableSlot.fromMap(Map<String, dynamic> map) {
    return TimetableSlot(
      subject: map['subject'] ?? 'N/A',
      faculty: map['faculty'] ?? 'TBD',
      facultyId: map['facultyId'],
      room: map['room'] ?? 'N/A',
      color: Color(map['color'] ?? 0xFF3F51B5),
    );
  }
}

class ManageTimetableScreen extends StatefulWidget {
  const ManageTimetableScreen({super.key});

  @override
  State<ManageTimetableScreen> createState() => _ManageTimetableScreenState();
}

class _ManageTimetableScreenState extends State<ManageTimetableScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _selectedDept = 'CSE';
  String _selectedSem = '1';
  String _selectedSection = 'A';

  final List<String> _departments = ['CSE', 'IT', 'MECH', 'ECE', 'CIVIL'];
  final List<String> _semesters = ['1', '2', '3', '4', '5', '6', '7', '8'];
  final List<String> _sections = ['A', 'B', 'C'];
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  
  final List<String> _defaultTimeSlots = [
    '09:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:15 AM - 12:15 PM',
    '12:15 PM - 01:15 PM',
    '02:00 PM - 03:00 PM',
    '03:00 PM - 04:00 PM'
  ];

  final Color _primaryColor = const Color(0xFF3F51B5);
  final Color _accentColor = const Color(0xFFFFC107);

  String get _docId => '${_selectedDept}_${_selectedSem}_$_selectedSection';

  Future<void> _updateSlot(String day, String time, TimetableSlot slot, List<String> currentSlots) async {
    try {
      final docRef = _firestore.collection('timetables').doc(_docId);
      await docRef.set({
        'timeSlots': currentSlots,
        day: {
          time: slot.toMap()
        }
      }, SetOptions(merge: true));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Slot updated for $day at $time'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteSlot(String day, String time) async {
    try {
      await _firestore.collection('timetables').doc(_docId).update({
        '$day.$time': FieldValue.delete()
      });
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }

  Future<void> _saveTimeSlots(List<String> slots) async {
    try {
      await _firestore.collection('timetables').doc(_docId).set({
        'timeSlots': slots,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving time slots: $e');
    }
  }

  void _showSlotDialog(String day, String time, List<String> timeSlots, {TimetableSlot? existingSlot}) {
    final subjectController = TextEditingController(text: existingSlot?.subject);
    final roomController = TextEditingController(text: existingSlot?.room);
    String facultyName = existingSlot?.faculty ?? '';
    String? facultyId = existingSlot?.facultyId;
    Color selectedColor = existingSlot?.color ?? _primaryColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24, left: 24, right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Assign Class', style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold, color: _primaryColor)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              Text('$day | $time', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              const SizedBox(height: 24),
              TextField(
                controller: subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject Name',
                  prefixIcon: const Icon(Icons.book_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final result = await _showFacultyPicker();
                  if (result != null) {
                    setDialogState(() {
                      facultyName = result['name'];
                      facultyId = result['id'];
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey.shade50,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, color: Colors.grey.shade700),
                      const SizedBox(width: 12),
                      Text(facultyName.isEmpty ? 'Select Faculty Member' : facultyName, 
                        style: TextStyle(color: facultyName.isEmpty ? Colors.grey.shade600 : Colors.black, fontSize: 16)),
                      const Spacer(),
                      const Icon(Icons.chevron_right, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: roomController,
                decoration: InputDecoration(
                  labelText: 'Room / Lab Number',
                  prefixIcon: const Icon(Icons.room_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 24),
              const Text('Tag Color', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _colorOption(const Color(0xFF3F51B5), selectedColor, (c) => setDialogState(() => selectedColor = c)),
                  _colorOption(const Color(0xFF4CAF50), selectedColor, (c) => setDialogState(() => selectedColor = c)),
                  _colorOption(const Color(0xFFFF9800), selectedColor, (c) => setDialogState(() => selectedColor = c)),
                  _colorOption(const Color(0xFFE91E63), selectedColor, (c) => setDialogState(() => selectedColor = c)),
                  _colorOption(const Color(0xFF9C27B0), selectedColor, (c) => setDialogState(() => selectedColor = c)),
                  _colorOption(const Color(0xFF00BCD4), selectedColor, (c) => setDialogState(() => selectedColor = c)),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  if (existingSlot != null)
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () { _deleteSlot(day, time); Navigator.pop(context); },
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        label: const Text('Remove', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  if (existingSlot != null) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        if (subjectController.text.isEmpty || facultyName.isEmpty) return;
                        _updateSlot(day, time, TimetableSlot(
                          subject: subjectController.text, 
                          faculty: facultyName, 
                          facultyId: facultyId, 
                          room: roomController.text, 
                          color: selectedColor
                        ), timeSlots);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      child: const Text('Save Assignment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _showFacultyPicker() async {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Select Faculty', style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('users').where('role', isEqualTo: 'Faculty').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = data['displayName'] ?? data['firstName'] ?? data['name'] ?? 'Unknown';
                      return ListTile(
                        leading: CircleAvatar(backgroundColor: _primaryColor.withOpacity(0.1), child: Text(name[0], style: TextStyle(color: _primaryColor))),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(data['email'] ?? ''),
                        onTap: () => Navigator.pop(context, {'id': doc.id, 'name': name}),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorOption(Color color, Color selected, Function(Color) onSelect) {
    bool isSelected = color.value == selected.value;
    return GestureDetector(
      onTap: () => onSelect(color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? Colors.black : Colors.white, width: 2),
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, spreadRadius: 2)] : null,
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
      ),
    );
  }

  void _showAddTimeSlotDialog(List<String> currentSlots) {
    final startTimeController = TextEditingController();
    final endTimeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Time Slot', style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: _primaryColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: startTimeController,
              decoration: const InputDecoration(labelText: 'Start Time (e.g., 09:00 AM)', hintText: 'HH:MM AM/PM'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: endTimeController,
              decoration: const InputDecoration(labelText: 'End Time (e.g., 10:00 AM)', hintText: 'HH:MM AM/PM'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: Colors.grey[600]))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor, 
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (startTimeController.text.isNotEmpty && endTimeController.text.isNotEmpty) {
                final newTime = '${startTimeController.text} - ${endTimeController.text}';
                List<String> updatedSlots = List.from(currentSlots)..add(newTime);
                _saveTimeSlots(updatedSlots);
                Navigator.pop(context);
              }
            },
            child: const Text('Add Slot'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('Timetable Manager', style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
        backgroundColor: _primaryColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('timetables').doc(_docId).snapshots(),
            builder: (context, snapshot) {
              final data = snapshot.hasData && snapshot.data!.exists ? snapshot.data!.data() as Map<String, dynamic> : {};
              final List<String> timeSlots = data.containsKey('timeSlots') ? List<String>.from(data['timeSlots']) : _defaultTimeSlots;
              return IconButton(
                onPressed: () => _showAddTimeSlotDialog(timeSlots), 
                icon: const Icon(Icons.add_alarm_rounded, color: Colors.white),
                tooltip: 'Add Time Slot',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeaderSection(),
          Expanded(
            child: _buildLiveGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: Card(
        elevation: 15,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildHeaderDropdown('Branch', _selectedDept, _departments, (v) => setState(() => _selectedDept = v!))),
                  const SizedBox(width: 15),
                  Expanded(child: _buildHeaderDropdown('Sem', _selectedSem, _semesters, (v) => setState(() => _selectedSem = v!))),
                  const SizedBox(width: 15),
                  Expanded(child: _buildHeaderDropdown('Sec', _selectedSection, _sections, (v) => setState(() => _selectedSection = v!))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.lato(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down, color: _primaryColor, size: 20),
            style: GoogleFonts.lato(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
            items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
            onChanged: (val) {
              onChanged(val);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLiveGrid() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('timetables').doc(_docId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        
        final data = snapshot.hasData && snapshot.data!.exists ? snapshot.data!.data() as Map<String, dynamic> : {};
        final List<String> timeSlots = data.containsKey('timeSlots') ? List<String>.from(data['timeSlots']) : _defaultTimeSlots;

        return Scrollbar(
          thumbVisibility: true,
          thickness: 6,
          radius: const Radius.circular(10),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
                  dataRowHeight: 110,
                  columnSpacing: 30,
                  horizontalMargin: 20,
                  border: TableBorder(
                    horizontalInside: BorderSide(color: Colors.grey.shade100, width: 1),
                    verticalInside: BorderSide(color: Colors.grey.shade50, width: 1),
                  ),
                  columns: [
                    DataColumn(label: Text('PERIOD', style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: _primaryColor, fontSize: 13))),
                    ..._days.map((day) => DataColumn(label: Text(day.toUpperCase(), style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 13)))),
                  ],
                  rows: timeSlots.map((time) => DataRow(cells: [
                    DataCell(Text(time, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
                    ..._days.map((day) {
                      final dayData = data[day] as Map<String, dynamic>? ?? {};
                      final slotData = dayData[time];
                      final slot = slotData != null ? TimetableSlot.fromMap(slotData) : null;
                      
                      return DataCell(InkWell(
                        onTap: () => _showSlotDialog(day, time, timeSlots, existingSlot: slot),
                        child: _buildPremiumCell(slot),
                      ));
                    }),
                  ])).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumCell(TimetableSlot? slot) {
    if (slot == null) {
      return Container(
        width: 120,
        alignment: Alignment.center,
        child: Icon(Icons.add_rounded, color: Colors.grey.shade300, size: 26),
      );
    }

    return Container(
      width: 130,
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: slot.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: slot.color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(slot.subject, style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.bold, color: slot.color), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.person, size: 11, color: Colors.black54),
              const SizedBox(width: 4),
              Expanded(child: Text(slot.faculty, style: const TextStyle(fontSize: 10, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(Icons.room, size: 11, color: Colors.black54),
              const SizedBox(width: 4),
              Text(slot.room, style: const TextStyle(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
