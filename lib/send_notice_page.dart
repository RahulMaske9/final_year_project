
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SendNoticePage extends StatefulWidget {
  const SendNoticePage({super.key});

  @override
  State<SendNoticePage> createState() => _SendNoticePageState();
}

class _SendNoticePageState extends State<SendNoticePage> {
  String? _selectedAudience;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  final List<String> _audience = ['All Users', 'Students', 'Faculty', 'Parents'];

  void _sendNotice() {
    if (_selectedAudience == null || _titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }

    // TODO: Implement actual notice sending logic

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notice sent to $_selectedAudience')),
    );

    _titleController.clear();
    _contentController.clear();
    setState(() {
      _selectedAudience = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Notice', style: GoogleFonts.lato()),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdown(),
            const SizedBox(height: 20),
            _buildTextField(controller: _titleController, label: 'Title'),
            const SizedBox(height: 20),
            _buildTextField(controller: _contentController, label: 'Content', maxLines: 8),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: _sendNotice,
                icon: const Icon(Icons.send, color: Colors.white),
                label: Text('Send Notice', style: GoogleFonts.lato(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
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
          hint: Text('Select Audience', style: GoogleFonts.lato(color: Colors.grey.shade600)),
          value: _selectedAudience,
          items: _audience.map((item) => DropdownMenuItem(value: item, child: Text(item, style: GoogleFonts.lato()))).toList(),
          onChanged: (value) => setState(() => _selectedAudience = value),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.lato(),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
