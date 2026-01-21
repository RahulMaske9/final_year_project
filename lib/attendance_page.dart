import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for attendance
    final attendanceData = {
      'totalDays': 120,
      'presentDays': 110,
      'absentDays': 8,
      'lateDays': 2,
    };
    final overallPercentage = (attendanceData['presentDays']! / attendanceData['totalDays']!) * 100;

    final dailyRecords = [
      {'date': 'October 23, 2023', 'status': 'Present'},
      {'date': 'October 22, 2023', 'status': 'Present'},
      {'date': 'October 21, 2023', 'status': 'Absent'},
      {'date': 'October 20, 2023', 'status': 'Present'},
      {'date': 'October 19, 2023', 'status': 'Late'},
      {'date': 'October 18, 2023', 'status': 'Present'},
      {'date': 'October 17, 2023', 'status': 'Present'},
    ];


    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance', style: GoogleFonts.lato()),
        backgroundColor: const Color(0xFF3F51B5), // Indigo
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFFF5F7FA), const Color(0xFFE9EBEE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            _buildSummaryCard(overallPercentage, attendanceData),
            const SizedBox(height: 20),
            _buildDailyRecordsCard(dailyRecords),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double percentage, Map<String, int> data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Overall Attendance',
              style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 120,
              width: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(_getPercentageColor(percentage)),
                  ),
                  Center(
                    child: Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryDetail('Present', data['presentDays']!, Colors.green),
                _buildSummaryDetail('Absent', data['absentDays']!, Colors.red),
                _buildSummaryDetail('Late', data['lateDays']!, Colors.orange),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryDetail(String title, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: GoogleFonts.lato(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 75) return Colors.orange;
    return Colors.red;
  }

  Widget _buildDailyRecordsCard(List<Map<String, Object>> records) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Recent Records',
              style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ...records.map((record) => _buildRecordTile(record['date'] as String, record['status'] as String)).toList()
        ],
      ),
    );
  }

  Widget _buildRecordTile(String date, String status) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(status).withAlpha(26),
        child: Icon(_getStatusIcon(status), color: _getStatusColor(status)),
      ),
      title: Text(date, style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
      trailing: Text(
        status,
        style: GoogleFonts.lato(color: _getStatusColor(status), fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch(status) {
      case 'Present':
        return Colors.green;
      case 'Absent':
        return Colors.red;
      case 'Late':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

    IconData _getStatusIcon(String status) {
    switch(status) {
      case 'Present':
        return Icons.check_circle_outline;
      case 'Absent':
        return Icons.cancel_outlined;
      case 'Late':
        return Icons.watch_later_outlined;
      default:
        return Icons.help_outline;
    }
  }
}
