import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TimetableSlot {
  final String subject;
  final String faculty;
  final String room;

  TimetableSlot({required this.subject, required this.faculty, required this.room});

  Map<String, dynamic> toMap() {
    return {'subject': subject, 'faculty': faculty, 'room': room};
  }

  factory TimetableSlot.fromMap(Map<String, dynamic> map) {
    return TimetableSlot(
      subject: map['subject'] ?? '',
      faculty: map['faculty'] ?? '',
      room: map['room'] ?? '',
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
  
  // Changed to a standard list so it can be updated
  List<String> _timeSlots = [
    '09:00 - 10:00',
    '10:00 - 11:00',
    '11:15 - 12:15',
    '12:15 - 01:15',
    '02:00 - 03:00',
    '03:00 - 04:00'
  ];

  Map<String, Map<String, TimetableSlot>> _timetableData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTimetable();
  }

  String get _docId => '${_selectedDept}_${_selectedSem}_$_selectedSection';

  Future<void> _fetchTimetable() async {
    setState(() => _isLoading = true);
    try {
      final doc = await _firestore.collection('timetables').doc(_docId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        Map<String, Map<String, TimetableSlot>> fetchedData = {};
        
        // Also fetch the time slots from Firestore if they exist
        if (data.containsKey('timeSlots')) {
          setState(() {
            _timeSlots = List<String>.from(data['timeSlots']);
          });
        }

        data.forEach((day, slots) {
          if (day == 'timeSlots') return; // Skip the metadata field
          Map<String, TimetableSlot> daySlots = {};
          if (slots is Map<String, dynamic>) {
            slots.forEach((time, slotData) {
              daySlots[time] = TimetableSlot.fromMap(slotData);
            });
          }
          fetchedData[day] = daySlots;
        });
        
        setState(() => _timetableData = fetchedData);
      } else {
        setState(() => _timetableData = {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveTimeSlots() async {
    try {
      await _firestore.collection('timetables').doc(_docId).set({
        'timeSlots': _timeSlots,
      }, SetOptions(merge: true));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save time slots: $e')));
      }
    }
  }

  Future<void> _updateSlot(String day, String time, TimetableSlot slot) async {
    try {
      await _firestore.collection('timetables').doc(_docId).set({
        day: {time: slot.toMap()}
      }, SetOptions(merge: true));
      _fetchTimetable();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
      }
    }
  }

  Future<void> _deleteSlot(String day, String time) async {
    try {
      await _firestore.collection('timetables').doc(_docId).update({
        '$day.$time': FieldValue.delete()
      });
      _fetchTimetable();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  void _showSlotDialog(String day, String time, {TimetableSlot? existingSlot}) {
    final subjectController = TextEditingController(text: existingSlot?.subject);
    final facultyController = TextEditingController(text: existingSlot?.faculty);
    final roomController = TextEditingController(text: existingSlot?.room);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Schedule Slot: $day ($time)', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: subjectController, decoration: const InputDecoration(labelText: 'Subject')),
            TextField(controller: facultyController, decoration: const InputDecoration(labelText: 'Faculty')),
            TextField(controller: roomController, decoration: const InputDecoration(labelText: 'Room Number')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F51B5), foregroundColor: Colors.white),
            onPressed: () {
              final slot = TimetableSlot(
                subject: subjectController.text,
                faculty: facultyController.text,
                room: roomController.text,
              );
              _updateSlot(day, time, slot);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddTimeSlotDialog() {
    final startTimeController = TextEditingController();
    final endTimeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Time Slot', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: startTimeController,
              decoration: const InputDecoration(labelText: 'Start Time (e.g., 10:00 AM)', hintText: 'HH:MM AM/PM'),
            ),
            TextField(
              controller: endTimeController,
              decoration: const InputDecoration(labelText: 'End Time (e.g., 11:00 AM)', hintText: 'HH:MM AM/PM'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F51B5), foregroundColor: Colors.white),
            onPressed: () {
              if (startTimeController.text.isNotEmpty && endTimeController.text.isNotEmpty) {
                final newTime = '${startTimeController.text} - ${endTimeController.text}';
                setState(() {
                  _timeSlots.add(newTime);
                });
                _saveTimeSlots(); // Persist to Firebase
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Timetable', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showAddTimeSlotDialog,
            icon: const Icon(Icons.add_alarm),
            tooltip: 'Add Time Slot',
          )
        ],
      ),
      body: Column(
        children: [
          _buildSelectors(),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(child: _buildTimetableGrid()),
        ],
      ),
    );
  }

  Widget _buildSelectors() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(child: _buildDropdown('Dept', _selectedDept, _departments, (val) => setState(() => _selectedDept = val!))),
          const SizedBox(width: 4),
          Expanded(child: _buildDropdown('Sem', _selectedSem, _semesters, (val) => setState(() => _selectedSem = val!))),
          const SizedBox(width: 4),
          Expanded(child: _buildDropdown('Sec', _selectedSection, _sections, (val) => setState(() => _selectedSection = val!))),
          const SizedBox(width: 4),
          IconButton(
            onPressed: _fetchTimetable,
            icon: const Icon(Icons.refresh, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF3F51B5),
              foregroundColor: Colors.white,
              minimumSize: const Size(40, 40),
              padding: EdgeInsets.zero,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      style: const TextStyle(fontSize: 12, color: Colors.black),
      decoration: InputDecoration(
        labelText: label, 
        labelStyle: const TextStyle(fontSize: 12),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, overflow: TextOverflow.ellipsis))).toList(),
      onChanged: (val) {
        onChanged(val);
        _fetchTimetable();
      },
    );
  }

  Widget _buildTimetableGrid() {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(const Color(0xFF3F51B5).withOpacity(0.1)),
            columnSpacing: 15,
            border: TableBorder.all(color: Colors.grey.shade300),
            columns: [
              const DataColumn(label: Text('Time / Day', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              ..._days.map((day) => DataColumn(label: Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
            ],
            rows: _timeSlots.map((time) {
              return DataRow(cells: [
                DataCell(
                  InkWell(
                    onLongPress: () {
                      setState(() {
                        _timeSlots.remove(time);
                      });
                      _saveTimeSlots(); // Persist to Firebase
                    },
                    child: Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ),
                ..._days.map((day) {
                  final slot = _timetableData[day]?[time];
                  return DataCell(
                    InkWell(
                      onLongPress: slot != null ? () => _deleteSlot(day, time) : null,
                      onTap: () => _showSlotDialog(day, time, existingSlot: slot),
                      child: Container(
                        width: 100,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: slot == null
                            ? const Center(child: Icon(Icons.add, color: Colors.grey, size: 14))
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(slot.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10), overflow: TextOverflow.ellipsis),
                                  Text(slot.faculty, style: const TextStyle(fontSize: 9), overflow: TextOverflow.ellipsis),
                                  Text('R: ${slot.room}', style: const TextStyle(fontSize: 9, color: Colors.blueGrey), overflow: TextOverflow.ellipsis),
                                ],
                              ),
                      ),
                    ),
                  );
                }),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
