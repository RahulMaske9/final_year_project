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

  factory TimetableSlot.fromMap(Map<String, dynamic> map) {
    return TimetableSlot(
      subject: map['subject'] ?? '',
      faculty: map['faculty'] ?? '',
      facultyId: map['facultyId'],
      room: map['room'] ?? '',
      color: Color(map['color'] ?? 0xFF3F51B5),
    );
  }
}

class ManageTimetablePage extends StatefulWidget {
  const ManageTimetablePage({super.key});

  @override
  State<ManageTimetablePage> createState() => _ManageTimetablePageState();
}

class _ManageTimetablePageState extends State<ManageTimetablePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _selectedDept;
  String? _selectedSem;
  String? _selectedSection;

  final List<String> _departments = ['CSE', 'IT', 'MECH', 'ECE', 'CIVIL'];
  final List<String> _semesters = ['1', '2', '3', '4', '5', '6', '7', '8'];
  final List<String> _sections = ['A', 'B', 'C'];
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  final List<String> _defaultTimeSlots = [
    '09:00 - 10:00',
    '10:00 - 11:00',
    '11:15 - 12:15',
    '12:15 - 01:15',
    '02:00 - 03:00',
    '03:00 - 04:00'
  ];

  final Color _primaryColor = const Color(0xFF3F51B5);

  // Connectivity fix: Explicit mapping to the exact docId used by Admin
  String get _docId {
    // Both portals MUST use Dept_Sem_Section format (e.g. CSE_1_A)
    return '${_selectedDept}_${_selectedSem}_$_selectedSection';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _days.length,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        appBar: AppBar(
          title: Text('Class Schedule', 
            style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          backgroundColor: _primaryColor,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            _buildSelectorsHeader(),
            Expanded(
              child: (_selectedDept != null && _selectedSem != null && _selectedSection != null)
                  ? _buildTimetableStream()
                  : _buildInitialPlaceholder(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorsHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(child: _buildHeaderDropdown('Branch', _selectedDept, _departments, (val) => setState(() => _selectedDept = val))),
              const SizedBox(width: 8),
              Expanded(child: _buildHeaderDropdown('Sem', _selectedSem, _semesters, (val) => setState(() => _selectedSem = val))),
              const SizedBox(width: 8),
              Expanded(child: _buildHeaderDropdown('Sec', _selectedSection, _sections, (val) => setState(() => _selectedSection = val))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      icon: Icon(Icons.keyboard_arrow_down, color: _primaryColor, size: 18),
      decoration: InputDecoration(
        labelText: label, 
        labelStyle: GoogleFonts.lato(color: Colors.grey[600], fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: GoogleFonts.lato(fontSize: 13)))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildInitialPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month_outlined, size: 80, color: _primaryColor.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            'Select Branch, Semester, and Section\nto see the current schedule',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(color: Colors.grey[500], fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableStream() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('timetables').doc(_docId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        final data = snapshot.hasData && snapshot.data!.exists ? snapshot.data!.data() as Map<String, dynamic> : {};
        
        // Use the time slots set by the Admin
        final List<String> timeSlots = data.containsKey('timeSlots') 
            ? List<String>.from(data['timeSlots']) 
            : _defaultTimeSlots;

        return Column(
          children: [
            TabBar(
              isScrollable: true,
              indicatorColor: _primaryColor,
              labelColor: _primaryColor,
              unselectedLabelColor: Colors.grey,
              tabs: _days.map((day) => Tab(text: day)).toList(),
            ),
            Expanded(
              child: TabBarView(
                children: _days.map((day) {
                  final dayData = data[day] as Map<String, dynamic>? ?? {};
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: timeSlots.length,
                    itemBuilder: (context, index) {
                      final time = timeSlots[index];
                      final slotData = dayData[time];
                      final slot = slotData != null ? TimetableSlot.fromMap(slotData) : null;
                      return _buildSlotCard(time, slot);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSlotCard(String time, TimetableSlot? slot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 90,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.05),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              ),
              child: Center(
                child: Text(
                  time.replaceFirst(' - ', '\nto\n'), 
                  textAlign: TextAlign.center, 
                  style: GoogleFonts.lato(fontSize: 11, fontWeight: FontWeight.bold, color: _primaryColor),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: slot != null
                    ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(slot.subject, style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, color: slot.color)),
                        const SizedBox(height: 8),
                        Row(children: [const Icon(Icons.person_outline, size: 14, color: Colors.grey), const SizedBox(width: 6), Text(slot.faculty, style: GoogleFonts.lato(color: Colors.grey, fontSize: 13))]),
                        const SizedBox(height: 4),
                        Row(children: [const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey), const SizedBox(width: 6), Text('Room: ${slot.room}', style: GoogleFonts.lato(color: Colors.grey, fontSize: 13))]),
                      ])
                    : Center(child: Text('Free Period', style: GoogleFonts.lato(color: Colors.grey[400], fontStyle: FontStyle.italic))),
              ),
            ),
            if (slot != null) 
              Container(
                width: 5, 
                decoration: BoxDecoration(
                  color: slot.color, 
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
