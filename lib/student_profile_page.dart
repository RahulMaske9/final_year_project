import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _slideAnimations = List.generate(
      4, // For header + 3 info cards
      (index) => Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(index * 0.2, (index + 1) * 0.25, curve: Curves.easeOut),
      )),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile', style: GoogleFonts.lato()),
        backgroundColor: const Color(0xFF3F51B5), // Indigo
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade50, Colors.grey.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 24.0),
          child: Column(
            children: [
              SlideTransition(position: _slideAnimations[0], child: _buildProfileHeader()),
              const SizedBox(height: 24),
              SlideTransition(position: _slideAnimations[1], child: _buildInfoCard('Personal Information', Icons.person_outline, [
                _buildInfoTile(Icons.cake_outlined, 'Date of Birth', '15 June 2010'),
                _buildInfoTile(Icons.transgender_outlined, 'Gender', 'Male'),
              ])),
              const SizedBox(height: 20),
              SlideTransition(position: _slideAnimations[2], child: _buildInfoCard('Contact Information', Icons.contact_phone_outlined, [
                _buildInfoTile(Icons.phone_outlined, 'Parent Contact', '+91 98765 43210'),
                _buildInfoTile(Icons.home_outlined, 'Address', 'Amravati'),
              ])),
              const SizedBox(height: 20),
              SlideTransition(position: _slideAnimations[3], child: _buildInfoCard('School Information', Icons.school_outlined, [
                _buildInfoTile(Icons.confirmation_number_outlined, 'Admission No', 'SCH-12345'),
                _buildInfoTile(Icons.date_range_outlined, 'Admission Date', '01 April 2020'),
              ])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: const Color(0xFF3F51B5).withAlpha(50),
            child: const CircleAvatar(
              radius: 56,
              backgroundColor: Color(0xFF3F51B5),
              child: Icon(Icons.person, size: 80, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text('Ramesh Suresh', style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData headerIcon, List<Widget> tiles) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withAlpha(26),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Row(
              children: [
                Icon(headerIcon, color: const Color(0xFF3F51B5)),
                const SizedBox(width: 12),
                Text(title, style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF3F51B5))),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ...tiles,
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(label, style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
      trailing: Text(value, style: GoogleFonts.lato(fontSize: 15, color: Colors.black54)),
    );
  }
}
