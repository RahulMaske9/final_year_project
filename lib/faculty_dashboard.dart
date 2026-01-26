import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_app/faculty_enter_marks_screen.dart';
import 'package:first_app/faculty_select_year_screen.dart';
import 'package:first_app/mark_attendance_screen.dart';
import 'package:first_app/login_screen.dart';
import 'package:first_app/manage_timetable_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FacultyDashboard extends StatefulWidget {
  const FacultyDashboard({super.key});

  @override
  State<FacultyDashboard> createState() => _FacultyDashboardState();
}

class _FacultyDashboardState extends State<FacultyDashboard> {
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _logout() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  void _showFeatureNotImplemented(String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName feature is coming soon!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF3F51B5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Faculty Portal', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(_currentUserId).snapshots(),
        builder: (context, snapshot) {
          String facultyName = 'Professor';
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            facultyName = data['displayName'] ?? data['firstName'] ?? 'Professor';
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildWelcomeCard(facultyName),
                const SizedBox(height: 24),
                _buildAttendancePromotion(),
                const SizedBox(height: 24),
                _buildDashboardSection(
                  title: 'Class Management',
                  tiles: [
                    _buildDashboardTile(
                      label: 'My Students',
                      icon: Icons.people_alt_outlined,
                      color: Colors.teal.shade700,
                      onTap: () => _navigateTo(const FacultySelectYearScreen()),
                    ),
                    _buildDashboardTile(
                      label: 'Take Attendance',
                      icon: Icons.how_to_reg_outlined,
                      color: Colors.green.shade700,
                      onTap: () => _navigateTo(const MarkAttendanceScreen()),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDashboardSection(
                  title: 'Academics & Exams',
                  tiles: [
                    _buildDashboardTile(
                      label: 'Enter Marks',
                      icon: Icons.edit_note_outlined,
                      color: Colors.indigo.shade700,
                      onTap: () => _navigateTo(const FacultyEnterMarksScreen()),
                    ),
                    _buildDashboardTile(
                      label: 'Assignments',
                      icon: Icons.assignment_outlined,
                      color: Colors.orange.shade800,
                      onTap: () => _showFeatureNotImplemented('Assignments'),
                    ),
                    _buildDashboardTile(
                      label: 'Timetable',
                      icon: Icons.calendar_today_outlined,
                      color: Colors.purple.shade700,
                      onTap: () => _navigateTo(const ManageTimetablePage()),
                    ),
                    _buildDashboardTile(
                      label: 'Course Material',
                      icon: Icons.menu_book_outlined,
                      color: Colors.blue.shade800,
                      onTap: () => _showFeatureNotImplemented('Course Material'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDashboardSection(
                  title: 'Communication',
                  tiles: [
                    _buildDashboardTile(
                      label: 'Broadcast Notice',
                      icon: Icons.campaign_outlined,
                      color: Colors.pink.shade700,
                      onTap: () => _showFeatureNotImplemented('Notices'),
                    ),
                    _buildDashboardTile(
                      label: 'Leave Requests',
                      icon: Icons.mail_outline,
                      color: Colors.red.shade700,
                      onTap: () => _showFeatureNotImplemented('Leave Requests'),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome,',
            style: GoogleFonts.lato(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Faculty Active',
                  style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendancePromotion() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF3F51B5).withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.fact_check_outlined, color: Color(0xFFFFC107), size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Attendance',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Mark presence for your students',
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _navigateTo(const MarkAttendanceScreen()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F51B5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('Go'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardSection({required String title, required List<Widget> tiles}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: tiles,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTile({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.lato(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
