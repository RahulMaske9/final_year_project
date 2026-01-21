
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Dummy data model for Fee Record
class FeeRecord {
  final String studentName;
  final String rollNo;
  final double amount;
  String status;

  FeeRecord({
    required this.studentName,
    required this.rollNo,
    required this.amount,
    required this.status,
  });
}

class FeeStudentListPage extends StatefulWidget {
  final String branch;
  final String year;

  const FeeStudentListPage({super.key, required this.branch, required this.year});

  @override
  State<FeeStudentListPage> createState() => _FeeStudentListPageState();
}

class _FeeStudentListPageState extends State<FeeStudentListPage> {
  final List<FeeRecord> _feeRecords = [
    FeeRecord(studentName: 'Student 1', rollNo: 'IT-01', amount: 50000, status: 'Paid'),
    FeeRecord(studentName: 'Student 2', rollNo: 'CSE-02', amount: 52000, status: 'Pending'),
    FeeRecord(studentName: 'Student 3', rollNo: 'EXTC-03', amount: 50000, status: 'Paid'),
    FeeRecord(studentName: 'Student 4', rollNo: 'MECH-04', amount: 48000, status: 'Pending'),
  ];

  List<FeeRecord> _filteredRecords = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredRecords = _feeRecords;
    _searchController.addListener(_filterRecords);
  }

  void _filterRecords() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRecords = _feeRecords.where((record) {
        return record.studentName.toLowerCase().contains(query) ||
            record.rollNo.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.branch} - ${widget.year} Fees', style: GoogleFonts.lato()),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search student by name or roll no...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _filteredRecords.length,
              itemBuilder: (context, index) => _buildFeeCard(_filteredRecords[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeCard(FeeRecord record) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(record.studentName, style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Roll No: ${record.rollNo}', style: GoogleFonts.lato(color: Colors.black54)),
            const SizedBox(height: 8),
            Text('Amount: \u20b9${record.amount.toStringAsFixed(2)}', style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
            const Divider(height: 20, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Status:', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: record.status,
                  items: <String>['Paid', 'Pending'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: GoogleFonts.lato(color: value == 'Paid' ? Colors.green : Colors.orange.shade700, fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      record.status = newValue!;
                    });
                  },
                  underline: Container(), // Hides the default underline
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
