
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

// Model for attendance event
enum AttendanceStatus { Present, Absent, Holiday }

class AttendanceEvent {
  final AttendanceStatus status;
  const AttendanceEvent(this.status);
}

class NewAttendancePage extends StatefulWidget {
  const NewAttendancePage({super.key});

  @override
  State<NewAttendancePage> createState() => _NewAttendancePageState();
}

class _NewAttendancePageState extends State<NewAttendancePage> {
  late Map<DateTime, List<AttendanceEvent>> _events;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  int _presentDays = 0;
  int _absentDays = 0;
  double _attendancePercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    // Dummy data - In a real app, this would be fetched from a server
    _events = {
      DateTime.utc(2024, 7, 1): [const AttendanceEvent(AttendanceStatus.Present)],
      DateTime.utc(2024, 7, 2): [const AttendanceEvent(AttendanceStatus.Present)],
      DateTime.utc(2024, 7, 3): [const AttendanceEvent(AttendanceStatus.Absent)],
      DateTime.utc(2024, 7, 4): [const AttendanceEvent(AttendanceStatus.Present)],
      DateTime.utc(2024, 7, 5): [const AttendanceEvent(AttendanceStatus.Present)],
      DateTime.utc(2024, 7, 6): [const AttendanceEvent(AttendanceStatus.Holiday)],
      DateTime.utc(2024, 7, 8): [const AttendanceEvent(AttendanceStatus.Present)],
      DateTime.utc(2024, 7, 9): [const AttendanceEvent(AttendanceStatus.Present)],
      DateTime.utc(2024, 7, 10): [const AttendanceEvent(AttendanceStatus.Present)],
      DateTime.utc(2024, 7, 11): [const AttendanceEvent(AttendanceStatus.Absent)],
      DateTime.utc(2024, 7, 12): [const AttendanceEvent(AttendanceStatus.Present)],
    };
    _calculateSummary();
  }

  void _calculateSummary() {
    int present = 0;
    int absent = 0;
    _events.forEach((day, events) {
      if (events.isNotEmpty) {
        if (events.first.status == AttendanceStatus.Present) present++;
        if (events.first.status == AttendanceStatus.Absent) absent++;
      }
    });

    setState(() {
      _presentDays = present;
      _absentDays = absent;
      final totalDays = present + absent;
      _attendancePercentage = totalDays == 0 ? 0 : (present / totalDays) * 100;
    });
  }


  List<AttendanceEvent> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Details', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          _buildSummaryCards(),
          _buildCalendar(),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryCard('Present', '$_presentDays Days', Colors.green, Icons.check_circle_outline),
          _summaryCard('Absent', '$_absentDays Days', Colors.red, Icons.cancel_outlined),
          _summaryCard('Percentage', '${_attendancePercentage.toStringAsFixed(1)}%', Colors.blue, Icons.pie_chart_outline),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 8),
              Text(title, style: GoogleFonts.lato(color: Colors.grey.shade600)),
              Text(value, style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: TableCalendar<AttendanceEvent>(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: _getEventsForDay,
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(color: Colors.transparent), // We use builders
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return null;
            final status = events.first.status;
            Color color = Colors.grey;
            if (status == AttendanceStatus.Present) color = Colors.green;
            if (status == AttendanceStatus.Absent) color = Colors.red;
            if (status == AttendanceStatus.Holiday) color = Colors.orange;

            return Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.all(4.0),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _legendItem('Present', Colors.green),
          _legendItem('Absent', Colors.red),
          _legendItem('Holiday', Colors.orange),
        ],
      ),
    );
  }

  Widget _legendItem(String text, Color color) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
