import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SemesterPage extends StatefulWidget {
  final String year;
  const SemesterPage({super.key, required this.year});

  @override
  State<SemesterPage> createState() => _SemesterPageState();
}

class _SemesterPageState extends State<SemesterPage> {
  late List<String> _semesters;
  final Map<String, bool> _expandedState = {};

  @override
  void initState() {
    super.initState();
    final yearIndex = int.parse(widget.year.substring(0, 1)) - 1;
    _semesters = [
      'Semester ${yearIndex * 2 + 1}',
      'Semester ${yearIndex * 2 + 2}'
    ];
    for (var semester in _semesters) {
      _expandedState[semester] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.year, style: GoogleFonts.lato()),
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
        child: ListView.builder(
          padding: const EdgeInsets.all(20.0),
          itemCount: _semesters.length,
          itemBuilder: (context, index) {
            return _buildSemesterCard(_semesters[index]);
          },
        ),
      ),
    );
  }

  Widget _buildSemesterCard(String semester) {
    final isExpanded = _expandedState[semester]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        children: [
          Card(
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.zero,
            child: InkWell(
              onTap: () {
                setState(() {
                  _expandedState[semester] = !isExpanded;
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade600, Colors.teal.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      semester,
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 16.0, right: 16.0),
              child: Column(
                children: [
                  _buildSessionalCard('Sessional 1'),
                  const SizedBox(height: 10),
                  _buildSessionalCard('Sessional 2'),
                  const SizedBox(height: 10),
                  _buildSessionalCard('Semester'),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _buildSessionalCard(String title) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () {
          // TODO: Implement navigation for sessional details
          print('Tapped on $title');
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
