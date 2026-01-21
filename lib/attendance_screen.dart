import 'package:flutter/material.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  // Dummy data for attendance
  final List<Map<String, dynamic>> subjectAttendance = const [
    {'subject': 'Data Structures', 'attended': 28, 'total': 32},
    {'subject': 'Operating Systems', 'attended': 25, 'total': 30},
    {'subject': 'DBMS', 'attended': 30, 'total': 35},
    {'subject': 'Software Engineering', 'attended': 22, 'total': 25},
  ];

  @override
  Widget build(BuildContext context) {
    final Map<DateTime, String> attendanceData = {};
    // For demonstration, let's populate some dynamic data for the current month
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    for (int i = 0; i < daysInMonth; i++) {
      final day = firstDayOfMonth.add(Duration(days: i));
      if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
        attendanceData[day] = 'H'; // Weekend Holiday
      } else if (i % 7 == 0) {
        attendanceData[day] = 'A'; // Absent once a week
      } else {
        attendanceData[day] = 'P'; // Present
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalendar(context, now, attendanceData),
            const SizedBox(height: 24),
            const Text('Subject-wise Attendance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...subjectAttendance.map((subject) => _buildSubjectAttendanceCard(context, subject)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, DateTime month, Map<DateTime, String> data) {
    // This is a simplified calendar view. For a full-featured calendar, a library like table_calendar is recommended.
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final startingWeekday = firstDayOfMonth.weekday;

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('${month.month}/${month.year}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
              itemCount: daysInMonth + startingWeekday - 1,
              itemBuilder: (context, index) {
                if (index < startingWeekday - 1) {
                  return const SizedBox(); // Empty cell before the month starts
                }
                final day = firstDayOfMonth.add(Duration(days: index - (startingWeekday - 1)));
                final status = data[day] ?? '';

                Color dayColor = Colors.transparent;
                if (status == 'P') dayColor = Colors.green.shade200;
                if (status == 'A') dayColor = Colors.red.shade200;
                if (status == 'H') dayColor = Colors.blue.shade200;

                return Container(
                  margin: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    color: dayColor,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Center(child: Text(day.day.toString())),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _legendItem(Colors.green.shade200, 'Present'),
        _legendItem(Colors.red.shade200, 'Absent'),
        _legendItem(Colors.blue.shade200, 'Holiday'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color), // Simplified shape
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget _buildSubjectAttendanceCard(BuildContext context, Map<String, dynamic> subject) {
    final int attended = subject['attended'] as int;
    final int total = subject['total'] as int;
    final double percentage = total > 0 ? (attended / total) * 100 : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subject['subject'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Attended: $attended / $total'),
                Text('${percentage.toStringAsFixed(1)}%', style: TextStyle(fontWeight: FontWeight.bold, color: percentage < 75 ? Colors.red : Colors.green)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
