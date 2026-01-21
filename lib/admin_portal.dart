import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_app/login_screen.dart';
import 'package:first_app/manage_courses_screen.dart';
import 'package:first_app/manage_events_screen.dart';
import 'package:first_app/manage_faculty_screen.dart';
import 'package:first_app/manage_student_screen.dart';
import 'package:first_app/manage_timetable_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Portal', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade100, Colors.blue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Welcome & Metrics Card
                _buildWelcomeCard(),
                const SizedBox(height: 24),

                // Section 1: User Management
                _buildSectionTitle('User Management'),
                _buildGroupedCard([
                  _buildListTile(
                    title: 'Manage Students',
                    icon: Icons.people_alt_outlined,
                    color: Colors.blue.shade800,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ManageStudentScreen()));
                    },
                  ),
                  _buildListTile(
                    title: 'Manage Faculty',
                    icon: Icons.school_outlined,
                    color: Colors.orange.shade800,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ManageFacultyScreen()));
                    },
                    isLast: true,
                  ),
                ]),

                const SizedBox(height: 24),

                // Section 2: Academics & Timetable
                _buildSectionTitle('Academics & Timetable'),
                _buildGroupedCard([
                  _buildListTile(
                    title: 'Manage Courses',
                    icon: Icons.book_outlined,
                    color: Colors.green.shade700,
                    onTap: () {
                       Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ManageCoursesScreen()));
                    },
                  ),
                  _buildListTile(
                    title: 'Generate Timetable',
                    icon: Icons.schedule_outlined,
                    color: Colors.purple.shade700,
                    onTap: () {
                       Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ManageTimetableScreen()));
                    },
                    isLast: true,
                  ),
                ]),

                const SizedBox(height: 24),

                // Section 3: Communication
                _buildSectionTitle('Communication'),
                _buildGroupedCard([
                  _buildListTile(
                    title: 'Post Announcements',
                    icon: Icons.campaign_outlined,
                    color: Colors.lightBlue.shade700,
                    onTap: () {
                       Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ManageEventsScreen()));
                    },
                  ),
                  _buildListTile(
                    title: 'View Reports',
                    icon: Icons.bar_chart_outlined,
                    color: Colors.red.shade700,
                    onTap: () {
                       // Placeholder for View Reports
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reports feature coming soon!')));
                    },
                    isLast: true,
                  ),
                ]),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3F51B5).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Welcome, Admin',
                style: GoogleFonts.lato(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Icon(Icons.admin_panel_settings, color: Colors.white70, size: 30),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildMetricItem('1,250', 'Students'),
              Container(width: 1, height: 40, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 20)),
              _buildMetricItem('85', 'Faculty'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMetricItem(String count, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          count,
          style: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.lato(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _buildGroupedCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: isLast
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
