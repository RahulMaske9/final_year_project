
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageTimetablePage extends StatefulWidget {
  const ManageTimetablePage({super.key});

  @override
  State<ManageTimetablePage> createState() => _ManageTimetablePageState();
}

class _ManageTimetablePageState extends State<ManageTimetablePage> {
  String? _selectedBranch;
  String? _selectedYear;

  final List<String> _branches = ['IT', 'CSE', 'EXTC', 'CIVIL', 'MECHANICAL', 'AIDS'];
  final List<String> _years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];

  void _uploadTimetable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Upload functionality not implemented yet.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Timetable', style: GoogleFonts.lato()),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdowns(),
            const SizedBox(height: 30),
            _buildUploadSection(),
            const SizedBox(height: 30),
            _buildTimetablePreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdowns() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            hint: 'Select Branch',
            value: _selectedBranch,
            items: _branches,
            onChanged: (value) => setState(() => _selectedBranch = value),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildDropdown(
            hint: 'Select Year',
            value: _selectedYear,
            items: _years,
            onChanged: (value) => setState(() => _selectedYear = value),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({required String hint, String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint, style: GoogleFonts.lato(color: Colors.grey.shade600)),
          value: value,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: GoogleFonts.lato()))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upload New Timetable', style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                const Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.blueAccent),
                const SizedBox(width: 20),
                Expanded(child: Text('Upload the timetable in PDF or image format.', style: GoogleFonts.lato(fontSize: 16))),
                ElevatedButton(
                  onPressed: _uploadTimetable,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                  child: const Text('Upload'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimetablePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Current Timetable', style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Container(
            height: 300,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: _selectedBranch != null && _selectedYear != null
                ? Text('Showing timetable for\n$_selectedBranch - $_selectedYear', textAlign: TextAlign.center, style: GoogleFonts.lato(fontSize: 18, color: Colors.grey.shade700))
                : Text('Select branch and year to view timetable.', style: GoogleFonts.lato(fontSize: 16, color: Colors.grey.shade700)),
          ),
        ),
      ],
    );
  }
}
